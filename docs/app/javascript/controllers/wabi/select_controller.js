import { Controller } from "@hotwired/stimulus"
import * as select from "@zag-js/select"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"
import { WabiPortalRegistry } from "controllers/wabi/_shared/portal_registry"

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
    this.originalParents = {
      content:    this.contentEl?.parentNode,
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
        // Tracked here (not as a Stimulus value) because select's open state is
        // machine-internal; isOpen() exposes it for WabiPortalRegistry's inert calc.
        this.isOpenValue = open
        WabiPortalRegistry.onOpenChange()
        if (!this.portaled && this.contentEl) {
          if (open) this.contentEl.removeAttribute("inert")
          else      this.contentEl.setAttribute("inert", "")
        }
      },
    })
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    if (this.portaled) WabiPortalRegistry.register(this)
    this.render()
  }

  disconnect() {
    this.unsubscribe?.()
    this.machine?.stop()
    if (this.portaled) {
      WabiPortalRegistry.unregister(this)
      this.restoreFromBody()
    }
  }

  isOpen() { return !!this.isOpenValue }

  attachToBody() {
    [this.contentEl, this.positionerEl].forEach((el) => {
      if (el && el.parentNode !== document.body) document.body.appendChild(el)
    })
  }

  restoreFromBody() {
    if (this.contentEl    && this.originalParents.content)    this.originalParents.content.appendChild(this.contentEl)
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
    if (this.hasListTarget)         spreadProps(this.listTarget,         api.getListProps())

    // ValueText content: api.valueAsString shows the selected label(s) or empty.
    if (this.hasValueTextTarget) {
      this.valueTextTarget.textContent = api.valueAsString || this.placeholderValue
    }

    // Per-item props (data-highlighted, data-state=checked, click handlers).
    this.itemTargets.forEach((el) => {
      const value = el.dataset.wabiValue
      const item  = this.itemsValue.find((i) => i.value === value)
      if (item) spreadProps(el, api.getItemProps({ item }))
    })

    // Per-item indicator visibility.
    this.itemIndicatorTargets.forEach((el) => {
      const li    = el.closest("[data-wabi--select-target='item']")
      const value = li?.dataset.wabiValue
      const item  = this.itemsValue.find((i) => i.value === value)
      if (item) spreadProps(el, api.getItemIndicatorProps({ item }))
    })

    // Per-item text props.
    this.itemTextTargets.forEach((el) => {
      const li    = el.closest("[data-wabi--select-target='item']")
      const value = li?.dataset.wabiValue
      const item  = this.itemsValue.find((i) => i.value === value)
      if (item) spreadProps(el, api.getItemTextProps({ item }))
    })
  }
}
