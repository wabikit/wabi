# frozen_string_literal: true

require "rails/generators"
require "wabi/lockfile"

module Wabi
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../templates", __dir__)

      desc "Set up Wabi in this Rails app: copy tokens, theme controller, init lockfile."

      def copy_tokens
        copy_file "tokens.css", "app/assets/tailwind/wabi/tokens.css"
      end

      def copy_theme_controller
        copy_file "controllers/wabi/theme_controller.js",
                  "app/javascript/controllers/wabi/theme_controller.js"
      end

      def init_lockfile
        path = File.join(destination_root, "config/wabi.lock.json")
        FileUtils.mkdir_p(File.dirname(path))
        return if File.exist?(path)
        lockfile = Wabi::Lockfile.load(path)
        lockfile.save
      end

      def print_next_steps
        say "\n  Wabi installed. Next steps:", :green
        say "    1. Import tokens in app/assets/tailwind/application.css (AFTER @import \"tailwindcss\";):"
        say "         @import \"./wabi/tokens.css\";"
        say "    2. Add the theme controller to your <html data-controller=\"wabi--theme\"> tag."
        say "    3. Add your first component:  bin/rails g wabi:add button"
      end
    end
  end
end
