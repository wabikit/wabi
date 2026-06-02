import { describe, it, expect, afterEach } from "vitest"
import Controller from "./toaster_controller.js"
import { mount, tick } from "../../test/support/mount.js"

// mount() leaves each Stimulus Application running; stop the prior one so a
// later test's <ol> doesn't get a controller attached by an earlier app too
// (which would re-register over window.wabiToasters and log a dup-id warning).
let harness
const track = (h) => { harness = h; return h }
afterEach(() => {
  if (harness) { harness.stop(); harness = null }
  delete window.wabiToasters
  delete window.wabiToaster
})

describe("wabi--toaster", () => {
  it("registers itself in window.wabiToasters keyed by id", async () => {
    track(mount("wabi--toaster", Controller, `<ol id="wabi-toaster" data-controller="wabi--toaster"></ol>`))
    await tick()
    expect(window.wabiToasters["wabi-toaster"]).toBeTruthy()
  })

  it("group pointerover from outside expands; pointerout to outside collapses", async () => {
    const h = track(mount("wabi--toaster", Controller, `<ol id="t" data-controller="wabi--toaster"></ol>`))
    await tick()
    const ol = document.getElementById("t")
    const ctrl = h.application.getControllerForElementAndIdentifier(ol, "wabi--toaster")
    // relatedTarget null => not contained by the group => expand
    ol.dispatchEvent(new MouseEvent("pointerover", { bubbles: true, relatedTarget: null }))
    expect(ctrl.expanded).toBe(true)
    ol.dispatchEvent(new MouseEvent("pointerout", { bubbles: true, relatedTarget: null }))
    expect(ctrl.expanded).toBe(false)
  })
})
