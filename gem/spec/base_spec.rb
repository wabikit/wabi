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
end
