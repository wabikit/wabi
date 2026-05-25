# frozen_string_literal: true

# Note: Phlex 2.x's `phlex:install` generator creates a `Components::Base`
# instead of the top-level `ApplicationComponent` used by Phlex 1.x. The
# autoloader (see config/initializers/phlex.rb) namespaces everything under
# `app/components/` into the `Components::` module, so this class autoloads
# as `Components::Site::Layout`.
module Components
  module Site
    class Layout < Components::Base
      include Phlex::Rails::Helpers::StyleSheetLinkTag
      include Phlex::Rails::Helpers::JavaScriptImportmapTags

      def initialize(title:)
        @title = title
      end

      def view_template(&block)
        doctype
        html(data: { controller: "wabi--theme" }) do
          head do
            title { "#{@title} — Wabi" }
            meta(name: "viewport", content: "width=device-width, initial-scale=1")
            stylesheet_link_tag("application")
            javascript_importmap_tags
          end
          body(class: "bg-background text-foreground antialiased min-h-screen") do
            yield_content(&block)
          end
        end
      end

      private

      def yield_content(&block)
        capture(&block)
      end
    end
  end
end
