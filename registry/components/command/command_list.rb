# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class CommandList < Wabi::Base
      LIST_CLASS = "max-h-80 overflow-y-auto overflow-x-hidden p-1 list-none m-0"

      def initialize(items: [], **attrs)
        @items = items
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)

        groups = @items.group_by { |i| i[:group] || "_default" }

        ul(
          **@attrs,
          data: { "wabi--combobox-target": "content" },
          "data-state": "closed",
          class: merge_class(LIST_CLASS, user_class)
        ) do
          groups.each do |group_name, items|
            if group_name != "_default"
              render Components::UI::CommandGroup.new(heading: group_name) do
                items.each { |item| render Components::UI::CommandItem.new(**item) { item[:label] } }
              end
            else
              items.each { |item| render Components::UI::CommandItem.new(**item) { item[:label] } }
            end
          end
          yield if block_given?  # for CommandEmpty
        end
      end
    end
  end
end
