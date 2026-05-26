import { Controller } from "@hotwired/stimulus"
import * as popover from "@zag-js/popover"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["trigger", "positioner", "content", "closeTrigger"]
  static values  = {
    open:  { type: Boolean, default: false },
    modal: { type: Boolean, default: false },
  }

  connect() {
    this.machine = new VanillaMachine(popover.machine, {
      id: this.element.id || crypto.randomUUID(),
      // `defaultOpen` keeps the open bindable uncontrolled so the machine can
      // toggle it on trigger click / Escape / click-outside.
      defaultOpen: this.openValue,
      modal: this.modalValue,
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
    const api = popover.connect(this.machine.service, normalizeProps)
    if (this.hasTriggerTarget)    spreadProps(this.triggerTarget,    api.getTriggerProps())
    if (this.hasPositionerTarget) spreadProps(this.positionerTarget, api.getPositionerProps())
    if (this.hasContentTarget)    spreadProps(this.contentTarget,    api.getContentProps())
    this.closeTriggerTargets.forEach((el) => spreadProps(el, api.getCloseTriggerProps()))
  }
}
