# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class DatePicker < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/calendar.rb
          app/components/ui/date_picker.rb
          app/components/ui/date_picker_view.rb
          app/javascript/controllers/wabi/date_picker_controller.js
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Date Picker", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Date Picker" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add date_picker\n" \
                        "bin/importmap pin @zag-js/date-picker @internationalized/date @zag-js/vanilla",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Pin @zag-js/date-picker, @internationalized/date and @zag-js/vanilla at 1.41+ using the " \
                "+esm jsdelivr URLs — bin/importmap pin only fetches the main entry and leaves submodules unresolved."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::DatePicker.new(name: "event[date]", placeholder: "Pick a date")
              RUBY
                render ::Components::UI::DatePicker.new(name: "event[date]", placeholder: "Pick a date")
              end

              h2(id: "range", class: "text-2xl font-semibold mt-8 mb-4") { "Range" }
              p(class: "text-muted-foreground mb-4 text-sm") do
                "Pass selection_mode: :range. Pick the start day, navigate with the arrows if needed, then pick the end day. "
                plain "Submits booking[stay][start] and booking[stay][end]."
              end
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::DatePicker.new(name: "booking[stay]", selection_mode: :range, placeholder: "Check-in → Check-out")
              RUBY
                render ::Components::UI::DatePicker.new(name: "booking[stay]", selection_mode: :range, placeholder: "Check-in → Check-out")
              end

              h2(id: "inline", class: "text-2xl font-semibold mt-8 mb-4") { "Inline calendar" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::Calendar.new(name: "event[date]", default_value: "2026-06-15")
              RUBY
                render ::Components::UI::Calendar.new(name: "event[date]", default_value: "2026-06-15")
              end

              h2(id: "source", class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              SOURCE_PATHS.each do |relpath|
                h3(id: "source-#{File.basename(relpath, '.rb')}", class: "text-base font-medium mt-6 mb-2 font-mono") { relpath }
                render ::Components::Site::CodeBlock.new(source: File.read(Rails.root.join(relpath)))
              end

              h2(id: "accessibility", class: "text-2xl font-semibold mt-8 mb-4") { "Accessibility" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li { "The day grid uses Zag's grid roles; arrow keys move between days, Enter selects." }
                li { "Prev/next buttons and day cells carry accessible labels derived from the locale." }
                li { "The field input has an accessible name (aria-label, default \"Choose date\", overridable); the popover is keyboard-dismissable (Escape)." }
                li { "Selection is mirrored into hidden inputs as ISO YYYY-MM-DD, so forms submit a value." }
                li { "Single-month view; range selection spans months via prev/next navigation." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "date_picker", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
