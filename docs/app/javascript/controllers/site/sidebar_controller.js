import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.sidebar = document.querySelector("aside.sidebar-mobile-target") || document.querySelector("aside.lg\\:block")
    this.boundClose = this.close.bind(this)
  }

  toggle(e) {
    e?.preventDefault()
    if (!this.sidebar) return
    const isOpen = this.sidebar.classList.contains("!block")
    isOpen ? this.close() : this.open()
  }

  open() {
    this.sidebar.classList.add("!block", "fixed", "inset-y-14", "left-0", "z-40", "bg-background", "border-r")
    document.addEventListener("keydown", this.boundClose)
    document.body.style.overflow = "hidden"
  }

  close(e) {
    if (e && e.type === "keydown" && e.key !== "Escape") return
    this.sidebar.classList.remove("!block", "fixed", "inset-y-14", "left-0", "z-40", "bg-background", "border-r")
    document.removeEventListener("keydown", this.boundClose)
    document.body.style.overflow = ""
  }
}
