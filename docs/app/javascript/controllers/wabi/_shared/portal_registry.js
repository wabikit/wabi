// WabiPortalRegistry: global singleton that tracks every open portal-mounted
// overlay so `inert` can be applied to non-overlay top-level elements when
// any overlay is open. Auto-attaches to `window` on first import so the
// importing controller doesn't need to manage initialization.
//
// v0.7 perf: caches the set of non-portal body children. The cache is only
// invalidated when register/unregister changes which portal nodes exist;
// onOpenChange (open/close on an already-tracked overlay) reuses the
// cached list and just toggles the inert attribute on each child. Prior
// versions walked document.body.childNodes on every open/close.
//
// Known limitation: the cache only tracks body children present at the last
// register/unregister. Top-level body nodes appended by external code (a
// Turbo Frame, a third-party widget) AFTER the last register call won't be
// in the cache and so won't receive `inert` while an overlay is open. In
// practice overlays register on connect (which fires on Turbo navigations),
// so this gap is narrow; if it ever matters, call register/unregister on the
// affected overlay to force a recompute.

const open = new Set()
let cachedSiblings = null  // Element[] | null — invalidated by register/unregister

function recomputeSiblings() {
  const portalNodes = new Set()
  open.forEach((c) => {
    if (c.contentEl)    portalNodes.add(c.contentEl)
    if (c.backdropEl)   portalNodes.add(c.backdropEl)
    if (c.positionerEl) portalNodes.add(c.positionerEl)
  })
  const siblings = []
  document.body.childNodes.forEach((node) => {
    if (node.nodeType !== 1) return
    if (portalNodes.has(node)) return
    siblings.push(node)
  })
  cachedSiblings = siblings
}

function applyInert() {
  if (cachedSiblings == null) recomputeSiblings()
  // Direct Set iteration (no [...open] array allocation) — short-circuits on
  // the first open overlay. This runs on every open/close, the hot path.
  let anyOpen = false
  for (const c of open) {
    if (c.isOpen?.()) { anyOpen = true; break }
  }
  cachedSiblings.forEach((node) => {
    if (anyOpen) node.setAttribute("inert", "")
    else         node.removeAttribute("inert")
  })
}

function invalidateAndApply() {
  cachedSiblings = null
  applyInert()
}

const registry = window.WabiPortalRegistry ?? {
  register(controller)   { open.add(controller); invalidateAndApply() },
  unregister(controller) { open.delete(controller); invalidateAndApply() },
  onOpenChange()         { applyInert() },  // no invalidation — same overlay set
}

window.WabiPortalRegistry = registry

export { registry as WabiPortalRegistry }
