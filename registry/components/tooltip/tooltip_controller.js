import { Controller } from "@hotwired/stimulus"
import * as tooltip from "@zag-js/tooltip"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["trigger", "positioner", "content"]
  static values  = {
    openDelay:  { type: Number, default: 700 },
    closeDelay: { type: Number, default: 300 },
    open:       { type: Boolean, default: false },
  }

  connect() {
    this.machine = new VanillaMachine(tooltip.machine, {
      id: this.element.id || crypto.randomUUID(),
      // `defaultOpen` keeps the bindable uncontrolled so hover/focus toggle it.
      defaultOpen: this.openValue,
      openDelay:   this.openDelayValue,
      closeDelay:  this.closeDelayValue,
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
    const api = tooltip.connect(this.machine.service, normalizeProps)
    if (this.hasTriggerTarget)    spreadProps(this.triggerTarget,    api.getTriggerProps())
    if (this.hasPositionerTarget) spreadProps(this.positionerTarget, api.getPositionerProps())
    if (this.hasContentTarget)    spreadProps(this.contentTarget,    api.getContentProps())
  }
}
