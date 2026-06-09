# frozen_string_literal: true

require "yaml"

module Views
  module Pages
    module Components
      class FileUpload < Views::Base
        SOURCE_PATHS = %w[
          app/components/ui/file_upload.rb
          app/components/ui/file_upload_dropzone.rb
          app/components/ui/file_upload_trigger.rb
          app/components/ui/file_upload_list.rb
          app/javascript/controllers/wabi/file_upload_controller.js
        ].freeze

        def view_template
          render ::Components::Site::Layout.new(title: "File Upload", chrome: :full) do
            main(class: "container mx-auto py-12 px-4 max-w-3xl") do
              p(class: "text-sm text-muted-foreground mb-2") do
                a(href: "/docs/components", class: "hover:text-foreground") { "← Components" }
              end
              h1(class: "text-4xl font-bold mb-2") { "File Upload" }
              p(class: "text-muted-foreground mb-8") { description }

              h2(id: "installation", class: "text-2xl font-semibold mt-8 mb-4") { "Installation" }
              render ::Components::Site::CodeBlock.new(
                source: "bin/rails g wabi:add file_upload\n" \
                        "bin/importmap pin @zag-js/file-upload @zag-js/vanilla",
                language: "shell"
              )
              p(class: "text-sm text-muted-foreground mt-2") do
                "Pin @zag-js/file-upload and @zag-js/vanilla at 1.41+ using the +esm jsdelivr URLs — " \
                "bin/importmap pin only fetches the main entry and leaves submodules unresolved."
              end

              h2(id: "example", class: "text-2xl font-semibold mt-8 mb-4") { "Example" }
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::FileUpload.new(name: "post[avatar]") do
                  render Components::UI::FileUploadDropzone.new do
                    plain "Drag a file here, or "
                    render Components::UI::FileUploadTrigger.new { "browse" }
                  end
                  render Components::UI::FileUploadList.new
                end
              RUBY
                render ::Components::UI::FileUpload.new(name: "post[avatar]") do
                  render ::Components::UI::FileUploadDropzone.new do
                    plain "Drag a file here, or "
                    render ::Components::UI::FileUploadTrigger.new { "browse" }
                  end
                  render ::Components::UI::FileUploadList.new
                end
              end

              h2(id: "multiple-images", class: "text-2xl font-semibold mt-8 mb-4") { "Multiple / images" }
              p(class: "text-muted-foreground mb-4 text-sm") do
                "Pass max_files: to allow multiple selections (the field name gains [] automatically) " \
                "and accept: to restrict by MIME type or extension."
              end
              render ::Components::Site::ComponentPreview.new(source: <<~RUBY) do
                render Components::UI::FileUpload.new(name: "post[images]", max_files: 5, accept: "image/*") do
                  render Components::UI::FileUploadDropzone.new do
                    plain "Drag images here, or "
                    render Components::UI::FileUploadTrigger.new { "browse" }
                  end
                  render Components::UI::FileUploadList.new
                end
              RUBY
                render ::Components::UI::FileUpload.new(name: "post[images]", max_files: 5, accept: "image/*") do
                  render ::Components::UI::FileUploadDropzone.new do
                    plain "Drag images here, or "
                    render ::Components::UI::FileUploadTrigger.new { "browse" }
                  end
                  render ::Components::UI::FileUploadList.new
                end
              end

              h2(id: "source", class: "text-2xl font-semibold mt-8 mb-4") { "Source" }
              SOURCE_PATHS.each do |relpath|
                h3(id: "source-#{File.basename(relpath, '.rb')}", class: "text-base font-medium mt-6 mb-2 font-mono") { relpath }
                render ::Components::Site::CodeBlock.new(source: File.read(Rails.root.join(relpath)))
              end

              h2(id: "accessibility", class: "text-2xl font-semibold mt-8 mb-4") { "Accessibility" }
              ul(class: "list-disc pl-5 space-y-1 text-sm text-muted-foreground") do
                li { "The dropzone has role=\"button\" with tabindex=0 and opens the file picker on Enter or Space." }
                li { "Drag state is reflected via data-[dragging] on the dropzone for visual feedback." }
                li { "The underlying <input type=\"file\"> is tabindex=-1 and aria-hidden (out of the tab order and the accessibility tree); the dropzone and the Browse button are the accessible surfaces." }
                li { "File list renders accepted files; each entry can expose a remove button wired to the controller." }
                li { "max_files > 1 automatically appends [] to the field name and enables the multiple attribute." }
                li { "The dropzone is keyboard-focusable and contains the browse button (Zag's file-upload structure); automated tools may flag this as nested-interactive, but both the dropzone (drag/drop + Enter/Space) and the button are independently operable." }
              end
            end
          end
        end

        private

        def description
          @description ||= YAML.safe_load_file(
            Rails.root.join("..", "registry", "components", "file_upload", "manifest.yml").realpath
          )["description"]
        end
      end
    end
  end
end
