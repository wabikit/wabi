# frozen_string_literal: true

RSpec.describe Wabi::TurboStreamExtensions do
  # Minimal stand-in for Turbo::Streams::TagBuilder — records append calls so
  # we can assert that wabi_toast routes to the correct Toaster target.
  let(:builder) do
    b = Class.new do
      attr_reader :appends
      def initialize = @appends = []
      def append(target, content) = @appends << [target, content]
    end.new
    b.extend(Wabi::TurboStreamExtensions)
    b
  end

  before do
    stub_const("Components::UI::Toast", Class.new do
      def initialize(**opts) = @opts = opts
      def to_s = "[FakeToast #{@opts.inspect}]"
    end)
  end

  it "defaults to the singleton 'wabi-toaster' target" do
    builder.wabi_toast(title: "Saved")
    target, content = builder.appends.first
    expect(target).to eq("wabi-toaster")
    # Guards against passing the wrong thing to append (e.g. the class).
    expect(content).to be_a(Components::UI::Toast)
  end

  it "accepts toaster_id: to target a specific Toaster instance" do
    builder.wabi_toast(toaster_id: "alerts", title: "Saved")
    target, content = builder.appends.first
    expect(target).to eq("alerts")
    expect(content).to be_a(Components::UI::Toast)
  end

  it "raises a clear NameError when Components::UI::Toast is undefined" do
    hide_const("Components::UI::Toast")
    expect { builder.wabi_toast(title: "x") }.to raise_error(NameError, /wabi:add toast/)
  end
end
