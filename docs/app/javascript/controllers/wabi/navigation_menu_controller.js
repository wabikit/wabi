import { Controller } from "@hotwired/stimulus"
import * as navigationMenu from "@zag-js/navigation-menu"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["list", "item", "trigger", "content", "link"]
  static values  = {
    orientation: { type: String, default: "horizontal" },
  }

  connect() {
    this.machine = new VanillaMachine(navigationMenu.machine, {
      id: this.element.id || crypto.randomUUID(),
      orientation: this.orientationValue,
      onValueChange: ({ value }) => this.dispatch("change", { detail: { value } }),
    })
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    this.render()
  }

  disconnect() {
    this.unsubscribe?.()
    this.machine?.stop()
  }

  render() {
    const api = navigationMenu.connect(this.machine.service, normalizeProps)
    spreadProps(this.element, api.getRootProps())
    if (this.hasListTarget) spreadProps(this.listTarget, api.getListProps())

    this.itemTargets.forEach((el)    => spreadProps(el, api.getItemProps({ value: el.dataset.wabiValue })))
    this.triggerTargets.forEach((el) => spreadProps(el, api.getTriggerProps({ value: el.dataset.wabiValue })))
    this.linkTargets.forEach((el)    => spreadProps(el, api.getLinkProps({ value: el.dataset.wabiValue })))
    this.contentTargets.forEach((el) => {
      spreadProps(el, api.getContentProps({ value: el.dataset.wabiValue }))
      // Keep rendered for the fade, but make closed panels inert so their links
      // leave the tab order and a11y tree (inert implies aria-hidden). Matches
      // the popover/overlay pattern; opacity-0 alone does not remove focusability.
      const open = el.getAttribute("data-state") === "open"
      el.hidden = false
      if (open) el.removeAttribute("inert")
      else      el.setAttribute("inert", "")
    })
  }
}
