import { Controller } from "@hotwired/stimulus"

// Docs-only controller used by the Form example. Intercepts submit so the
// fake demo form doesn't navigate away from the docs page, then runs a
// few client-side checks. Each FormMessage slot has its own target so
// errors can be shown/hidden per field independently.
export default class extends Controller {
  static targets = [
    "nameInput",  "nameError",
    "emailInput", "emailError",
    "bioInput",   "bioError",
    "successMessage",
  ]

  static values = {
    nameMin: { type: Number, default: 2  },
    bioMin:  { type: Number, default: 10 },
  }

  submit(event) {
    event.preventDefault()

    const name  = this.hasNameInputTarget  ? this.nameInputTarget.value.trim()  : ""
    const email = this.hasEmailInputTarget ? this.emailInputTarget.value.trim() : ""
    const bio   = this.hasBioInputTarget   ? this.bioInputTarget.value.trim()   : ""

    const nameOK  = name.length >= this.nameMinValue
    const emailOK = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
    const bioOK   = bio.length >= this.bioMinValue

    this.toggle(this.hasNameErrorTarget  && this.nameErrorTarget,  !nameOK)
    this.toggle(this.hasEmailErrorTarget && this.emailErrorTarget, !emailOK)
    this.toggle(this.hasBioErrorTarget   && this.bioErrorTarget,   !bioOK)

    const allOK = nameOK && emailOK && bioOK
    if (this.hasSuccessMessageTarget) this.toggle(this.successMessageTarget, allOK)
  }

  toggle(el, show) {
    if (!el) return
    el.classList.toggle("hidden", !show)
  }
}
