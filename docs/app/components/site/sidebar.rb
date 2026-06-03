# frozen_string_literal: true

module Components
  module Site
    class Sidebar < Components::Base
      COMPONENT_LINK = ->(slug) {
        { name: slug.split("_").map(&:capitalize).join(" "), path: "/docs/components/#{slug}" }
      }

      GROUPS = [
        { label: "Getting Started", items: [
          { name: "Introduction", path: "/docs/getting-started" },
          { name: "Theming",      path: "/docs/theming" },
          { name: "Philosophy",   path: "/docs/philosophy" },
        ]},
        { label: "Forms", items: %w[button checkbox combobox form input label number_input radio_group select slider switch textarea toggle toggle_group].map(&COMPONENT_LINK) },
        { label: "Layout & Display", items: %w[alert avatar badge card separator table skeleton data_table sidebar].map(&COMPONENT_LINK) },
        { label: "Overlays", items: %w[alert_dialog command dialog drawer popover tooltip].map(&COMPONENT_LINK) },
        { label: "Menus", items: [{ name: "Dropdown Menu", path: "/docs/components/dropdown_menu" }] },
        { label: "Navigation", items: %w[accordion tabs breadcrumb pagination].map(&COMPONENT_LINK) },
        { label: "Feedback", items: [{ name: "Toast", path: "/docs/components/toast" }, { name: "Progress", path: "/docs/components/progress" }] },
      ].freeze

      def initialize(current_path:)
        @current_path = current_path
      end

      def view_template
        aside(
          data: { controller: "site--sidebar-scroll" },
          class: "sidebar-mobile-target hidden lg:block w-56 flex-shrink-0 border-r border-border " \
                 "h-[calc(100vh-3.5rem)] sticky top-14 overflow-y-auto py-6 px-4"
        ) do
          GROUPS.each do |group|
            render Components::Site::Sidebar::Group.new(
              label: group[:label], items: group[:items], current_path: @current_path
            )
          end
        end
      end
    end
  end
end
