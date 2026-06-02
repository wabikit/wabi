import { Application } from "@hotwired/stimulus"

// Mount a controller against a DOM fixture using a real Stimulus Application.
// Returns the application + a stop(). Call `await tick()` after mounting so
// Stimulus' connect (a MutationObserver microtask) has run.
export function mount(identifier, ControllerClass, html) {
  document.body.innerHTML = html
  const application = Application.start()
  application.register(identifier, ControllerClass)
  return {
    application,
    stop() {
      application.stop()
      document.body.innerHTML = ""
    },
  }
}

// Flush microtasks/timers so Stimulus lifecycle callbacks settle.
export const tick = () => new Promise((resolve) => setTimeout(resolve, 0))
