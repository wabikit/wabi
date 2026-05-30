import { Controller } from "@hotwired/stimulus"
import * as combobox from "@zag-js/combobox"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["label", "control", "input", "trigger", "positioner", "content", "item", "itemIndicator", "hiddenInput", "loading"]
  static values  = {
    name:        String,
    items:       Array,
    value:       String,
    placeholder: { type: String,  default: "Select an option..." },
    disabled:    { type: Boolean, default: false },
    portal:      { type: Boolean, default: true  },
    url:         { type: String,  default: "" },
    param:       { type: String,  default: "q" },
    debounce:    { type: Number,  default: 250 },
    minLength:   { type: Number,  default: 1 },
  }

  connect() {
    // Capture refs BEFORE portal move (Sprint 9 trap).
    this.contentEl    = this.hasContentTarget    ? this.contentTarget    : null
    this.positionerEl = this.hasPositionerTarget ? this.positionerTarget : null

    // In-content targets need capture before move (Sprint 9 trap).
    this.itemEls = this.contentEl
      ? Array.from(this.contentEl.querySelectorAll('[data-wabi--combobox-target="item"]'))
      : []
    this.itemIndicatorEls = this.contentEl
      ? Array.from(this.contentEl.querySelectorAll('[data-wabi--combobox-target="itemIndicator"]'))
      : []

    this.originalParents = {
      positioner: this.positionerEl?.parentNode,
    }

    this.portaled = this.portalValue
    if (this.portaled) this.attachToBody()

    // When items-value is empty (e.g. Command palette renders items as static
    // HTML rather than passing a JSON array), build the collection from the
    // captured DOM elements so Zag can spread getItemProps onto them.
    const domItems = this.itemEls.map((el) => ({
      value:    el.dataset.wabiValue    || "",
      label:    el.dataset.wabiLabel    || el.textContent.trim(),
      // CommandItem always emits data-wabi-disabled="true|false". (ComboboxItem
      // emits data-disabled only when disabled — but ComboboxItem is never used
      // in this DOM-fallback path: standalone comboboxes always pass items-value.)
      disabled: el.hasAttribute("data-disabled") || el.dataset.wabiDisabled === "true",
    }))
    this.items = this.itemsValue.length > 0 ? this.itemsValue : domItems

    const collection = combobox.collection({
      items: this.items,
      itemToString: (item) => item.label,
      itemToValue:  (item) => item.value,
      isItemDisabled: (item) => item.disabled === true,
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

  // Imperative open/close actions, used by sibling controllers (e.g. the
  // wabi--command bridge auto-opens this combobox when its dialog opens).
  open() {
    if (!this.machine) return
    const api = combobox.connect(this.machine.service, normalizeProps)
    if (typeof api.setOpen === "function") api.setOpen(true)
  }

  close() {
    if (!this.machine) return
    const api = combobox.connect(this.machine.service, normalizeProps)
    if (typeof api.setOpen === "function") api.setOpen(false)
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
      const item  = this.items.find((i) => i.value === value)
      if (item) spreadProps(el, api.getItemProps({ item }))
    })

    this.itemIndicatorEls.forEach((el) => {
      // Walk up to the nearest item element to look up the item object,
      // then spread Zag's per-item indicator props (toggles `hidden` based
      // on whether the item is currently selected).
      const itemEl = el.closest('[data-wabi--combobox-target="item"]')
      const value  = itemEl?.dataset.wabiValue
      const item   = this.items.find((i) => i.value === value)
      if (item) spreadProps(el, api.getItemIndicatorProps({ item }))
    })
  }
}
