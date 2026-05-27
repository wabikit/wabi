# frozen_string_literal: true

require "wabi/turbo_stream_extensions"

RSpec.describe "Wabi::TurboStreamExtensions" do
  let(:builder) do
    klass = Class.new do
      include Wabi::TurboStreamExtensions
      def append(*); raise "should not be called for create-style"; end
    end
    klass.new
  end

  before do
    def builder.turbo_stream_action_tag(action, **attrs)
      attrs_str = attrs.map { |k, v| %(#{k.to_s.tr("_", "-")}="#{v}") }.join(" ")
      %(<turbo-stream action="#{action}" #{attrs_str}></turbo-stream>)
    end
  end

  it "emits a wabi_toast_create stream with a JSON payload attribute" do
    output = builder.wabi_toast(title: "Saved", description: "Done.", appearance: :success)
    expect(output).to include('action="wabi_toast_create"')
    expect(output).to match(/data-payload="(.+?)"/)
    payload = JSON.parse(output.match(/data-payload="(.+?)"/)[1].gsub(/&quot;/, '"'))
    expect(payload).to include(
      "title" => "Saved",
      "description" => "Done.",
      "type" => "success",
    )
  end

  it "maps appearance: :destructive to type: 'error'" do
    output = builder.wabi_toast(title: "Boom", appearance: :destructive)
    payload = JSON.parse(output.match(/data-payload="(.+?)"/)[1].gsub(/&quot;/, '"'))
    expect(payload["type"]).to eq("error")
  end

  it "defaults type to 'info' when appearance not given" do
    output = builder.wabi_toast(title: "Hi")
    payload = JSON.parse(output.match(/data-payload="(.+?)"/)[1].gsub(/&quot;/, '"'))
    expect(payload["type"]).to eq("info")
  end
end
