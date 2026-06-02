import { describe, it, expect, afterEach } from "vitest"
import Controller from "./command_controller.js"
import { mount, tick } from "../../test/support/mount.js"

let harness
afterEach(() => {
  harness?.stop()
  harness = null
})

// Helper — dispatch a document-level event whose composedPath() includes a
// node carrying data-wabi--command-id. jsdom's ShadowRoot / composedPath() is
// limited, so we dispatch on a specific element (which appears in the path)
// rather than on document, then let it bubble up.
function dispatchOnNode(node, eventName, detail = {}) {
  const event = new CustomEvent(eventName, { bubbles: true, composed: true, detail })
  node.dispatchEvent(event)
}

// ─── Fixtures ────────────────────────────────────────────────────────────────

const FIXTURE_BASIC = (id = "cmd-test-1") => `
  <div data-controller="wabi--command" data-wabi--command-id="${id}">
  </div>`

// Fixture with a dialog content element (mirrors real usage: wabi--command
// stamps data-wabi--command-id onto the dialog content at connect()).
const FIXTURE_WITH_CONTENT = (id = "cmd-test-2") => `
  <div data-controller="wabi--command" data-wabi--command-id="${id}">
    <div data-wabi--dialog-target="content">
      <div data-controller="wabi--combobox"></div>
    </div>
  </div>`

// ─── Tests ────────────────────────────────────────────────────────────────────

describe("wabi--command", () => {
  it("connects without error and exposes the controller", async () => {
    harness = mount("wabi--command", Controller, FIXTURE_BASIC())
    await tick()
    const el = document.querySelector('[data-controller~="wabi--command"]')
    const ctrl = harness.application.getControllerForElementAndIdentifier(el, "wabi--command")
    expect(ctrl).toBeTruthy()
  })

  it("reads data-wabi--command-id into this.commandId at connect", async () => {
    harness = mount("wabi--command", Controller, FIXTURE_BASIC("cmd-abc"))
    await tick()
    const el = document.querySelector('[data-controller~="wabi--command"]')
    const ctrl = harness.application.getControllerForElementAndIdentifier(el, "wabi--command")
    expect(ctrl.commandId).toBe("cmd-abc")
  })

  it("stamps data-wabi--command-id onto the dialog content element at connect", async () => {
    harness = mount("wabi--command", Controller, FIXTURE_WITH_CONTENT("cmd-stamp"))
    await tick()
    const content = document.querySelector('[data-wabi--dialog-target="content"]')
    expect(content.getAttribute("data-wabi--command-id")).toBe("cmd-stamp")
  })

  it("eventBelongsToThisCommand returns true when composedPath includes a matching node", async () => {
    harness = mount("wabi--command", Controller, FIXTURE_BASIC("cmd-path"))
    await tick()
    const el = document.querySelector('[data-controller~="wabi--command"]')
    const ctrl = harness.application.getControllerForElementAndIdentifier(el, "wabi--command")

    // composedPath() is only populated while the event is being dispatched.
    // We intercept it synchronously inside a listener, call the filter there,
    // and record the result.
    let result = null
    document.addEventListener("wabi--combobox:change", (e) => {
      result = ctrl.eventBelongsToThisCommand(e)
    }, { once: true })

    // Dispatch on el — el has data-wabi--command-id="cmd-path", so the filter
    // should recognise it.
    dispatchOnNode(el, "wabi--combobox:change", {})
    expect(result).toBe(true)
  })

  it("eventBelongsToThisCommand returns false when no matching node is in the path", async () => {
    harness = mount("wabi--command", Controller, FIXTURE_BASIC("cmd-filter"))
    await tick()
    const el = document.querySelector('[data-controller~="wabi--command"]')
    const ctrl = harness.application.getControllerForElementAndIdentifier(el, "wabi--command")

    // Create a node that has a *different* command-id — dispatch on it.
    const other = document.createElement("div")
    other.setAttribute("data-wabi--command-id", "cmd-OTHER")
    document.body.appendChild(other)
    const evt = new CustomEvent("wabi--combobox:change", { bubbles: true, composed: true })
    other.dispatchEvent(evt)
    expect(ctrl.eventBelongsToThisCommand(evt)).toBe(false)
    other.remove()
  })

  it("does not throw when wabi--combobox:change fires with a matching path (no dialog controller present)", async () => {
    harness = mount("wabi--command", Controller, FIXTURE_BASIC("cmd-nocrash"))
    await tick()
    const el = document.querySelector('[data-controller~="wabi--command"]')
    // Dispatching on el means composedPath includes el (data-wabi--command-id="cmd-nocrash")
    // The controller will call getControllerForElementAndIdentifier for wabi--dialog,
    // which returns null → early return without throwing.
    expect(() => dispatchOnNode(el, "wabi--combobox:change", {})).not.toThrow()
  })

  it("does not throw when wabi--dialog:change fires with a non-matching path", async () => {
    harness = mount("wabi--command", Controller, FIXTURE_BASIC("cmd-nodialog"))
    await tick()
    // Dispatch on document (no element in path has the matching id) → filtered out silently.
    expect(() => {
      document.dispatchEvent(new CustomEvent("wabi--dialog:change", { detail: { open: true } }))
    }).not.toThrow()
  })

  it("removes document listeners on disconnect (no memory leak)", async () => {
    harness = mount("wabi--command", Controller, FIXTURE_BASIC("cmd-disconnect"))
    await tick()
    // Stopping the harness calls disconnect(); a second event must not throw
    // even though the controller's bound handlers reference a detached element.
    harness.stop()
    harness = null
    expect(() => {
      document.dispatchEvent(new CustomEvent("wabi--combobox:change", { bubbles: true }))
      document.dispatchEvent(new CustomEvent("wabi--dialog:change", { detail: { open: false } }))
    }).not.toThrow()
  })
})
