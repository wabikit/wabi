# frozen_string_literal: true

module Views
  module Pages
    module Docs
      class Philosophy < Views::Base
        def view_template
          render ::Components::Site::Layout.new(title: "Philosophy", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              h1(class: "text-4xl font-bold mb-4") { "Philosophy" }
              p(class: "text-muted-foreground mb-8") do
                "Why Wabi works the way it does, and where it fits in the Rails ecosystem."
              end

              h2(class: "text-2xl font-semibold mt-8 mb-3") { "You own the code" }
              p(class: "text-sm mb-3 leading-relaxed") do
                "Wabi components are not imported from a node_modules-equivalent. " \
                "When you run `bin/rails g wabi:add button`, the Phlex source is COPIED into " \
                "`app/components/ui/button.rb`. You can edit it, refactor it, fork it. There is " \
                "no upstream API for it to drift away from, because the upstream is now you."
              end
              p(class: "text-sm mb-3 leading-relaxed") do
                "This trade-off is deliberate. The cost is no automatic component upgrades when " \
                "Wabi ships v0.3 — your existing components don't move. The benefit is that " \
                "customization is the default mode rather than an escape hatch."
              end

              h2(class: "text-2xl font-semibold mt-8 mb-3") { "Phlex-native, not ERB-wrapped" }
              p(class: "text-sm mb-3 leading-relaxed") do
                "Phlex components are Ruby classes. Composition is method dispatch. " \
                "Variants are class-method DSLs. Inheritance is real inheritance. " \
                "This trades a bit of newcomer friction for a model that scales like the rest of " \
                "your Rails app."
              end

              h2(class: "text-2xl font-semibold mt-8 mb-3") { "Accessible by default, not retrofitted" }
              p(class: "text-sm mb-3 leading-relaxed") do
                "Every interactive component wires through @zag-js state machines, which carry " \
                "WAI-ARIA roles, keyboard semantics, and focus management baked in. Overlays toggle " \
                "the inert attribute when closed so they stay out of tab order and the accessibility " \
                "tree. The goal is WCAG-AA out of the box for every component shipping."
              end

              h2(class: "text-2xl font-semibold mt-8 mb-3") { "Brand-neutral" }
              p(class: "text-sm mb-3 leading-relaxed") do
                "Wabi ships 8 palettes with carefully chosen accent colors and neutral grayscales. " \
                "No single one is the \"Wabi look\" — pick the one closest to your brand, or edit " \
                "the HSL values directly. The visual identity is the user's, not ours."
              end

              h2(class: "text-2xl font-semibold mt-8 mb-3") { "Hotwire and Turbo-friendly" }
              p(class: "text-sm mb-3 leading-relaxed") do
                "Stimulus controllers wrap the Zag state machines so they survive Turbo navigation. " \
                "The Toast component ships a `turbo_stream.wabi_toast` action helper so server-side " \
                "code can spawn notifications without round-tripping the page. Wabi is opinionated " \
                "about working with Rails, not around it."
              end
            end
          end
        end
      end
    end
  end
end
