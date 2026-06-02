import { Controller } from "@hotwired/stimulus"

// Wabi theme controller — toggles data-mode on <html>, persists to localStorage,
// respects prefers-color-scheme on first load.
export default class extends Controller {
  static values = {
    themeKey: { type: String, default: "wabi-theme" },
    modeKey:  { type: String, default: "wabi-mode" },
  }

  connect() {
    const html = document.documentElement
    // Honor the server-rendered data-theme/data-mode before falling back, so a
    // single-theme (or non-"default") install isn't clobbered to "default" on
    // hydration when localStorage is empty. Precedence: user choice (localStorage)
    // → server-rendered value → sensible default.
    const storedTheme = localStorage.getItem(this.themeKeyValue) || html.dataset.theme || "default"
    const storedMode  = localStorage.getItem(this.modeKeyValue) || html.dataset.mode || this.systemMode()
    html.dataset.theme = storedTheme
    html.dataset.mode  = storedMode
  }

  toggleMode() {
    const html = document.documentElement
    const next = html.dataset.mode === "dark" ? "light" : "dark"
    html.dataset.mode = next
    localStorage.setItem(this.modeKeyValue, next)
    this.dispatch("change", { detail: { mode: next } })
  }

  setTheme(event) {
    const theme = event.params.theme
    document.documentElement.dataset.theme = theme
    localStorage.setItem(this.themeKeyValue, theme)
    this.dispatch("change", { detail: { theme } })
  }

  systemMode() {
    return window.matchMedia?.("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }
}
