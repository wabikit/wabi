import { Controller } from "@hotwired/stimulus"
import * as tagsInput from "@zag-js/tags-input"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static targets = ["label", "control", "input"]
  static values  = {
    name:        String,
    value:       Array,
    max:         { type: Number,  default: 0 },     // 0 = unlimited
    editable:    { type: Boolean, default: true },
    disabled:    { type: Boolean, default: false },
    placeholder: { type: String,  default: "" },
  }

  connect() {
    this.machine = new VanillaMachine(tagsInput.machine, {
      id: this.element.id || crypto.randomUUID(),
      // Intentionally NOT passing `name` — we own form submission via name[]
      // hidden inputs (see syncHiddenInputs), mirroring combobox.
      defaultValue: this.valueValue,
      max: this.maxValue > 0 ? this.maxValue : undefined,
      editable: this.editableValue,
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
    const api = tagsInput.connect(this.machine.service, normalizeProps)
    spreadProps(this.element, api.getRootProps())
    if (this.hasLabelTarget)   spreadProps(this.labelTarget,   api.getLabelProps())
    if (this.hasControlTarget) spreadProps(this.controlTarget, api.getControlProps())
    if (this.hasInputTarget)   spreadProps(this.inputTarget,   api.getInputProps())

    this.renderTags(api)
    this.syncHiddenInputs()
  }

  renderTags(api) {
    // Remove previously-rendered tag nodes (keep the text input in place).
    this.controlTarget
      .querySelectorAll('[data-wabi--tags-input-tag="true"]')
      .forEach((el) => el.remove())

    api.value.forEach((value, index) => {
      const item = document.createElement("span")
      item.setAttribute("data-wabi--tags-input-tag", "true")
      item.className =
        "inline-flex items-center gap-1 rounded bg-secondary px-2 py-0.5 text-xs " +
        "data-[highlighted]:bg-secondary/80 data-[disabled]:opacity-50"
      spreadProps(item, api.getItemProps({ index, value }))

      const preview = document.createElement("span")
      preview.className = "inline-flex items-center gap-1"
      spreadProps(preview, api.getItemPreviewProps({ index, value }))

      const text = document.createElement("span")
      text.textContent = value
      spreadProps(text, api.getItemTextProps({ index, value }))

      const del = document.createElement("button")
      del.type = "button"
      del.className = "ml-0.5 leading-none opacity-70 hover:opacity-100"
      del.textContent = "×"
      // Zag's getItemDeleteTriggerProps supplies the aria-label ("Delete tag <x>").
      spreadProps(del, api.getItemDeleteTriggerProps({ index, value }))

      preview.appendChild(text)
      preview.appendChild(del)
      item.appendChild(preview)

      // Edit-in-place input (Zag shows it when editable && the tag is double-clicked).
      const edit = document.createElement("input")
      edit.className = "bg-transparent focus-visible:outline focus-visible:outline-2 focus-visible:outline-ring w-20"
      spreadProps(edit, api.getItemInputProps({ index, value }))
      item.appendChild(edit)

      this.controlTarget.insertBefore(item, this.inputTarget)
    })
  }

  // Form submission: one hidden input per tag named `${name}[]` so Rails parses
  // an array. Cleanup selector uses setAttribute (NOT dataset) — the double-dash
  // can't round-trip through dataset (slider Sprint-7 trap).
  syncHiddenInputs() {
    this.element
      .querySelectorAll(':scope > input[type="hidden"][data-wabi--tags-input-hidden="true"]')
      .forEach((el) => el.remove())
    if (!this.nameValue) return
    this.valueValue.forEach((tag) => {
      const inp = document.createElement("input")
      inp.type = "hidden"
      inp.name = `${this.nameValue}[]`
      inp.value = String(tag)
      inp.setAttribute("data-wabi--tags-input-hidden", "true")
      this.element.appendChild(inp)
    })
  }
}
