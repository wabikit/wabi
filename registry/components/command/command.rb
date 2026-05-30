# frozen_string_literal: true

require "date"         # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes
require "securerandom" # UUID generation for unique command-id

module Components
  module UI
    class Command < Wabi::Base
      def initialize(id: nil, **attrs)
        @id    = id || "cmd-#{SecureRandom.uuid}"
        @attrs = attrs
      end

      def view_template(&block)
        user_class = @attrs.delete(:class)
        div(
          **@attrs,
          id: @id,
          data: {
            controller: "wabi--command wabi--dialog",
            "wabi--dialog-modal-value":  "true",
            "wabi--dialog-portal-value": "true",
            "wabi--dialog-open-value":   "false",
            "wabi--command-id": @id,
          },
          class: user_class,
          &block
        )
      end
    end
  end
end
