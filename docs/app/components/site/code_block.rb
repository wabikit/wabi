# frozen_string_literal: true

require "rouge"

module Components
  module Site
    # Pre + code with Rouge HTML highlighting and a clipboard-copy button.
    # `language:` keys into Rouge::Lexer.find; unknown lexers fall back to
    # PlainText so the page still renders. The raw source (pre-highlight) is
    # passed via a Stimulus String value so the copy controller can hand the
    # untouched text to the clipboard.
    class CodeBlock < Components::Base
      def initialize(source:, language: "ruby")
        @source   = source.to_s
        @language = language.to_s
      end

      def view_template
        lexer       = Rouge::Lexer.find(@language) || Rouge::Lexers::PlainText.new
        formatter   = Rouge::Formatters::HTML.new
        highlighted = formatter.format(lexer.lex(@source))

        div(
          class: "relative my-4 rounded-md border border-border bg-muted text-foreground",
          data: { controller: "site--copy", "site--copy-source-value": @source }
        ) do
          pre(class: "overflow-x-auto p-4 text-sm leading-relaxed") do
            code(class: "font-mono") { raw safe(highlighted) }
          end
          button(
            type: "button",
            class: "absolute right-2 top-2 inline-flex items-center justify-center " \
                   "rounded px-2 py-1 text-xs font-medium border border-input bg-background " \
                   "hover:bg-accent hover:text-accent-foreground",
            data: { action: "click->site--copy#copy", "site--copy-target": "button" }
          ) { "Copy" }
        end
      end
    end
  end
end
