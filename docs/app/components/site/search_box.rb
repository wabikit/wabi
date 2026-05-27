# frozen_string_literal: true

module Components
  module Site
    class SearchBox < Components::Base
      def view_template
        div(id: "search", class: "w-64", data: { controller: "site--search" })
      end
    end
  end
end
