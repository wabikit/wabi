# frozen_string_literal: true

require "date"

module Components
  module UI
    class FileUpload < Wabi::Base
      def initialize(name:, accept: nil, max_files: 1, max_size: nil, disabled: false, **attrs)
        @name      = name
        @accept    = accept
        @max_files = max_files
        @max_size  = max_size
        @disabled  = disabled
        @attrs     = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        user_data  = @attrs.delete(:data) || {}
        multiple   = @max_files > 1
        field_name = multiple && !@name.end_with?("[]") ? "#{@name}[]" : @name
        root_data = {
          controller: "wabi--file-upload",
          "wabi--file-upload-name-value":      field_name,
          "wabi--file-upload-accept-value":    @accept.to_s,
          "wabi--file-upload-max-files-value": @max_files.to_s,
          "wabi--file-upload-max-size-value":  @max_size.to_s,
          "wabi--file-upload-disabled-value":  @disabled.to_s,
        }
        div(**@attrs, data: user_data.merge(root_data),
            class: merge_class("flex flex-col gap-3", user_class)) do
          input(type: "file", name: field_name, multiple: (multiple || nil),
                data: { "wabi--file-upload-target": "hiddenInput" }, class: "sr-only")
          yield if block
        end
      end
    end
  end
end
