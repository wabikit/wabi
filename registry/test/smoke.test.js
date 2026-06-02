import { describe, it, expect } from "vitest"
import { Controller } from "@hotwired/stimulus"
import { mount, tick } from "./support/mount.js"

describe("test harness", () => {
  it("connects a Stimulus controller in jsdom", async () => {
    let connected = false
    class Probe extends Controller {
      connect() { connected = true }
    }
    const h = mount("probe", Probe, `<div data-controller="probe"></div>`)
    await tick()
    expect(connected).toBe(true)
    h.stop()
  })
})
