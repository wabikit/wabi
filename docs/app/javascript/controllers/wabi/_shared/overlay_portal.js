// Shared portal/overlay helpers used by the portal-using overlay controllers.
// Each function takes the Stimulus controller instance (c) and operates on its
// captured element refs. Extracted from per-controller boilerplate so the
// overlays stop duplicating attach/restore/ref-capture logic.

// Capture positioner/backdrop/content refs + their original parents BEFORE any
// portal move (Stimulus targets stop resolving once a node leaves the
// controller's subtree — the Sprint 9 trap).
export function capturePortalRefs(c) {
  c.contentEl    = c.hasContentTarget    ? c.contentTarget    : null
  c.positionerEl = c.hasPositionerTarget ? c.positionerTarget : null
  c.backdropEl   = c.hasBackdropTarget   ? c.backdropTarget   : null
  c.originalParents = {
    positioner: c.positionerEl?.parentNode,
    backdrop:   c.backdropEl?.parentNode,
    content:    c.contentEl?.parentNode,
  }
}

// Move the overlay's portal node(s) to <body>. Anchored overlays move the
// positioner (content rides inside); an overlay without a positioner moves its
// content directly. A backdrop (Dialog) moves separately.
export function attachToBody(c) {
  const mover = c.positionerEl || c.contentEl
  if (mover && mover.parentNode !== document.body) {
    document.body.appendChild(mover)
  }
  if (c.backdropEl && c.backdropEl.parentNode !== document.body) {
    document.body.appendChild(c.backdropEl)
  }
}

export function restoreFromBody(c) {
  if (c.positionerEl && c.originalParents?.positioner) {
    c.originalParents.positioner.appendChild(c.positionerEl)
  } else if (c.contentEl && c.originalParents?.content) {
    c.originalParents.content.appendChild(c.contentEl)
  }
  if (c.backdropEl && c.originalParents?.backdrop) {
    c.originalParents.backdrop.appendChild(c.backdropEl)
  }
}

// Multi-panel variant for overlays that own several content panels (one open at
// a time), e.g. navigation_menu. Capture the panel refs + parents BEFORE moving,
// move each to <body>, and restore each on disconnect. Same Sprint 9 trap: once a
// panel leaves the subtree, `contentTargets` stops resolving it.
export function capturePanelRefs(c) {
  c.panelEls = c.hasContentTarget ? Array.from(c.contentTargets) : []
  c.panelParents = c.panelEls.map((el) => el.parentNode)
}

export function attachPanelsToBody(c) {
  c.panelEls?.forEach((el) => {
    if (el.parentNode !== document.body) document.body.appendChild(el)
  })
}

export function restorePanelsFromBody(c) {
  c.panelEls?.forEach((el, i) => c.panelParents?.[i]?.appendChild(el))
}
