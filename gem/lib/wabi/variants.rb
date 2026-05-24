# frozen_string_literal: true

module Wabi
  # CVA-style variant DSL. Use by extending into a class:
  #
  #   class Button
  #     extend Wabi::Variants
  #     variants do
  #       base "btn"
  #       variant :size, { sm: "h-8", md: "h-10" }, default: :md
  #     end
  #   end
  #
  #   Button.new.tokens(size: :sm) # => "btn h-8"
  module Variants
    def variants(&block)
      definition = Definition.new
      definition.instance_eval(&block)
      @_wabi_variants = definition
      define_method(:tokens) do |**opts|
        self.class.instance_variable_get(:@_wabi_variants).resolve(**opts)
      end
    end

    class Definition
      def initialize
        @base = ""
        @variants = {}
        @defaults = {}
      end

      def base(str)
        @base = str
      end

      def variant(key, options, default: nil)
        @variants[key] = options
        @defaults[key] = default if default
      end

      def resolve(**opts)
        parts = [@base]
        @variants.each do |key, options|
          selected = opts[key] || @defaults[key]
          parts << options[selected] if selected && options[selected]
        end
        parts.compact.reject(&:empty?).join(" ")
      end
    end
  end
end
