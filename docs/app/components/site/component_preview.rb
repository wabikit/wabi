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
        div(class: "my-6 rounded-lg border border-border overflow-hidden") do
          render ::Components::UI::Tabs.new(value: "preview", class: "w-full") do
            render ::Components::UI::TabsList.new(
              class: "rounded-none w-full justify-start gap-1 border-b border-border " \
                     "bg-muted/30 px-2 h-auto py-2"
            ) do
              render ::Components::UI::TabsTrigger.new(value: "preview", class: "cursor-pointer") { "Preview" }
              render ::Components::UI::TabsTrigger.new(value: "code",    class: "cursor-pointer") { "Code" }
            end
            render ::Components::UI::TabsContent.new(value: "preview", class: "mt-0 p-8 bg-background") do
              raw safe(block_content) if block_content
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
