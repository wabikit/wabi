import { describe, it, expect, beforeEach } from "vitest"
import * as menu from "@zag-js/menu"
import { normalizeProps } from "@zag-js/vanilla"
import Controller from "./context_menu_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { controllerFor, byTarget, root } from "../../test/support/overlay.js"

// The context_menu controller owns the parent Zag menu machine (and a child
// per `sub` boundary — none here). We assert: open/close state + inert + :change;
// the checkbox option-item toggles data-wabi-checked via onSelect→handleOptionToggle
// (controller bookkeeping Zag doesn't own) + the :select dispatch; role=menu.
// The menu opens on right-click (contextmenu event) instead of a left-click.
// jsdom asserts wiring only — NOT positioning / focus / scroll-lock.
const ID = "wabi--context-menu"

const FIXTURE = `
  <div id="cm" data-controller="wabi--context-menu">
    <button data-wabi--context-menu-target="trigger">Right-click me</button>
    <div data-wabi--context-menu-target="positioner">
      <div data-wabi--context-menu-target="content">
        <div data-wabi--context-menu-target="item" data-wabi-value="edit">Edit</div>
        <div data-wabi--context-menu-target="optionItem"
             data-wabi-value="grid" data-wabi-type="checkbox" data-wabi-checked="false">
          <span data-wabi--context-menu-target="optionItemIndicator">✓</span>
          Show grid
        </div>
      </div>
    </div>
  </div>`

let harness, ctrl
beforeEach(async () => {
  harness = mount(ID, Controller, FIXTURE)
  await tick()
  ctrl = controllerFor(harness.application, ID, root())
})

describe("wabi--context-menu", () => {
  it("portals content + captures item/optionItem refs", () => {
    expect(byTarget(ID, "content").closest("#cm")).toBeNull()
    expect(ctrl.itemEls.length).toBe(1)
    expect(ctrl.optionItemEls.length).toBe(1)
  })

  it("starts closed, opens on contextmenu event, dispatches :change (teeth)", async () => {
    const seen = []
    document.addEventListener("wabi--context-menu:change", (e) => seen.push(e.detail.open))
    const content = byTarget(ID, "content")
    expect(content.getAttribute("data-state")).toBe("closed")
    openMenu(ctrl)
    await tick()
    expect(content.getAttribute("data-state")).toBe("open")
    expect(content.hasAttribute("inert")).toBe(false)
    expect(seen).toContain(true)
  })

  it("selecting the checkbox option toggles data-wabi-checked and dispatches :select", async () => {
    const seen = []
    document.addEventListener("wabi--context-menu:select", (e) => seen.push(e.detail.value))
    const opt = ctrl.optionItemEls[0]
    expect(opt.dataset.wabiChecked).toBe("false")
    await selectMenuValue(ctrl, "grid")
    expect(seen).toContain("grid")
    expect(opt.dataset.wabiChecked).toBe("true")
    expect(ctrl.optionItemIndicatorEls[0].hidden).toBe(false)
  })

  it("content carries role=menu decoration", () => {
    expect(byTarget(ID, "content").getAttribute("role")).toBe("menu")
  })
})

function api(ctrl) {
  return menu.connect(ctrl.machine.service, normalizeProps)
}

// Context menu opens via right-click (contextmenu event). We dispatch the real
// event so getContextTriggerProps.onContextMenu fires and sends CONTEXT_MENU
// to the Zag machine — no machine stubbing.
function openMenu(ctrl) {
  ctrl.triggerEl.dispatchEvent(
    new MouseEvent("contextmenu", { bubbles: true, cancelable: true, clientX: 100, clientY: 100 })
  )
}

// Discovered mechanism: the menu api has no direct selectValue, and a bare
// option-item .click() only highlights it (ITEM_CLICK's fallback branch).
// onSelect fires only when the item is the highlighted one, so we: open the
// menu, highlight the value, THEN dispatch the real click that Zag wired via
// getOptionItemProps.onClick → ITEM_CLICK → invokeOnSelect.
async function selectMenuValue(ctrl, value) {
  const a = api(ctrl)
  a.setOpen(true)
  await tick()
  a.setHighlightedValue(value)
  await tick()
  const opt = ctrl.optionItemEls.find((el) => el.dataset.wabiValue === value)
  opt.click()
  await tick()
}
