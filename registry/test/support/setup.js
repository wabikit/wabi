import { afterEach } from "vitest"
import { stopAll } from "./mount.js"

// Popper-based overlays (popover, tooltip, select, dropdown_menu) start Zag's
// floating-ui positioning on open, which constructs a ResizeObserver. jsdom has
// none, so opening would throw an unhandled rejection. Polyfill a no-op: these
// tests assert wiring, not geometry, so the observer doing nothing is fine.
if (typeof globalThis.ResizeObserver !== "function") {
  globalThis.ResizeObserver = class {
    observe() {}
    unobserve() {}
    disconnect() {}
  }
}

// Global teardown: stop any Stimulus Applications a test started, so controllers
// never leak across test files.
afterEach(() => stopAll())
