# frozen_string_literal: true

require "yaml"

# Regression guard for the v0.14.x dogfooding bug: toaster_controller.js imports
# `controllers/wabi/_shared/toast_stack`, but toast/manifest.yml didn't declare
# that file under `shared_files:`, so the builder omitted it from toast.json ->
# `wabi:add toast` never installed it -> the importmap couldn't pin the bare
# specifier -> "Failed to register controller: wabi--toaster".
#
# This scans every real component: any `controllers/wabi/_shared/<x>` import in a
# component's controllers MUST be declared in that component's manifest
# `shared_files:`, or the installed component is broken.
RSpec.describe "component _shared import integrity" do
  components_dir = File.expand_path("../components", __dir__)
  import_re = %r{controllers/wabi/_shared/([a-z0-9_]+)}

  component_dirs = Dir.children(components_dir).select do |name|
    next false if name.start_with?("_")
    File.directory?(File.join(components_dir, name))
  end.sort

  component_dirs.each do |name|
    dir = File.join(components_dir, name)

    it "#{name}: every _shared import is declared in manifest shared_files" do
      controllers = Dir.glob(File.join(dir, "*_controller.js"))
      imported = controllers.flat_map do |f|
        File.read(f).scan(import_re).flatten
      end.uniq.sort
      next if imported.empty? # component imports no shared files

      manifest_path = File.join(dir, "manifest.yml")
      manifest = File.exist?(manifest_path) ? (YAML.safe_load_file(manifest_path) || {}) : {}
      declared = Array(manifest["shared_files"]).map do |rel|
        File.basename(rel.to_s, ".js")
      end.sort

      missing = imported - declared
      expect(missing).to be_empty,
        "#{name} imports controllers/wabi/_shared/#{missing.join(', ')} but does " \
        "not declare #{missing.map { |m| "_shared/#{m}.js" }.join(', ')} in " \
        "manifest.yml shared_files: -> the file won't ship via `wabi:add #{name}` " \
        "and the controller will fail to register."
    end
  end
end
