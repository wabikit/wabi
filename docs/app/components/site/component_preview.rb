# frozen_string_literal: true

module Components
  module Site
    # Tabbed Preview / Code view around a single example. The block passed
    # to the component is the live render (Preview tab); the `source:`
    # kwarg is the literal Ruby/HTML text shown via CodeBlock in the Code
    # tab. Callers MUST keep both in sync — there's no automatic
    # extraction.
    #
    # Uses Wabi's own Tabs component (dogfooding). Tabs ships with full
    # Zag.js wiring: ARIA tablist/tab/tabpanel roles, keyboard arrow nav,
    # focus management, and an :active data-state that styles the active
    # trigger.
    class ComponentPreview < Components::Base
      def initialize(source:, language: "ruby")
        @source   = source
        @language = language
      end

      def view_template(&block)
        block_content = capture(&block) if block_given?
        # Underline-style tabs: the active trigger gets a 2px primary-colored
        # bottom border that visually replaces the TabsList's bottom border;
        # inactive triggers stay muted with a transparent placeholder border
        # so the height doesn't jump on activation. The TabsList's bg, shadow,
        # and rounded-corners from the base tokens are stripped so the underline
        # reads cleanly.
        trigger_class =
          "rounded-none bg-transparent shadow-none border-b-[3px] border-transparent " \
          "px-4 py-3 -mb-px text-muted-foreground hover:text-foreground " \
          "aria-selected:bg-transparent aria-selected:shadow-none " \
          "aria-selected:border-b-primary aria-selected:text-primary " \
          "aria-selected:font-bold"
        div(class: "my-6 rounded-lg border border-border overflow-hidden") do
          render ::Components::UI::Tabs.new(value: "preview", class: "w-full") do
            render ::Components::UI::TabsList.new(
              class: "rounded-none w-full justify-start gap-4 border-b border-border " \
                     "bg-transparent px-4 h-auto py-0"
            ) do
              render ::Components::UI::TabsTrigger.new(value: "preview", class: trigger_class) { "Preview" }
              render ::Components::UI::TabsTrigger.new(value: "code",    class: trigger_class) { "Code" }
            end
            render ::Components::UI::TabsContent.new(value: "preview", class: "mt-0 p-8 bg-background") do
              # Demos aren't real navigation: site--preview swallows link clicks so a
              # breadcrumb "Home"/pagination/sidebar link doesn't leave the docs page.
              div(data: { controller: "site--preview", action: "click->site--preview#block" }) do
                raw safe(block_content) if block_content
              end
            end
            render ::Components::UI::TabsContent.new(value: "code", class: "mt-0 bg-background") do
              render Components::Site::CodeBlock.new(source: @source, language: @language)
            end
          end
        end
      end
    end
  end
end
