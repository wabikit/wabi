import { Controller } from "@hotwired/stimulus"

// Docs-only controller used by the Form example. Intercepts submit so the
// fake demo form doesn't navigate away from the docs page, then runs a
// quick client-side email validation to decide whether to show the inline
// success banner or the FormMessage error.
export default class extends Controller {
  static targets = ["emailInput", "errorMessage", "successMessage"]

  submit(event) {
    event.preventDefault()

    const email = this.hasEmailInputTarget ? this.emailInputTarget.value.trim() : ""
    const valid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)

    if (valid) {
      if (this.hasErrorMessageTarget)   this.errorMessageTarget.classList.add("hidden")
      if (this.hasSuccessMessageTarget) this.successMessageTarget.classList.remove("hidden")
    } else {
      if (this.hasErrorMessageTarget)   this.errorMessageTarget.classList.remove("hidden")
      if (this.hasSuccessMessageTarget) this.successMessageTarget.classList.add("hidden")
    }
  }
}
