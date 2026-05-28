import { Controller } from "@hotwired/stimulus"
import * as combobox from "@zag-js/combobox"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["label", "control", "input", "trigger", "positioner", "content", "item", "itemIndicator", "hiddenInput"]
  static values  = {
    name:        String,
    items:       Array,
    value:       String,
    placeholder: { type: String,  default: "Select an option..." },
    disabled:    { type: Boolean, default: false },
    portal:      { type: Boolean, default: true  },
  }

  connect() {
    // Capture refs BEFORE portal move (Sprint 9 trap).
    this.contentEl    = this.hasContentTarget    ? this.contentTarget    : null
    this.positionerEl = this.hasPositionerTarget ? this.positionerTarget : null

    // In-content targets need capture before move (Sprint 9 trap).
    this.itemEls = this.contentEl
      ? Array.from(this.contentEl.querySelectorAll('[data-wabi--combobox-target="item"]'))
      : []

    this.originalParents = {
      positioner: this.positionerEl?.parentNode,
    }

    this.portaled = this.portalValue
    if (this.portaled) this.attachToBody()

    const items = this.itemsValue
    const collection = combobox.collection({
      items,
      itemToString: (item) => item.label,
      itemToValue:  (item) => item.value,
    })

    this.machine = new VanillaMachine(combobox.machine, {
      id: this.element.id || crypto.randomUUID(),
      collection,
      // Intentionally NOT passing `name` to the machine. Zag would forward it to
      // the visible <input>, which then submits the LABEL ("Ruby on Rails")
      // instead of the VALUE ("rails"). We mirror the value to a hidden input
      // on every change for form submission instead.
      defaultValue: this.valueValue ? [this.valueValue] : undefined,
      disabled: this.disabledValue,
      placeholder: this.placeholderValue,
      onValueChange: ({ value }) => {
        this.valueValue = value[0] || ""
        if (this.hasHiddenInputTarget) this.hiddenInputTarget.value = this.valueValue
        this.dispatch("change", { detail: { value: value[0] } })
      },
      onOpenChange: ({ open }) => {
        if (this.contentEl) {
          if (open) this.contentEl.removeAttribute("inert")
          else      this.contentEl.setAttribute("inert", "")
        }
      },
    })
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    this.render()
  }

  disconnect() {
    this.unsubscribe?.()
    this.machine?.stop()
    if (this.portaled) this.restoreFromBody()
  }

  attachToBody() {
    if (this.positionerEl && this.positionerEl.parentNode !== document.body) {
      document.body.appendChild(this.positionerEl)
    }
  }

  restoreFromBody() {
    if (this.positionerEl && this.originalParents.positioner) {
      this.originalParents.positioner.appendChild(this.positionerEl)
    }
  }

  render() {
    const api = combobox.connect(this.machine.service, normalizeProps)
    spreadProps(this.element, api.getRootProps())

    if (this.hasLabelTarget)    spreadProps(this.labelTarget,    api.getLabelProps())
    if (this.hasControlTarget)  spreadProps(this.controlTarget,  api.getControlProps())
    if (this.hasInputTarget)    spreadProps(this.inputTarget,    api.getInputProps())
    if (this.hasTriggerTarget)  spreadProps(this.triggerTarget,  api.getTriggerProps())
    if (this.positionerEl)      spreadProps(this.positionerEl,   api.getPositionerProps())
    if (this.contentEl) {
      spreadProps(this.contentEl, api.getContentProps())
      this.contentEl.hidden = false
    }

    this.itemEls.forEach((el) => {
      const value = el.dataset.wabiValue
      const item  = this.itemsValue.find((i) => i.value === value)
      if (item) spreadProps(el, api.getItemProps({ item }))
    })
  }
}
