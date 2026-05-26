# frozen_string_literal: true

module Wabi
  # Extends `Turbo::Streams::TagBuilder` with a `wabi_toast` shorthand that
  # appends a server-rendered Toast component into the singleton Toaster
  # container.
  #
  # In a Rails controller / Turbo Stream view:
  #
  #   render turbo_stream: turbo_stream.wabi_toast(
  #     title: "Saved",
  #     description: "Profile updated.",
  #     appearance: :success,
  #   )
  #
  # Equivalent to:
  #
  #   render turbo_stream: turbo_stream.append(
  #     "wabi-toaster",
  #     Components::UI::Toast.new(title: "Saved", description: "...", appearance: :success),
  #   )
  #
  # The user app must have run `bin/rails g wabi:add toast` first so that
  # `Components::UI::Toast` is defined.
  #
  # NOTE: this module is named `Wabi::TurboStreamExtensions` (NOT
  # `Wabi::Rails::TurboStreamExtensions`) because nesting a `Rails` module
  # inside `Wabi` shadows the top-level `Rails` constant from generators that
  # reference `Rails::Generators::Base`, breaking gem load order.
  module TurboStreamExtensions
    def wabi_toast(toaster_id: "wabi-toaster", **toast_options)
      toast_class = wabi_resolve_toast_class
      append(toaster_id, toast_class.new(**toast_options))
    end

    private

    def wabi_resolve_toast_class
      Object.const_get("Components::UI::Toast")
    rescue NameError
      raise NameError,
            "Components::UI::Toast is not defined. Run `bin/rails g wabi:add toast` " \
            "to install the component before using `turbo_stream.wabi_toast(...)`."
    end
  end
end

# Inject into Turbo's tag builder when Turbo is loaded. Gated so the gem stays
# usable in non-Turbo Rails apps and in pure-Ruby specs.
if defined?(::Turbo::Streams::TagBuilder)
  ::Turbo::Streams::TagBuilder.include(Wabi::TurboStreamExtensions)
end
