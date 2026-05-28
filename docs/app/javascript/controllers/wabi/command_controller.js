import { Controller } from "@hotwired/stimulus"

// Bridge between the nested wabi--combobox (selection events) and the
// outer wabi--dialog (close action). When the user picks a command item,
// the combobox dispatches a "change" event with the selected value; this
// controller listens and asks the dialog controller to close.
export default class extends Controller {
  connect() {
    this.boundOnChange = this.onComboboxChange.bind(this)
    this.element.addEventListener("wabi--combobox:change", this.boundOnChange)
  }

  disconnect() {
    this.element.removeEventListener("wabi--combobox:change", this.boundOnChange)
  }

  onComboboxChange(event) {
    const dialogController = this.application.getControllerForElementAndIdentifier(
      this.element, "wabi--dialog"
    )
    if (dialogController) dialogController.close()
  }
}
