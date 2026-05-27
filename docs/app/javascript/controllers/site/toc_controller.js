import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list"]

  connect() {
    this.headings = Array.from(document.querySelectorAll("main h2[id], main h3[id]"))
    if (this.headings.length === 0) return
    this.build()
    this.observe()
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  build() {
    this.listTarget.innerHTML = ""
    this.anchorsById = new Map()
    this.headings.forEach(h => {
      const li = document.createElement("li")
      li.className = h.tagName === "H3" ? "pl-3" : ""
      const a = document.createElement("a")
      a.href = `#${h.id}`
      a.textContent = h.textContent
      a.className = "block py-0.5 text-muted-foreground hover:text-foreground"
      a.dataset.tocAnchor = h.id
      li.appendChild(a)
      this.listTarget.appendChild(li)
      this.anchorsById.set(h.id, a)
    })
  }

  observe() {
    this.observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        const a = this.anchorsById.get(entry.target.id)
        if (!a) return
        if (entry.isIntersecting) {
          this.anchorsById.forEach(link => link.classList.remove("text-foreground", "font-medium"))
          a.classList.add("text-foreground", "font-medium")
        }
      })
    }, { rootMargin: "0px 0px -75% 0px", threshold: 0 })
    this.headings.forEach(h => this.observer.observe(h))
  }
}
