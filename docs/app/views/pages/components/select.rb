# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class Select < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/select.rb
          app/components/ui/select_trigger.rb
          app/components/ui/select_content.rb
          app/components/ui/select_item.rb
          app/components/ui/select_label.rb
          app/components/ui/select_value.rb
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Select", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Select" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add select\nbin/importmap pin @zag-js/select\nbin/importmap pin @zag-js/vanilla",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Pin @zag-js/select and @zag-js/vanilla at version 1.41+ using the +esm jsdelivr URLs — " \
                "bin/importmap pin only downloads the main entry and leaves submodule imports unresolved."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                FRUITS = [
                  { value: "apple",  label: "Apple"  },
                  { value: "banana", label: "Banana" },
                  { value: "cherry", label: "Cherry" },
                ]

                render Components::UI::Select.new(
                  name: "fruit",
                  placeholder: "Choose a fruit",
                  items: FRUITS,
                  class: "w-72"
                ) do
                  render Components::UI::SelectTrigger.new(aria_label: "Choose a fruit") do
                    render Components::UI::SelectValue.new
                  end
                  render Components::UI::SelectContent.new do
                    FRUITS.each do |fruit|
                      render Components::UI::SelectItem.new(value: fruit[:value]) { fruit[:label] }
                    end
                  end
                end
              RUBY
                fruits = [
                  { value: "apple",  label: "Apple"  },
                  { value: "banana", label: "Banana" },
                  { value: "cherry", label: "Cherry" },
                ]
                div(class: "flex justify-center") do
                  render ::Components::UI::Select.new(
                    name: "fruit",
                    placeholder: "Choose a fruit",
                    items: fruits,
                    class: "w-72"
                  ) do
                    render ::Components::UI::SelectTrigger.new(aria_label: "Choose a fruit") do
                      render ::Components::UI::SelectValue.new
                    end
                    render ::Components::UI::SelectContent.new do
                      fruits.each do |fruit|
                        render ::Components::UI::SelectItem.new(value: fruit[:value]) { fruit[:label] }
                      end
                    end
                  end
                end
              end

              h2(id: "disabled", class: "text-2xl font-semibold mt-8 mb-4") { "Disabled" }
              p(class: "text-muted-foreground mb-4 text-sm") do
                plain "Pass "
                code(class: "font-mono text-foreground") { "disabled: true" }
                plain " to disable the whole control, or mark a single entry in "
                code(class: "font-mono text-foreground") { "items:" }
                plain " with "
                code(class: "font-mono text-foreground") { "disabled: true" }
                plain " to skip just that option."
              end
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                PLANS = [
                  { value: "free",  label: "Free"  },
                  { value: "pro",   label: "Pro"   },
                  { value: "team",  label: "Team", disabled: true },
                ]

                # A single disabled option
                render Components::UI::Select.new(
                  name: "plan",
                  placeholder: "Choose a plan",
                  items: PLANS,
                  class: "w-72"
                ) do
                  render Components::UI::SelectTrigger.new(aria_label: "Choose a plan") do
                    render Components::UI::SelectValue.new
                  end
                  render Components::UI::SelectContent.new do
                    PLANS.each do |plan|
                      render Components::UI::SelectItem.new(value: plan[:value]) { plan[:label] }
                    end
                  end
                end

                # The whole control disabled
                render Components::UI::Select.new(
                  name: "plan_locked",
                  placeholder: "Unavailable",
                  items: PLANS,
                  disabled: true,
                  class: "w-72"
                ) do
                  render Components::UI::SelectTrigger.new(aria_label: "Plan (unavailable)") do
                    render Components::UI::SelectValue.new
                  end
                  render Components::UI::SelectContent.new do
                    PLANS.each do |plan|
                      render Components::UI::SelectItem.new(value: plan[:value]) { plan[:label] }
                    end
                  end
                end
              RUBY
                plans = [
                  { value: "free",  label: "Free"  },
                  { value: "pro",   label: "Pro"   },
                  { value: "team",  label: "Team", disabled: true },
                ]
                div(class: "flex flex-col items-center gap-4") do
                  render ::Components::UI::Select.new(
                    name: "plan",
                    placeholder: "Choose a plan",
                    items: plans,
                    class: "w-72"
                  ) do
                    render ::Components::UI::SelectTrigger.new(aria_label: "Choose a plan") do
                      render ::Components::UI::SelectValue.new
                    end
                    render ::Components::UI::SelectContent.new do
                      plans.each do |plan|
                        render ::Components::UI::SelectItem.new(value: plan[:value]) { plan[:label] }
                      end
                    end
                  end

                  render ::Components::UI::Select.new(
                    name: "plan_locked",
                    placeholder: "Unavailable",
                    items: plans,
                    disabled: true,
                    class: "w-72"
                  ) do
                    render ::Components::UI::SelectTrigger.new(aria_label: "Plan (unavailable)") do
                      render ::Components::UI::SelectValue.new
                    end
                    render ::Components::UI::SelectContent.new do
                      plans.each do |plan|
                        render ::Components::UI::SelectItem.new(value: plan[:value]) { plan[:label] }
                      end
                    end
                  end
                end
              end

              h2(id: "source", class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              SOURCE_PATHS.each do |relpath|
                h3(id: "source-#{File.basename(relpath, '.rb')}",
                   class: "text-base font-medium mt-6 mb-2 font-mono") { relpath }
                render ::Components::Site::CodeBlock.new(source: File.read(Rails.root.join(relpath)))
              end

              h2(id: "accessibility", class: "text-2xl font-semibold mt-8 mb-4") { "Accessibility" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li { 'combobox role; trigger announces selected value and "expanded/collapsed" state.' }
                li { "arrow keys navigate options; type-ahead jumps to matching items; Enter selects; Escape closes." }
                li { "focus is trapped inside the listbox while open; first focus lands on selected option." }
                li { "scroll lock prevents background scroll while the listbox is open." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "select", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
