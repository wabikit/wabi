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
    placeholder: { type: String, default: "Select an option" },
  }

  connect() {
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
    const api = select.connect(this.machine.service, normalizeProps)

    spreadProps(this.element, api.getRootProps())
    if (this.hasHiddenSelectTarget) spreadProps(this.hiddenSelectTarget, api.getHiddenSelectProps())
    if (this.hasTriggerTarget)      spreadProps(this.triggerTarget,      api.getTriggerProps())
    if (this.hasIndicatorTarget)    spreadProps(this.indicatorTarget,    api.getIndicatorProps())
    if (this.hasValueTextTarget)    spreadProps(this.valueTextTarget,    api.getValueTextProps())
    if (this.hasPositionerTarget)   spreadProps(this.positionerTarget,   api.getPositionerProps())
    if (this.hasContentTarget)      spreadProps(this.contentTarget,      api.getContentProps())
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
