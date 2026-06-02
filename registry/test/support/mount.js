import { Application } from "@hotwired/stimulus"

// Track every Application we start so a global afterEach can stop them all,
// preventing leftover controllers from attaching to later tests' fixtures.
const started = []

export function mount(identifier, ControllerClass, html) {
  document.body.innerHTML = html
  const application = Application.start()
  application.register(identifier, ControllerClass)
  started.push(application)
  return {
    application,
    stop() {
      application.stop()
      const i = started.indexOf(application)
      if (i !== -1) started.splice(i, 1)
      document.body.innerHTML = ""
    },
  }
}

// Stop any Applications still running and clear the DOM. Wired into a global
// afterEach via test/support/setup.js so individual test files don't have to.
export function stopAll() {
  while (started.length) started.pop().stop()
  document.body.innerHTML = ""
}

// Flush microtasks/timers so Stimulus lifecycle callbacks settle.
export const tick = () => new Promise((resolve) => setTimeout(resolve, 0))
