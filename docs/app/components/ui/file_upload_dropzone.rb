# frozen_string_literal: true

require "date"

module Components
  module UI
    class FileUploadDropzone < Wabi::Base
      def initialize(**attrs) = @attrs = attrs

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(**@attrs, data: { "wabi--file-upload-target": "dropzone" },
            class: merge_class(
              "flex flex-col items-center justify-center gap-2 rounded-lg border-2 border-dashed " \
              "border-input bg-background px-6 py-10 text-center text-sm text-muted-foreground " \
              "transition-colors motion-reduce:transition-none cursor-pointer data-[dragging]:border-ring data-[dragging]:bg-accent",
              user_class)) do
          yield if block
        end
      end
    end
  end
end
