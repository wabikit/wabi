import { describe, it, expect, beforeEach } from "vitest"
import Controller from "./hover_card_controller.js"
import { mount, tick } from "../../test/support/mount.js"
import { byTarget, root } from "../../test/support/overlay.js"

const ID = "wabi--hover-card"

const FIXTURE = `
  <div id="hc" data-controller="wabi--hover-card"
       data-wabi--hover-card-open-delay-value="700"
       data-wabi--hover-card-portal-value="false">
    <button type="button" data-wabi--hover-card-target="trigger">@wabi</button>
    <div data-wabi--hover-card-target="positioner">
      <div data-wabi--hover-card-target="content" data-state="closed" inert>Card body</div>
    </div>
  </div>`

describe("wabi--hover-card", () => {
  beforeEach(async () => {
    mount(ID, Controller, FIXTURE)
    await tick()
  })

  it("spreads trigger props (data-state) onto the trigger element", () => {
    const trigger = byTarget(ID, "trigger")
    expect(trigger.hasAttribute("data-state")).toBe(true)
  })

  it("sets content.hidden = false after connect", () => {
    const content = byTarget(ID, "content")
    expect(content.hidden).toBe(false)
  })

  it("sets aria-expanded=false on the trigger when card is closed", () => {
    const trigger = byTarget(ID, "trigger")
    expect(trigger.getAttribute("aria-expanded")).toBe("false")
  })
})
