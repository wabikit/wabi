# frozen_string_literal: true

require "date"

module Components
  module UI
    class FileUploadList < Wabi::Base
      def initialize(**attrs) = @attrs = attrs

      def view_template
        user_class = @attrs.delete(:class)
        ul(**@attrs, data: { "wabi--file-upload-target": "list" },
           class: merge_class("flex flex-col gap-2 empty:hidden", user_class))
      end
    end
  end
end
