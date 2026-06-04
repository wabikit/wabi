import { Controller } from "@hotwired/stimulus"

// Docs-only controller for the Sidebar example. The demo's menu items don't
// navigate (they're buttons, no href), so this moves the active state to the
// clicked item on the fly — no page reload. Real apps mark the active item
// server-side via aria-current on the link matching the current route.
//
// Wired on the SidebarMenu with `data-action="click->demo--sidebar-nav#select"`;
// it relies on event bubbling, so it needs no per-item targets.
export default class extends Controller {
  select(event) {
    // The nearest clicked menu/submenu control. A <summary> (the collapsible
    // disclosure) is neither <a> nor <button>, so clicks on it return null here
    // and just toggle the <details> natively — they don't change the active item.
    const item = event.target.closest("a, button")
    if (!item || !this.element.contains(item)) return

    this.element
      .querySelectorAll('[aria-current="page"]')
      .forEach((el) => el.removeAttribute("aria-current"))
    item.setAttribute("aria-current", "page")
  }
}
