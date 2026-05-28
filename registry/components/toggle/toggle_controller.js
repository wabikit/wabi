import { Controller } from "@hotwired/stimulus"
import * as toggle from "@zag-js/toggle"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

export default class extends Controller {
  static values = {
    pressed:  { type: Boolean, default: false },
    name:     String,
    disabled: { type: Boolean, default: false },
  }

  connect() {
    this.machine = new VanillaMachine(toggle.machine, {
      id: this.element.id || crypto.randomUUID(),
      defaultPressed: this.pressedValue,
      name: this.nameValue || undefined,
      disabled: this.disabledValue,
      onPressedChange: ({ pressed }) => {
        this.pressedValue = pressed
        this.dispatch("change", { detail: { pressed } })
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
    const api = toggle.connect(this.machine.service, normalizeProps)
    spreadProps(this.element, api.getRootProps())
  }
}
