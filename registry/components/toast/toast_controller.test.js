import { describe, it, expect, beforeEach, afterEach, vi } from "vitest"
import Controller from "./toast_controller.js"
import { mount, tick } from "../../test/support/mount.js"

const TOAST = (duration = 5000) => `
  <li data-controller="wabi--toast"
      data-wabi--toast-duration-ms-value="${duration}"
      data-state="open">
    <button data-action="click->wabi--toast#dismiss">x</button>
  </li>`

// mount() starts a fresh Stimulus Application each call but never stops the
// prior one. Left running, every still-live Application attaches its own
// controller instance to the next test's element -- so a single <li> ends up
// with several wabi--toast controllers, each with its own dismiss timer. The
// extra (unreferenced) instances then auto-dismiss the element out from under
// the controller we hold(). Stop each app in afterEach to keep tests isolated.
let harness
const track = (h) => { harness = h; return h }

beforeEach(() => {
  vi.stubGlobal("requestAnimationFrame", (cb) => { cb(0); return 0 })
  vi.useFakeTimers({ toFake: ["setTimeout", "clearTimeout", "Date"] })
})
afterEach(() => {
  if (harness) { harness.stop(); harness = null }
  vi.useRealTimers()
  vi.unstubAllGlobals()
})

const el = () => document.querySelector('[data-controller~="wabi--toast"]')

// Stimulus' connect runs on a MutationObserver microtask, not a fake timer, so
// flushing real microtasks (Promise.resolve) is enough to let connect() run.
// We can't `await tick()` (a real setTimeout(0)) because fake timers intercept
// it and it never fires.
const flush = () => Promise.resolve().then(() => Promise.resolve())

describe("wabi--toast", () => {
  it("enters: flips data-state to open", async () => {
    track(mount("wabi--toast", Controller, TOAST()))
    await flush()
    expect(el().dataset.state).toBe("open")
  })

  it("auto-dismisses after durationMs (removes the element)", async () => {
    track(mount("wabi--toast", Controller, TOAST(5000)))
    await flush()
    expect(el()).not.toBeNull()
    vi.advanceTimersByTime(5000) // dismiss() fires
    vi.advanceTimersByTime(400)  // 350ms safety setTimeout removes element
    expect(el()).toBeNull()
  })

  it("sticky (duration <= 0) never auto-dismisses", async () => {
    track(mount("wabi--toast", Controller, TOAST(0)))
    await flush()
    vi.advanceTimersByTime(60000)
    expect(el()).not.toBeNull()
  })

  it("hold() pauses the timer; release() resumes it", async () => {
    const h = track(mount("wabi--toast", Controller, TOAST(5000)))
    await flush()
    const ctrl = h.application.getControllerForElementAndIdentifier(el(), "wabi--toast")
    vi.advanceTimersByTime(2000) // 3000ms remaining
    ctrl.hold()
    vi.advanceTimersByTime(10000) // paused: still here
    expect(el()).not.toBeNull()
    ctrl.release() // resumes with 3000ms remaining
    vi.advanceTimersByTime(3000 + 400) // dismiss + safety
    expect(el()).toBeNull()
  })
})
