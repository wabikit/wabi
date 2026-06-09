# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class TreeView < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/tree_view.rb
        ].freeze

        TREE = [
          { value: "src", label: "src", icon: "folder", children: [
            { value: "app.rb", label: "app.rb", icon: "file" },
            { value: "lib", label: "lib", icon: "folder", children: [
              { value: "util.rb", label: "util.rb", icon: "file" }
            ] }
          ] },
          { value: "README", label: "README.md", icon: "file" }
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "Tree View", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "Tree View" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add tree_view\nbin/importmap pin @zag-js/tree-view\nbin/importmap pin @zag-js/collection\nbin/importmap pin @zag-js/vanilla",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Pin @zag-js/tree-view, @zag-js/collection, and @zag-js/vanilla at version 1.41+ using the +esm jsdelivr URLs — " \
                "bin/importmap pin only downloads the main entry and leaves submodule imports unresolved."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::TreeView.new(
                  label: "Files",
                  default_expanded: ["src"],
                  items: [
                    { value: "src", label: "src", icon: "folder", children: [
                      { value: "app.rb", label: "app.rb", icon: "file" },
                      { value: "lib", label: "lib", icon: "folder", children: [
                        { value: "util.rb", label: "util.rb", icon: "file" }
                      ] }
                    ] },
                    { value: "README", label: "README.md", icon: "file" }
                  ]
                )
              RUBY
                render ::Components::UI::TreeView.new(label: "Files", default_expanded: ["src"], items: TREE)
              end

              h2(id: "source", class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              SOURCE_PATHS.each do |relpath|
                h3(id: "source-#{File.basename(relpath, '.rb')}", class: "text-base font-medium mt-6 mb-2 font-mono") { relpath }
                render ::Components::Site::CodeBlock.new(source: File.read(Rails.root.join(relpath)))
              end

              h2(id: "accessibility", class: "text-2xl font-semibold mt-8 mb-4") { "Accessibility" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li { "Full keyboard navigation: arrow keys move focus and expand/collapse, typeahead jumps to a node by typing." }
                li { "Nodes expose treeitem roles with aria-selected / aria-expanded; set selection_mode: :multiple for multi-select." }
                li { "Set with_checkboxes: true to add per-node tri-state checkboxes." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "tree_view", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
