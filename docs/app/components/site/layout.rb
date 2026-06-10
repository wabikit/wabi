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
      include Phlex::Rails::Helpers::Request

      CHROME_VALUES = [:bare, :sidebar_only, :full].freeze

      def initialize(title:, chrome: :bare)
        raise ArgumentError, "chrome must be one of #{CHROME_VALUES}" unless CHROME_VALUES.include?(chrome)
        @title = title
        @chrome = chrome
      end

      def view_template(&block)
        doctype
        html(lang: "en", data: { controller: "wabi--theme" }) do
          head do
            title { "#{@title} — Wabi" }
            meta(name: "viewport", content: "width=device-width, initial-scale=1")
            link(rel: "icon", href: "/favicon.ico", sizes: "32x32")
            link(rel: "icon", href: "/icon.svg", type: "image/svg+xml")
            link(rel: "icon", href: "/icon.png", type: "image/png")
            link(rel: "apple-touch-icon", href: "/icon.png")
            stylesheet_link_tag("tailwind", "data-turbo-track": "reload")
            javascript_importmap_tags
          end
          body(class: "bg-background text-foreground antialiased min-h-screen") do
            render_header
            render_chrome(&block)
            render ::Components::UI::Toaster.new
          end
        end
      end

      private

      def render_header
        header(class: "border-b border-border sticky top-0 z-30 bg-background") do
          div(class: "container mx-auto flex h-14 items-center justify-between px-4") do
            div(class: "flex items-center gap-2") do
              render ::Components::Site::SidebarToggle.new if @chrome != :bare
              a(href: "/", class: "flex items-center gap-2 font-bold text-lg") do
                # Wabi gem mark — inherits the link's text color via currentColor.
                raw safe(<<~SVG)
                  <svg viewBox="0 0 32 32" width="22" height="22" class="shrink-0" aria-hidden="true">
                    <path d="M9 6.5 L22.5 6 L26 10 L24.5 11.2 L28 13 L16 28 L4 13 Z" fill="currentColor"/>
                    <path d="M9 6.5 L22.5 6 L21.5 13 L10.5 13 Z" fill="#fff" fill-opacity="0.13"/>
                    <path d="M22.5 6 L26 10 L24.5 11.2 L28 13 L21.5 13 Z" fill="#fff" fill-opacity="0.20"/>
                    <path d="M21.5 13 L28 13 L16 28 Z" fill="#fff" fill-opacity="0.10"/>
                    <path d="M9 6.5 L10.5 13 L4 13 Z" fill="#000" fill-opacity="0.18"/>
                    <path d="M4 13 L10.5 13 L16 28 Z" fill="#000" fill-opacity="0.12"/>
                  </svg>
                SVG
                span { "Wabi" }
              end
            end
            div(class: "flex items-center gap-2") do
              render ::Components::Site::SearchBox.new if @chrome != :bare
              a(href: "/docs/components",
                class: "text-sm text-muted-foreground hover:text-foreground px-2") { "Components" }
              a(href: "/docs/themes",
                class: "text-sm text-muted-foreground hover:text-foreground px-2") { "Themes" }
              render ::Components::Site::ModeToggle.new
              render ::Components::Site::ThemePicker.new
            end
          end
        end
      end

      def render_chrome(&block)
        case @chrome
        when :bare
          raw safe(yield_content(&block))
        when :sidebar_only
          div(class: "flex") do
            render ::Components::Site::Sidebar.new(current_path: request.path)
            div(class: "flex-1 min-w-0") { raw safe(yield_content(&block)) }
          end
        when :full
          div(class: "flex") do
            render ::Components::Site::Sidebar.new(current_path: request.path)
            div(class: "flex-1 min-w-0") { raw safe(yield_content(&block)) }
            render ::Components::Site::TableOfContents.new
          end
        end
      end

      def yield_content(&block)
        capture(&block)
      end
    end
  end
end
