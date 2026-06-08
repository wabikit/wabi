# frozen_string_literal: true

require "wabi"
require_relative "file_upload"
require_relative "file_upload_dropzone"
require_relative "file_upload_trigger"
require_relative "file_upload_list"

RSpec.describe "FileUpload" do
  it "wires the controller + core data-values on the root" do
    out = Components::UI::FileUpload.new(name: "post[avatar]").call
    expect(out).to include('data-controller="wabi--file-upload"')
    expect(out).to include('data-wabi--file-upload-name-value="post[avatar]"')
    expect(out).to include('data-wabi--file-upload-max-files-value="1"')
  end

  it "renders a real hidden file input (single)" do
    out = Components::UI::FileUpload.new(name: "post[avatar]").call
    expect(out).to match(/<input[^>]*type="file"[^>]*name="post\[avatar\]"[^>]*data-wabi--file-upload-target="hiddenInput"/)
    expect(out).not_to include(' multiple')
  end

  it "makes name end with [] and sets multiple when max_files > 1" do
    out = Components::UI::FileUpload.new(name: "post[images]", max_files: 5).call
    expect(out).to include('name="post[images][]"')
    expect(out).to include("multiple")
    expect(out).to include('data-wabi--file-upload-max-files-value="5"')
  end

  it "reflects accept + max_size + disabled" do
    out = Components::UI::FileUpload.new(name: "f", accept: "image/*", max_size: 1048576, disabled: true).call
    expect(out).to include('data-wabi--file-upload-accept-value="image/*"')
    expect(out).to include('data-wabi--file-upload-max-size-value="1048576"')
    expect(out).to include('data-wabi--file-upload-disabled-value="true"')
  end

  it "Dropzone + Trigger + List render with their targets" do
    expect(Components::UI::FileUploadDropzone.new.call { "" }).to include('data-wabi--file-upload-target="dropzone"')
    expect(Components::UI::FileUploadTrigger.new.call { "Browse" }).to include('data-wabi--file-upload-target="trigger"')
    expect(Components::UI::FileUploadList.new.call).to include('data-wabi--file-upload-target="list"')
  end

  # a11y regressions — WCAG-AA fixes
  it "FileUploadList has aria-live=polite and aria-atomic=false (live-region announcement)" do
    out = Components::UI::FileUploadList.new.call
    expect(out).to include('aria-live="polite"')
    expect(out).to include('aria-atomic="false"')
  end

  it "composes" do
    composed = Class.new(Phlex::HTML) do
      def view_template
        render Components::UI::FileUpload.new(name: "f") do
          render Components::UI::FileUploadDropzone.new do
            render Components::UI::FileUploadTrigger.new { "Browse files" }
          end
          render Components::UI::FileUploadList.new
        end
      end
    end.new.call
    expect(composed).to include('data-controller="wabi--file-upload"')
    expect(composed).to include('data-wabi--file-upload-target="dropzone"')
    expect(composed).to include('data-wabi--file-upload-target="list"')
  end
end
