# frozen_string_literal: true

require "date" # Phlex 2.4 references Date/Time constants lazily when rendering data:{} hashes

module Components
  module UI
    # Wrapper over Rails' form_with. Yields the form builder so apps continue
    # using Rails form helpers (form.email_field, form.text_area, etc.) for
    # idiomatic ActiveModel/ActiveRecord integration.
    #
    # Requires a Rails view context — uses the Phlex::Rails::Helpers::FormWith
    # adapter (the recommended pattern in phlex-rails 2.4+).
    class Form < Wabi::Base
      include Phlex::Rails::Helpers::FormWith if defined?(Phlex::Rails::Helpers::FormWith)

      def initialize(model: nil, url: nil, scope: nil, **opts)
        @model = model
        @url   = url
        @scope = scope
        @opts  = opts
      end

      def view_template(&block)
        user_class = @opts.delete(:class)
        form_with(
          model: @model, url: @url, scope: @scope, **@opts,
          class: merge_class("space-y-6", user_class)
        ) do |form|
          yield(form) if block_given?
        end
      end
    end
  end
end
