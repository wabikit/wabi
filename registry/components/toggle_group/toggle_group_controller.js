import { Controller } from "@hotwired/stimulus"
import * as toggleGroup from "@zag-js/toggle-group"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["item"]
  static values  = {
    multiple: { type: Boolean, default: false },
    value:    Array,
    name:     String,
    disabled: { type: Boolean, default: false },
  }

  connect() {
    this.machine = new VanillaMachine(toggleGroup.machine, {
      id: this.element.id || crypto.randomUUID(),
      multiple: this.multipleValue,
      defaultValue: this.valueValue,
      disabled: this.disabledValue,
      onValueChange: ({ value }) => {
        this.valueValue = value
        this.dispatch("change", { detail: { value } })
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
    const api = toggleGroup.connect(this.machine.service, normalizeProps)
    spreadProps(this.element, api.getRootProps())

    this.itemTargets.forEach((el) => {
      const value = el.dataset.wabiValue
      spreadProps(el, api.getItemProps({ value, disabled: el.dataset.wabiDisabled === "true" }))
    })

    this.syncHiddenInputs()
  }

  syncHiddenInputs() {
    this.element.querySelectorAll(':scope > input[type="hidden"][data-wabi--toggle-group-hidden="true"]').forEach((el) => el.remove())
    if (!this.nameValue) return
    const inputName = this.multipleValue ? `${this.nameValue}[]` : this.nameValue
    this.valueValue.forEach((v) => {
      const inp = document.createElement("input")
      inp.type = "hidden"
      inp.name = inputName
      inp.value = v
      // setAttribute (NOT dataset): the double-dash `data-wabi--toggle-group-hidden`
      // can't round-trip through dataset (it would become single-dash
      // data-wabi-toggle-group-hidden), which is what the cleanup selector in
      // render() matches — the mismatch leaked stale inputs across selections
      // (same trap the slider documents). Form then submitted stale values.
      inp.setAttribute("data-wabi--toggle-group-hidden", "true")
      this.element.appendChild(inp)
    })
  }
}
