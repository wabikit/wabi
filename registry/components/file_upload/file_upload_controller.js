import { Controller } from "@hotwired/stimulus"
import * as fileUpload from "@zag-js/file-upload"
import { VanillaMachine, normalizeProps, spreadProps } from "@zag-js/vanilla"

function humanSize(bytes) {
  if (bytes == null) return ""
  const u = ["B", "KB", "MB", "GB"]; let i = 0; let n = bytes
  while (n >= 1024 && i < u.length - 1) { n /= 1024; i++ }
  return `${n.toFixed(n < 10 && i > 0 ? 1 : 0)} ${u[i]}`
}

export default class extends Controller {
  static targets = ["dropzone", "trigger", "hiddenInput", "list"]
  static values = {
    name:     String,
    accept:   String,
    maxFiles: { type: Number, default: 1 },
    maxSize:  String,
    disabled: { type: Boolean, default: false },
  }

  connect() {
    this.machine = new VanillaMachine(fileUpload.machine, {
      id: this.element.id || crypto.randomUUID(),
      name: this.nameValue || undefined,
      accept: this.acceptValue || undefined,
      maxFiles: this.maxFilesValue,
      maxFileSize: this.maxSizeValue ? Number(this.maxSizeValue) : undefined,
      disabled: this.disabledValue,
      onFileChange: () => { this.renderList(); this.dispatch("change") },
    })
    this.unsubscribe = this.machine.subscribe(() => this.render())
    this.machine.start()
    this.render()
    this.renderList()
  }

  disconnect() {
    ;(this._objectUrls || []).forEach((u) => URL.revokeObjectURL(u))
    this.unsubscribe?.()
    this.machine?.stop()
  }

  get api() {
    return fileUpload.connect(this.machine.service, normalizeProps)
  }

  render() {
    const api = this.api
    spreadProps(this.element, api.getRootProps())
    if (this.hasDropzoneTarget)    spreadProps(this.dropzoneTarget,    api.getDropzoneProps())
    if (this.hasTriggerTarget)     spreadProps(this.triggerTarget,     api.getTriggerProps())
    if (this.hasHiddenInputTarget) spreadProps(this.hiddenInputTarget, api.getHiddenInputProps())
  }

  renderList() {
    if (!this.hasListTarget) return
    ;(this._objectUrls ||= []).forEach((u) => URL.revokeObjectURL(u))
    this._objectUrls = []
    const api = this.api
    this.listTarget.innerHTML = ""
    api.acceptedFiles.forEach((file) => {
      const li = document.createElement("li")
      li.className = "flex items-center gap-3 rounded-md border border-input p-2 text-sm"

      // Image preview: only for image files — Zag's getItemPreviewImageProps
      // throws for non-image types, so we guard with a type check.
      if (file.type?.startsWith("image/")) {
        const img = document.createElement("img")
        // getItemPreviewImageProps requires a `url` arg (the object URL).
        // We build it manually to avoid async createFileUrl and to keep
        // the preview synchronous for jsdom compatibility.
        const url = URL.createObjectURL(file)
        this._objectUrls.push(url)
        spreadProps(img, api.getItemPreviewImageProps({ file, url }))
        img.className = "h-10 w-10 rounded object-cover"
        li.appendChild(img)
      }

      const meta = document.createElement("div")
      meta.className = "flex-1 min-w-0"
      const nm = document.createElement("p")
      nm.className = "truncate font-medium"
      nm.textContent = file.name
      const sz = document.createElement("p")
      sz.className = "text-xs text-muted-foreground"
      sz.textContent = humanSize(file.size)
      meta.append(nm, sz)
      li.appendChild(meta)

      const del = document.createElement("button")
      del.type = "button"
      spreadProps(del, api.getItemDeleteTriggerProps({ file }))
      del.className = "shrink-0 rounded-md p-1 text-muted-foreground hover:bg-accent hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
      del.setAttribute("aria-label", `Remove ${file.name}`)
      del.textContent = "✕"
      li.appendChild(del)

      this.listTarget.appendChild(li)
    })
  }
}
