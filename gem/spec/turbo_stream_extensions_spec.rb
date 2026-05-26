# frozen_string_literal: true

require "wabi/turbo_stream_extensions"

RSpec.describe Wabi::TurboStreamExtensions do
  let(:fake_toast_class) do
    Class.new do
      attr_reader :options
      def initialize(**options) = (@options = options)
      def call = "<li>fake</li>"
    end
  end

  let(:tag_builder_class) do
    Class.new do
      include Wabi::TurboStreamExtensions

      attr_reader :appended_target, :appended_content

      def append(target, content)
        @appended_target  = target
        @appended_content = content
      end
    end
  end

  let(:tag_builder) { tag_builder_class.new }

  before { stub_const("Components::UI::Toast", fake_toast_class) }

  it "appends to #wabi-toaster by default" do
    tag_builder.wabi_toast(title: "Hi")
    expect(tag_builder.appended_target).to eq("wabi-toaster")
  end

  it "supports a custom toaster_id" do
    tag_builder.wabi_toast(toaster_id: "my-toaster", title: "Hi")
    expect(tag_builder.appended_target).to eq("my-toaster")
  end

  it "instantiates Components::UI::Toast with the passed options" do
    tag_builder.wabi_toast(title: "Saved", appearance: :success, description: "Done")
    expect(tag_builder.appended_content).to be_a(fake_toast_class)
    expect(tag_builder.appended_content.options).to eq(
      title: "Saved", appearance: :success, description: "Done"
    )
  end

  it "raises a helpful NameError when the Toast component isn't installed" do
    hide_const("Components::UI::Toast")
    expect { tag_builder.wabi_toast(title: "Hi") }
      .to raise_error(NameError, /wabi:add toast/)
  end
end
