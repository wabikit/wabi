import { Controller } from "@hotwired/stimulus"

// Pagefind ships pagefind-ui.{js,css} as classic (IIFE) assets that set
// window.PagefindUI rather than ES module exports. We load them once via
// link + script tag injection, wait for the script to fire its 'load'
// event, then mount PagefindUI on this controller's element.
const UI_JS  = "/pagefind/pagefind-ui.js"
const UI_CSS = "/pagefind/pagefind-ui.css"

let pagefindLoader = null

function loadPagefindUI() {
  if (window.PagefindUI) return Promise.resolve(window.PagefindUI)
  pagefindLoader ||= new Promise((resolve, reject) => {
    if (!document.querySelector('link[data-pagefind-ui-css]')) {
      const link = document.createElement("link")
      link.rel = "stylesheet"
      link.href = UI_CSS
      link.dataset.pagefindUiCss = "true"
      document.head.appendChild(link)
    }
    const script = document.createElement("script")
    script.src = UI_JS
    script.async = true
    script.onload  = () => resolve(window.PagefindUI)
    script.onerror = () => reject(new Error("Failed to load " + UI_JS))
    document.head.appendChild(script)
  })
  return pagefindLoader
}

export default class extends Controller {
  async connect() {
    try {
      const PagefindUI = await loadPagefindUI()
      new PagefindUI({
        element: this.element,
        showSubResults: true,
        resetStyles: false,
        // Pagefind builds URLs from file paths under the crawl input dir
        // (e.g. docs/components/button.html). Our routes are clean — no
        // .html suffix — so strip it before display. /index → /.
        processResult: (result) => {
          if (!result.url) return result
          result.url = result.url
            .replace(/\.html$/, "")
            .replace(/\/index$/, "/")
            .replace(/^\/$/, "/")
          if (result.url === "") result.url = "/"
          return result
        },
      })
    } catch (err) {
      console.error("[site--search] PagefindUI failed to load:", err)
    }
  }
}
