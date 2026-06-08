# frozen_string_literal: true

module Components
  module UI
    class SidebarProvider < Wabi::Base
      variants do
        base "group/sidebar flex min-h-svh w-full"
      end

      def initialize(variant: :sidebar, default_collapsed: false, persist_key: "wabi-sidebar", **attrs)
        @variant           = variant
        @default_collapsed = default_collapsed
        @persist_key       = persist_key
        @attrs             = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          **@attrs,
          data: {
            controller: "wabi--sidebar",
            "wabi--sidebar-default-collapsed-value": @default_collapsed.to_s,
            "wabi--sidebar-persist-key-value":       @persist_key,
          },
          "data-state":   @default_collapsed ? "collapsed" : "expanded",
          "data-mobile":  "closed",
          "data-variant": @variant.to_s,
          class: merge_class(tokens, (@variant == :inset ? "bg-sidebar" : nil), user_class)
        ) do
          div(
            "aria-hidden": "true",
            data: {
              "wabi--sidebar-target": "backdrop",
              action: "click->wabi--sidebar#closeMobile",
            },
            class: "fixed inset-0 z-40 bg-black/50 hidden lg:hidden " \
                   "group-data-[mobile=open]/sidebar:block"
          )
          yield if block
        end
      end
    end
  end
end
