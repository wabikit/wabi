# frozen_string_literal: true

require "wabi/base"

RSpec.describe Wabi::Base do
  it "inherits from Phlex::HTML" do
    expect(Wabi::Base.ancestors).to include(Phlex::HTML)
  end

  it "can be subclassed and renders HTML" do
    klass = Class.new(Wabi::Base) do
      def view_template
        button(class: "btn") { "Hi" }
      end
    end

    output = klass.new.call
    expect(output).to include('<button class="btn">Hi</button>')
  end

  it "subclasses get the variants DSL automatically" do
    klass = Class.new(Wabi::Base) do
      variants do
        base "inline-flex"
        variant :size, { sm: "h-8", md: "h-10" }, default: :md
      end

      def view_template
        button(class: tokens(size: :sm)) { "x" }
      end
    end

    output = klass.new.call
    expect(output).to include('class="inline-flex h-8"')
  end

  describe "#merge_class" do
    it "merges user-supplied class with internal tokens" do
      klass = Class.new(Wabi::Base) do
        variants do
          base "btn"
          variant :size, { sm: "h-8" }, default: :sm
        end

        def initialize(class: nil) = @user_class = binding.local_variable_get(:class)

        def view_template
          button(class: merge_class(tokens, @user_class)) { "x" }
        end
      end

      output = klass.new(class: "h-12 shadow").call
      # User's h-12 overrides base h-8, shadow is preserved
      expect(output).to include('class="btn h-12 shadow"')
    end
  end
end
