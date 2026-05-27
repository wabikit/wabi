# frozen_string_literal: true

require "json"

module Wabi
  # Extends `Turbo::Streams::TagBuilder` with a `wabi_toast` shorthand that
  # emits a `wabi_toast_create` custom Turbo Stream action. The Toaster's
  # Stimulus controller listens on `turbo:before-stream-render`, intercepts
  # the action, and routes the payload through the Zag group machine's
  # `create()` API.
  #
  # In a Rails controller / Turbo Stream view:
  #
  #   render turbo_stream: turbo_stream.wabi_toast(
  #     title: "Saved",
  #     description: "Profile updated.",
  #     appearance: :success,
  #   )
  #
  # The user app must have run `bin/rails g wabi:add toast` first so that
  # the Toaster controller is registered on the page.
  #
  # NOTE: this module is named `Wabi::TurboStreamExtensions` (NOT
  # `Wabi::Rails::TurboStreamExtensions`) because nesting a `Rails` module
  # inside `Wabi` shadows the top-level `Rails` constant from generators that
  # reference `Rails::Generators::Base`, breaking gem load order.
  module TurboStreamExtensions
    APPEARANCE_TO_TYPE = {
      success:     "success",
      destructive: "error",
      info:        "info",
    }.freeze

    def wabi_toast(toaster_id: "wabi-toaster", title:, description: nil, appearance: :info, **extra)
      type = APPEARANCE_TO_TYPE[appearance] || appearance.to_s
      payload = { "title" => title, "description" => description, "type" => type }.merge(extra)
      payload_json = JSON.generate(payload).gsub('"', "&quot;")
      turbo_stream_action_tag("wabi_toast_create", target: toaster_id, data_payload: payload_json)
    end
  end
end

# Inject into Turbo's tag builder when Turbo is loaded. Gated so the gem stays
# usable in non-Turbo Rails apps and in pure-Ruby specs.
if defined?(::Turbo::Streams::TagBuilder)
  ::Turbo::Streams::TagBuilder.include(Wabi::TurboStreamExtensions)
end
