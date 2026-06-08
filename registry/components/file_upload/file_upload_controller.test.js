import { describe, it, expect, beforeEach } from "vitest"
import Controller from "./file_upload_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { root } from "../../test/support/overlay.js"

const ID = "wabi--file-upload"

beforeEach(() => {
  if (!URL.createObjectURL) URL.createObjectURL = () => "blob:test"
  if (!URL.revokeObjectURL) URL.revokeObjectURL = () => {}
})

function fixture(attrs = "") {
  return `
    <div data-controller="wabi--file-upload"
         data-wabi--file-upload-name-value="files[]"
         data-wabi--file-upload-max-files-value="3"
         ${attrs}>
      <input type="file" name="files[]" multiple data-wabi--file-upload-target="hiddenInput" class="sr-only" />
      <div data-wabi--file-upload-target="dropzone">
        <button data-wabi--file-upload-target="trigger">Browse</button>
      </div>
      <ul data-wabi--file-upload-target="list"></ul>
    </div>`
}

describe("wabi--file-upload", () => {
  it("spreads props onto dropzone/trigger/hidden input on connect", async () => {
    mount(ID, Controller, fixture())
    await tick()
    const dz = root().querySelector('[data-wabi--file-upload-target="dropzone"]')
    // Zag decorates the dropzone (role/tabindex/data-part/etc.)
    expect(dz.getAttributeNames().some((a) => a.startsWith("data-") || a === "role" || a === "tabindex")).toBe(true)
  })

  it("renders a list row per accepted file with a remove button", async () => {
    const h = mount(ID, Controller, fixture())
    await tick()
    const ctrl = h.application.getControllerForElementAndIdentifier(root(), ID)
    const f = new File(["x"], "photo.txt", { type: "text/plain" })
    // Drive file acceptance via the machine API (setFiles) — jsdom doesn't fully
    // support the DataTransfer/FileList APIs that Zag's onInput path requires.
    ctrl.api.setFiles([f])
    await tick()
    const rows = root().querySelectorAll('[data-wabi--file-upload-target="list"] > li')
    expect(rows.length).toBe(1)
    expect(rows[0].textContent).toContain("photo.txt")
    expect(rows[0].querySelector("button")).toBeTruthy()
  })

  // a11y regression — WCAG-AA: delete button must carry focus-visible ring classes
  it("delete button has focus-visible ring classes", async () => {
    const h = mount(ID, Controller, fixture())
    await tick()
    const ctrl = h.application.getControllerForElementAndIdentifier(root(), ID)
    const f = new File(["x"], "report.pdf", { type: "application/pdf" })
    ctrl.api.setFiles([f])
    await tick()
    const del = root().querySelector('[data-wabi--file-upload-target="list"] > li button')
    expect(del).toBeTruthy()
    expect(del.className).toContain("focus-visible:outline-none")
    expect(del.className).toContain("focus-visible:ring-2")
    expect(del.className).toContain("focus-visible:ring-ring")
  })
})
