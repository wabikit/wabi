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
            stylesheet_link_tag("tailwind", "data-turbo-track": "reload")
            javascript_importmap_tags
          end
          body(class: "bg-background text-foreground antialiased min-h-screen") do
            # `yield_content` uses Phlex::Rails capture, which returns the
            # captured HTML as a string. Phlex's element method uses that
            # return value as content ONLY when it's the last expression in
            # the block AND the buffer didn't grow inside. To compose
            # additional siblings (the Toaster) we must `raw(safe(...))` the
            # captured string explicitly, then render the others.
            raw safe(yield_content(&block))
            # Singleton toaster container. Toasts are appended here at runtime
            # (in production: via `turbo_stream.append "wabi-toaster", ...`).
            render Components::UI::Toaster.new
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
