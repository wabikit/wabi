import { Controller } from "@hotwired/stimulus"

// Component previews are demos, not real navigation. Swallow clicks on links
// inside a preview so e.g. a breadcrumb "Home" or a pagination page doesn't
// yank the reader off the docs page. Buttons and triggers (dialog, toast,
// menus, …) are left untouched, so interactive demos still work.
export default class extends Controller {
  block(event) {
    const link = event.target.closest("a[href]")
    if (link && this.element.contains(link)) event.preventDefault()
  }
}
