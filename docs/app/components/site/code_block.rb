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
      COPY_ICON_SVG = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" ' \
                      'stroke="currentColor" stroke-width="2" stroke-linecap="round" ' \
                      'stroke-linejoin="round" aria-hidden="true">' \
                      '<rect x="9" y="9" width="13" height="13" rx="2" ry="2"/>' \
                      '<path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>'

      CHECK_ICON_SVG = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" ' \
                       'stroke="currentColor" stroke-width="2" stroke-linecap="round" ' \
                       'stroke-linejoin="round" aria-hidden="true">' \
                       '<polyline points="20 6 9 17 4 12"/></svg>'

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
          # `pr-12` reserves the column under the absolute-positioned copy
          # button so long code lines scroll horizontally WITHOUT sliding
          # under it. `overflow-x-auto` keeps the rest of the line clipped
          # to the visible area.
          pre(class: "overflow-x-auto p-4 pr-12 text-sm leading-relaxed") do
            code(class: "font-mono") { raw safe(highlighted) }
          end
          button(
            type: "button",
            "aria-label": "Copy code to clipboard",
            class: "absolute right-2 top-2 inline-flex items-center justify-center " \
                   "h-7 w-7 rounded border border-input bg-background text-muted-foreground " \
                   "hover:bg-accent hover:text-accent-foreground",
            data: { action: "click->site--copy#copy" }
          ) do
            span(data: { "site--copy-target": "copyIcon" }, class: "inline-flex") do
              raw safe(COPY_ICON_SVG)
            end
            span(
              data: { "site--copy-target": "checkIcon" },
              class: "hidden text-primary"
            ) do
              raw safe(CHECK_ICON_SVG)
            end
          end
        end
      end
    end
  end
end
