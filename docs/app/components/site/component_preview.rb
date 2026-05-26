# frozen_string_literal: true

module Components
  module Site
    # Tabbed Preview / Code view around a single example. The block passed to
    # the component is the live render (used for the Preview tab); the
    # `source:` kwarg is the literal Ruby/HTML text shown via CodeBlock in
    # the Code tab. Callers MUST keep both in sync -- there's no automatic
    # extraction. (A v0.4 cleanup could template the live block back through
    # an Inspector-like API, but the duplication is acceptable for v0.3.)
    class ComponentPreview < Components::Base
      def initialize(source:, language: "ruby")
        @source   = source
        @language = language
      end

      def view_template(&block)
        div(
          class: "my-6 rounded-lg border border-border overflow-hidden",
          data: { controller: "site--preview-tabs" }
        ) do
          div(class: "flex items-center gap-1 border-b border-border px-2 py-2 bg-muted/30") do
            button(
              type: "button",
              class: "px-3 py-1.5 text-sm font-medium rounded data-[active=true]:bg-background " \
                     "data-[active=true]:shadow-sm",
              "data-active": "true",
              data: {
                action: "click->site--preview-tabs#show",
                "site--preview-tabs-tab-param": "preview",
              }
            ) { "Preview" }
            button(
              type: "button",
              class: "px-3 py-1.5 text-sm font-medium rounded data-[active=true]:bg-background " \
                     "data-[active=true]:shadow-sm",
              "data-active": "false",
              data: {
                action: "click->site--preview-tabs#show",
                "site--preview-tabs-tab-param": "code",
              }
            ) { "Code" }
          end
          div(
            class: "p-8 bg-background",
            data: { "site--preview-tabs-target": "preview" }
          ) do
            yield if block_given?
          end
          div(
            class: "bg-background",
            data: { "site--preview-tabs-target": "code" },
            hidden: true
          ) do
            render Components::Site::CodeBlock.new(source: @source, language: @language)
          end
        end
      end
    end
  end
end
