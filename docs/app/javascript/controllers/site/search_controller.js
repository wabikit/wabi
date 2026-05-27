// docs/app/javascript/controllers/site/search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  async connect() {
    // Inject the Pagefind UI stylesheet once
    if (!document.querySelector('link[data-pagefind-ui-css]')) {
      const link = document.createElement("link")
      link.rel = "stylesheet"
      link.href = "/pagefind/pagefind-ui.css"
      link.dataset.pagefindUiCss = "true"
      document.head.appendChild(link)
    }

    // Dynamically import the UI bundle
    const { PagefindUI } = await import("/pagefind/pagefind-ui.js")
    new PagefindUI({
      element: this.element,
      showSubResults: true,
      resetStyles: false,
    })
  }
}
