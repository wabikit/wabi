# frozen_string_literal: true

require "rails/generators"
require "wabi/lockfile"

module Wabi
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../templates", __dir__)

      desc "Set up Wabi in this Rails app: copy tokens, theme controller, init lockfile."

      class_option :force, type: :boolean, default: false,
                           desc: "Overwrite existing tokens.css and theme_controller.js (the lockfile is preserved)."

      def copy_tokens
        copy_file "tokens.css", "app/assets/tailwind/wabi/tokens.css",
                  force: options[:force], skip: !options[:force]
      end

      def copy_theme_controller
        copy_file "controllers/wabi/theme_controller.js",
                  "app/javascript/controllers/wabi/theme_controller.js",
                  force: options[:force], skip: !options[:force]
      end

      def init_lockfile
        path = File.join(destination_root, "config/wabi.lock.json")
        FileUtils.mkdir_p(File.dirname(path))
        return if File.exist?(path)
        lockfile = Wabi::Lockfile.load(path)
        lockfile.save
      end

      # Components install into app/components/ui/ under the Components::UI
      # namespace. Zeitwerk would expect Components::Ui for the "ui" dir, so the
      # app 500s on the first component reference unless "UI" is a known acronym.
      # Register it (idempotent — skipped if the file already exists).
      def register_ui_acronym
        create_file "config/initializers/wabi.rb", <<~RUBY
          # frozen_string_literal: true

          # Wabi components live in app/components/ui/ under the Components::UI
          # namespace. Zeitwerk needs the "UI" acronym to map the ui/ directory
          # to the UI constant (otherwise it expects Components::Ui).
          ActiveSupport::Inflector.inflections(:en) do |inflect|
            inflect.acronym "UI"
          end
        RUBY
      end

      def print_next_steps
        say "\n  Wabi installed. Next steps:", :green
        say ""
        say "    1. Import tokens AFTER the Tailwind import in app/assets/tailwind/application.css:"
        say "         @import \"tailwindcss\";"
        say "         @import \"./wabi/tokens.css\";"
        say ""
        say "    2. Use 'tailwind' (not 'application') in your stylesheet link tag:"
        say "         stylesheet_link_tag \"tailwind\", \"data-turbo-track\": \"reload\""
        say "       (Rails 8.1's :app symbol also works if you keep the default ERB layout.)"
        say ""
        say "    3. Mount the theme controller on <html> in your layout:"
        say "         <html data-controller=\"wabi--theme\">"
        say ""
        say "    4. Add components from the registry:"
        say "         bin/rails g wabi:add button input card"
        say "       Components autoload under Components::UI::* (Phlex 2.x convention)."
        say "       Render them as:  render Components::UI::Button.new"
        say ""
        say "    5. If Tailwind doesn't pick up component classes, add this near the top of"
        say "       application.css (Tailwind 4 normally auto-detects .rb files, but in"
        say "       unusual asset paths an explicit @source helps):"
        say "         @source \"../../components/**/*.rb\";"
        say ""
        say "    Run wabi:install --force later to refresh tokens.css and theme_controller.js"
        say "    after a gem upgrade (your wabi.lock.json is preserved)."
      end
    end
  end
end
