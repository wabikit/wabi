# frozen_string_literal: true

require "date"

module Components
  module UI
    class FileUploadTrigger < Wabi::Base
      def initialize(**attrs) = @attrs = attrs

      def view_template(&block)
        user_class = @attrs.delete(:class)
        button(type: "button", **@attrs, data: { "wabi--file-upload-target": "trigger" },
               class: merge_class(
                 "inline-flex h-9 items-center justify-center rounded-md border border-input bg-background " \
                 "px-4 text-sm font-medium shadow-sm transition-colors motion-reduce:transition-none hover:bg-accent hover:text-accent-foreground " \
                 "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
                 user_class)) do
          yield if block
        end
      end
    end
  end
end
