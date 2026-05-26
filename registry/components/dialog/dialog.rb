# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    class Dialog < Wabi::Base
      def initialize(id: nil, open: false, modal: true, **attrs)
        @id    = id
        @open  = open
        @modal = modal
        @attrs = attrs
      end

      def view_template(&block)
        div(
          id: @id,
          data: {
            controller: "wabi--dialog",
            # `.to_s` matters for Stimulus Boolean values -- a bare boolean true
            # serializes to a value-less attribute `data-...-value`, which
            # Stimulus then parses as the string "" and treats as `false`.
            # Emitting "true"/"false" strings makes the value type roundtrip.
            "wabi--dialog-open-value":  @open.to_s,
            "wabi--dialog-modal-value": @modal.to_s,
          }
        ) do
          yield if block_given?
        end
      end
    end
  end
end
