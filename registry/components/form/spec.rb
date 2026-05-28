# frozen_string_literal: true

require "wabi"
require_relative "form"
require_relative "form_field"
require_relative "form_label"
require_relative "form_description"
require_relative "form_message"

# FakeModel mimics ActiveModel just enough for FormMessage to read .errors.
FakeErrors = Struct.new(:hash) do
  def [](field) = hash[field] || []
  def any?      = hash.any?
end

FakeModel = Struct.new(:attrs, :errors_hash) do
  def errors = FakeErrors.new(errors_hash || {})
end

RSpec.describe "Form composition" do
  describe Components::UI::FormField do
    it "renders a div with space-y-2 class" do
      output = described_class.new.call { "child" }
      expect(output).to include('<div')
      expect(output).to include('space-y-2')
      expect(output).to include('child')
    end
  end

  describe Components::UI::FormLabel do
    it "renders a <label> with the form-label classes" do
      output = described_class.new(for_: "user_email").call { "Email" }
      expect(output).to include('<label')
      expect(output).to include('for="user_email"')
      expect(output).to include('text-sm')
      expect(output).to include("Email")
    end
  end

  describe Components::UI::FormDescription do
    it "renders a <p> with muted text class" do
      output = described_class.new.call { "Help text" }
      expect(output).to include('<p')
      expect(output).to include('text-muted-foreground')
      expect(output).to include("Help text")
    end
  end

  describe Components::UI::FormMessage do
    it "renders nothing when there is no error and no explicit text" do
      model = FakeModel.new({}, { email: [] })
      output = described_class.new(model: model, field: :email).call
      expect(output).to eq("")
    end

    it "renders the first error message when present" do
      model = FakeModel.new({}, { email: ["cannot be blank", "invalid format"] })
      output = described_class.new(model: model, field: :email).call
      expect(output).to include("cannot be blank")
      expect(output).not_to include("invalid format")
      expect(output).to include('text-destructive')
    end

    it "renders explicit text when given, overriding model lookup" do
      model = FakeModel.new({}, { email: ["model error"] })
      output = described_class.new(model: model, field: :email, text: "Forced").call
      expect(output).to include("Forced")
      expect(output).not_to include("model error")
    end

    it "renders explicit text without any model" do
      output = described_class.new(text: "Standalone error").call
      expect(output).to include("Standalone error")
    end
  end
end
