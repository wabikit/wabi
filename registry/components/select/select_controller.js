import { Controller } from "@hotwired/stimulus"
import * as select from "@zag-js/select"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = [
    "trigger", "indicator", "valueText",
    "positioner", "content", "list", "item", "itemIndicator", "itemText",
    "hiddenSelect",
  ]
  static values  = {
    items:       Array,                                       // [{ value, label }, ...]
    name:        String,
    value:       String,
    disabled:    { type: Boolean, default: false },
    placeholder: { type: String,  default: "Select an option" },
    portal:      { type: Boolean, default: true },
  }

  connect() {
    this.contentEl    = this.hasContentTarget    ? this.contentTarget    : null
    this.positionerEl = this.hasPositionerTarget ? this.positionerTarget : null

    // In-content targets captured before move. trigger/indicator/valueText/
    // hiddenSelect live OUTSIDE content (in the trigger area) and stay in
    // Stimulus scope, so we keep using *Target lookups for those.
    this.listEl           = this.contentEl?.querySelector('[data-wabi--select-target="list"]') || null
    this.itemEls          = this.contentEl ? Array.from(this.contentEl.querySelectorAll('[data-wabi--select-target="item"]')) : []
    this.itemIndicatorEls = this.contentEl ? Array.from(this.contentEl.querySelectorAll('[data-wabi--select-target="itemIndicator"]')) : []
    this.itemTextEls      = this.contentEl ? Array.from(this.contentEl.querySelectorAll('[data-wabi--select-target="itemText"]')) : []

    this.originalParents = {
      positioner: this.positionerEl?.parentNode,
    }

    this.portaled = this.portalValue
    if (this.portaled) this.attachToBody()

    const items = this.itemsValue
    const collection = select.collection({
      items,
      itemToString: (item) => item.label,
      itemToValue:  (item) => item.value,
    })

    this.machine = new VanillaMachine(select.machine, {
      id: this.element.id || crypto.randomUUID(),
      collection,
      name: this.nameValue || undefined,
      // `defaultValue` keeps the bindable uncontrolled so the machine can mutate
      // it on ITEM.CLICK. Passing `value:` here would make it controlled --
      // internal state changes are ignored and the trigger label never updates.
      defaultValue: this.valueValue ? [this.valueValue] : undefined,
      disabled: this.disabledValue,
      onValueChange: ({ value }) => {
        this.valueValue = value[0] || ""
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
    if (this.portaled) {
      this.restoreFromBody()
    }
  }

  attachToBody() {
    // Move positioner; content rides along inside it (do not extract).
    if (this.positionerEl && this.positionerEl.parentNode !== document.body) {
      document.body.appendChild(this.positionerEl)
    }
  }

  restoreFromBody() {
    if (this.positionerEl && this.originalParents.positioner) this.originalParents.positioner.appendChild(this.positionerEl)
  }

  render() {
    const api = select.connect(this.machine.service, normalizeProps)

    spreadProps(this.element, api.getRootProps())
    if (this.hasHiddenSelectTarget) spreadProps(this.hiddenSelectTarget, api.getHiddenSelectProps())
    if (this.hasTriggerTarget)      spreadProps(this.triggerTarget,      api.getTriggerProps())
    if (this.hasIndicatorTarget)    spreadProps(this.indicatorTarget,    api.getIndicatorProps())
    if (this.hasValueTextTarget)    spreadProps(this.valueTextTarget,    api.getValueTextProps())
    if (this.positionerEl)          spreadProps(this.positionerEl,       api.getPositionerProps())
    if (this.contentEl) {
      spreadProps(this.contentEl, api.getContentProps())
      this.contentEl.hidden = false
    }
    if (this.listEl)                spreadProps(this.listEl,             api.getListProps())

    // ValueText content: api.valueAsString shows the selected label(s) or empty.
    if (this.hasValueTextTarget) {
      this.valueTextTarget.textContent = api.valueAsString || this.placeholderValue
    }

    // Per-item props (data-highlighted, data-state=checked, click handlers).
    this.itemEls.forEach((el) => {
      const value = el.dataset.wabiValue
      const item  = this.itemsValue.find((i) => i.value === value)
      if (item) spreadProps(el, api.getItemProps({ item }))
    })

    // Per-item indicator visibility.
    this.itemIndicatorEls.forEach((el) => {
      const li    = el.closest("[data-wabi--select-target='item']")
      const value = li?.dataset.wabiValue
      const item  = this.itemsValue.find((i) => i.value === value)
      if (item) spreadProps(el, api.getItemIndicatorProps({ item }))
    })

    // Per-item text props.
    this.itemTextEls.forEach((el) => {
      const li    = el.closest("[data-wabi--select-target='item']")
      const value = li?.dataset.wabiValue
      const item  = this.itemsValue.find((i) => i.value === value)
      if (item) spreadProps(el, api.getItemTextProps({ item }))
    })
  }
}
