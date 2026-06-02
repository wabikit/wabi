import { describe, it, expect, beforeEach, vi } from "vitest"
import Controller from "./tooltip_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, byTarget, root } from "../../test/support/overlay.js"

// Tooltip opens on pointer/focus after openDelay. We zero the delays via values
// and drive with the real event Zag wires on the trigger (pointermove — focus
// alone does NOT open a tooltip in Zag). Positioning is NOT asserted (jsdom: no
// layout). ResizeObserver is polyfilled in setup.js. jsdom asserts wiring only
// — NOT positioning / focus / scroll-lock.
//
// NOTE: the controller has no isOpen(); state lives in ctrl.openValue (set by
// onOpenChange) and on the content's data-state attribute.
const ID = "wabi--tooltip"

const FIXTURE = `
  <div id="tip" data-controller="wabi--tooltip"
       data-wabi--tooltip-open-delay-value="0" data-wabi--tooltip-close-delay-value="0">
    <button data-wabi--tooltip-target="trigger">Hover me</button>
    <div data-wabi--tooltip-target="positioner">
      <div data-wabi--tooltip-target="content">Tip text</div>
    </div>
  </div>`

// Zag's tooltip opens on pointermove over the trigger (after openDelay). jsdom
// has no PointerEvent constructor; dispatch by event type with a plain Event —
// Zag's onPointerMove handler fires on the "pointermove" type regardless.
function openTooltip(trigger) {
  trigger.dispatchEvent(new Event("pointermove", { bubbles: true }))
}

let harness, ctrl
beforeEach(async () => {
  harness = mount(ID, Controller, FIXTURE)
  await tick()
  ctrl = controllerFor(harness.application, ID, root())
})

describe("wabi--tooltip", () => {
  it("portals content and captures the ref", () => {
    const content = byTarget(ID, "content")
    expect(content.closest("#tip")).toBeNull()
    expect(ctrl.contentEl).toBe(content)
  })

  it("starts closed and openValue false", () => {
    expect(ctrl.openValue).toBe(false)
  })

  it("pointer-over the trigger opens the tooltip (after the zeroed delay)", async () => {
    vi.useFakeTimers()
    openTooltip(byTarget(ID, "trigger"))
    await vi.runAllTimersAsync()
    vi.useRealTimers()
    await tick()

    const content = byTarget(ID, "content")
    expect(content.getAttribute("data-state")).toBe("open")
    expect(content.hasAttribute("inert")).toBe(false)
    expect(ctrl.openValue).toBe(true)
  })

  it("decorates trigger + content and dispatches :change (teeth)", async () => {
    const seen = []
    document.addEventListener("wabi--tooltip:change", (e) => seen.push(e.detail.open))
    const content = byTarget(ID, "content")
    const trigger = byTarget(ID, "trigger")
    expect(content.id).toBeTruthy()

    vi.useFakeTimers()
    openTooltip(trigger)
    await vi.runAllTimersAsync()
    vi.useRealTimers()
    await tick()

    expect(trigger.getAttribute("aria-describedby")).toBe(content.id)
    expect(seen).toContain(true)
  })
})
