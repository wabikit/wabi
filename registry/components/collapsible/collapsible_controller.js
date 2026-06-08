import { Controller } from "@hotwired/stimulus"
import * as collapsible from "@zag-js/collapsible"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["trigger", "content"]
  static values  = {
    open:     { type: Boolean, default: false },
    disabled: { type: Boolean, default: false },
  }

  connect() {
    this.machine = new VanillaMachine(collapsible.machine, {
      id: this.element.id || crypto.randomUUID(),
      defaultOpen: this.openValue,
      disabled: this.disabledValue,
      onOpenChange: ({ open }) => {
        this.openValue = open
        this.dispatch("change", { detail: { open } })
      },
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
    const api = collapsible.connect(this.machine.service, normalizeProps)
    spreadProps(this.element, api.getRootProps())
    if (this.hasTriggerTarget) spreadProps(this.triggerTarget, api.getTriggerProps())
    if (this.hasContentTarget) {
      spreadProps(this.contentTarget, api.getContentProps())
      this.contentTarget.hidden = false
      // Zag nulls data-state once open + settled (skip = !initial && open) because
      // its canonical animation keys off the --height var. Our grid-rows transition
      // needs data-state to PERSIST as "open" while open, so re-assert it from api.open.
      this.contentTarget.setAttribute("data-state", api.open ? "open" : "closed")
    }
  }
}
