// WabiPortalRegistry: global singleton that tracks every open portal-mounted
// overlay so `inert` can be applied to non-overlay top-level elements when
// any overlay is open. Auto-attaches to `window` on first import so the
// importing controller doesn't need to manage initialization.

const open = new Set()

function applyInert() {
  const portalNodes = new Set()
  open.forEach((c) => {
    if (c.contentEl)    portalNodes.add(c.contentEl)
    if (c.backdropEl)   portalNodes.add(c.backdropEl)
    if (c.positionerEl) portalNodes.add(c.positionerEl)
  })
  const anyOpen = [...open].some((c) => c.isOpen?.())
  document.body.childNodes.forEach((node) => {
    if (node.nodeType !== 1) return
    if (portalNodes.has(node)) return
    if (anyOpen) node.setAttribute("inert", "")
    else         node.removeAttribute("inert")
  })
}

const registry = window.WabiPortalRegistry ?? {
  register(controller)   { open.add(controller); applyInert() },
  unregister(controller) { open.delete(controller); applyInert() },
  onOpenChange()         { applyInert() },
}

window.WabiPortalRegistry = registry

export { registry as WabiPortalRegistry }
