# frozen_string_literal: true

require "rails/generators"
require "digest"
require "json"
require "open3"
require "tempfile"
require "wabi/registry_client"
require "wabi/lockfile"

module Wabi
  module Generators
    class UpdateGenerator < Rails::Generators::Base
      argument :components, type: :array, default: [],
               banner: "[component_name ...]"

      class_option :force,   type: :boolean, default: false,
                             desc: "Overwrite locally-edited files without prompting."
      class_option :dry_run, type: :boolean, default: false,
                             desc: "Report planned changes, write nothing."

      desc "Update installed Wabi components to the latest registry versions."

      class UpdateAborted < StandardError; end

      def update_components
        names = target_names
        if names.empty?
          say "  no components to update", :yellow
          return
        end
        names.each { |name| update_component(name) }
        lockfile.save unless options[:dry_run]
      rescue UpdateAborted => e
        say "  aborted: #{e.message}", :red
      end

      private

      def target_names
        components.any? ? components : lockfile.components.keys
      end

      def lockfile
        @lockfile ||= Wabi::Lockfile.load(File.join(destination_root, "config/wabi.lock.json"))
      end

      def client
        @client ||= Wabi::RegistryClient.new(base_url: lockfile.registry)
      end

      def update_component(name)
        unless lockfile.components.key?(name)
          say "  not installed: #{name} (use `wabi:add #{name}`)", :yellow
          return
        end

        installed_version = lockfile.components[name]["version"]
        data              = client.fetch(name)
        remote_version    = data["version"]

        if Gem::Version.new(remote_version) <= Gem::Version.new(installed_version)
          say "  up-to-date  #{name} (#{installed_version})", :cyan
          return
        end

        say "  updating    #{name} (#{installed_version} -> #{remote_version})", :green

        files_map     = {}
        installed_map = lockfile.components[name]["files"] || {}

        data["files"].each do |file|
          path     = file["path"]
          new_hash = Digest::SHA256.hexdigest(file["content"])
          target   = File.join(destination_root, path)

          files_map[path] = { "hash" => new_hash, "content" => file["content"] }

          if !File.exist?(target)
            write_file(target, file["content"], reason: "create")
            next
          end

          on_disk_hash   = Digest::SHA256.hexdigest(File.read(target))
          installed_hash = Wabi::Lockfile.file_entry(installed_map[path])[:hash]

          if installed_hash.nil?
            handle_conflict(path, target, file["content"], reason: "legacy lockfile has no per-file hash")
            next
          end

          if on_disk_hash == installed_hash
            write_file(target, file["content"], reason: "update")
          else
            base_content = Wabi::Lockfile.file_entry(installed_map[path])[:content]
            if base_content && git_available? && !options[:force]
              merge_file(path, target, base_content, file["content"])
            else
              handle_conflict(path, target, file["content"], reason: "edited locally")
            end
          end
        end

        print_js_deps_diff(name, data["js_dependencies"])

        lockfile.record(
          name,
          version:         remote_version,
          hash:            Digest::SHA256.hexdigest(JSON.generate(data["files"])),
          files:           files_map,
          js_dependencies: data["js_dependencies"],
        )
      end

      def write_file(target, content, reason:)
        if options[:dry_run]
          say "  would write #{target} (#{reason})", :cyan
          return
        end
        FileUtils.mkdir_p(File.dirname(target))
        File.write(target, content)
        say "  #{reason.ljust(10)} #{target}", :green
      end

      def handle_conflict(path, target, new_content, reason:)
        if options[:force]
          write_file(target, new_content, reason: "force-overwrite")
          return
        end
        if options[:dry_run]
          say "  CONFLICT    #{path} (#{reason}) - would prompt", :yellow
          return
        end

        loop do
          say ""
          say "  conflict    #{path}", :yellow
          say "    #{reason}. Overwrite with new version?", :yellow
          answer = prompt_conflict(path)
          case answer
          when "y"
            write_file(target, new_content, reason: "overwrite")
            return
          when "n"
            say "    skipped     #{path}", :cyan
            return
          when "d"
            print_diff(target, new_content)
            next
          when "q"
            raise UpdateAborted, "user aborted update"
          end
        end
      end

      def prompt_conflict(_path)
        ask("    (y)es / (n)o / (d)iff / (q)uit?", limited_to: %w[y n d q])
      end

      def merge_file(path, target, base_content, new_content)
        if options[:dry_run]
          say "  would 3-way merge #{path}", :cyan
          return
        end

        begin
          merged, conflicts, err = three_way_merge(target, base_content, new_content)
        rescue Errno::ENOENT, StandardError => e
          # git vanished mid-run, or any other spawn/IO failure.
          merged, conflicts, err = nil, 255, e.message
        end

        # git merge-file returns 255 (an error, NOT a conflict count) on
        # failure. Treat that — or empty output when we expected content — as a
        # failure and DO NOT write: blanking the user's edited file would be
        # irreversible data loss. Leave the file untouched; the user can re-run.
        if conflicts == 255 || conflicts.negative? || (merged.to_s.empty? && !new_content.empty?)
          detail = err.to_s.strip.empty? ? "" : ": #{err.to_s.strip.lines.first&.chomp}"
          say "  error       #{path} (git merge-file failed, file unchanged#{detail})", :red
          return
        end

        File.write(target, merged)
        if conflicts.zero?
          say "  merged      #{path}", :green
        else
          # git caps the exit code at 127, so report 127+ rather than lying.
          count = conflicts >= 127 ? "127+ conflicts" : "#{conflicts} conflict#{'s' if conflicts != 1}"
          say "  merged      #{path} (#{count} — resolve the <<<<<<< markers)", :yellow
        end
      end

      def git_available?
        return @git_available unless @git_available.nil?
        @git_available = system("git", "--version", out: File::NULL, err: File::NULL) || false
      end

      # 3-way merge via `git merge-file`. Arg order is current/base/other =
      # local/base/new (DO NOT reorder). Returns [merged_string, status, stderr]:
      # status 0 = clean, 1..127 = number of conflicts (git caps at 127),
      # 255 = error. stderr carries git's diagnostic on error.
      def three_way_merge(local_path, base_content, new_content)
        Tempfile.create("wabi-base") do |base_f|
          Tempfile.create("wabi-new") do |new_f|
            base_f.write(base_content); base_f.flush
            new_f.write(new_content);   new_f.flush
            merged, err, status = Open3.capture3(
              "git", "merge-file", "-p",
              "-L", "local (your edits)", "-L", "base (original)", "-L", "new (registry)",
              local_path, base_f.path, new_f.path
            )
            [merged, status.exitstatus, err]
          end
        end
      end

      def print_diff(target, new_content)
        on_disk = File.exist?(target) ? File.read(target) : ""
        on_disk_lines = on_disk.split("\n", -1)
        new_lines     = new_content.split("\n", -1)
        say ""
        say "    --- on-disk", :red
        on_disk_lines.each { |l| say "    - #{l}", :red }
        say "    +++ new", :green
        new_lines.each { |l| say "    + #{l}", :green }
        say ""
      end

      def print_js_deps_diff(name, new_deps)
        new_deps ||= {}
        old_deps   = lockfile.components.dig(name, "js_dependencies") || {}

        added   = new_deps.reject { |pkg, _| old_deps.key?(pkg) }
        changed = new_deps.select { |pkg, ver| old_deps.key?(pkg) && old_deps[pkg] != ver }

        return if added.empty? && changed.empty?

        say ""
        say "  JS pin changes for #{name}:", :yellow
        (added.merge(changed)).each do |pkg, version|
          v = version.to_s.sub(/\A[~^]/, "")
          v = "1.0.0" if v.empty?
          say %(    pin "#{pkg}", to: "https://cdn.jsdelivr.net/npm/#{pkg}@#{v}/+esm")
        end
      end
    end
  end
end
