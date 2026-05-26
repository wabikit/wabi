import { Controller } from "@hotwired/stimulus"
import * as menu from "@zag-js/menu"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["trigger", "positioner", "content", "item"]
  static values  = {
    open: { type: Boolean, default: false },
  }

  connect() {
    this.machine = new VanillaMachine(menu.machine, {
      id: this.element.id || crypto.randomUUID(),
      // `defaultOpen` keeps the open bindable uncontrolled so the machine can
      // toggle on trigger click / Escape / click-outside.
      defaultOpen: this.openValue,
      onSelect: ({ value }) => {
        this.dispatch("select", { detail: { value } })
      },
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
    const api = menu.connect(this.machine.service, normalizeProps)
    if (this.hasTriggerTarget)    spreadProps(this.triggerTarget,    api.getTriggerProps())
    if (this.hasPositionerTarget) spreadProps(this.positionerTarget, api.getPositionerProps())
    if (this.hasContentTarget)    spreadProps(this.contentTarget,    api.getContentProps())

    // Per-item props (data-highlighted, role, click handlers, onSelect dispatch).
    this.itemTargets.forEach((el) => {
      spreadProps(el, api.getItemProps({
        value: el.dataset.wabiValue,
        disabled: el.dataset.wabiDisabled === "true",
      }))
    })
  }
}
