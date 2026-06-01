// Pure stack-layout math for the Toast group coordinator. No DOM access.
//
// heights: front-first array of toast pixel heights (index 0 = front/newest).
// opts.expanded:     true when the group is hovered/focused (full list).
// opts.visibleCount: how many toasts peek before collapsing to the back.
// opts.gap:          px between toasts when expanded.
// opts.placement:    Toaster placement key, e.g. "top_right" / "bottom_left".
//
// Returns front-first [{ y, scale, zIndex, front, hidden }]:
//   y       px translateY (signed for the placement edge)
//   scale   1 at front, receding while collapsed
//   zIndex  front toast highest
//   front   true for index 0
//   hidden  true when collapsed and beyond visibleCount (timer should hold)
//
// Example: computeStack([80,80,80], {expanded:false, visibleCount:3, gap:14, placement:"bottom_right"})
//   => [{y:0,scale:1,...},{y:-16,scale:0.95,...},{y:-32,scale:0.9,...}]
const PEEK_OFFSET = 16   // px each receding toast peeks while collapsed
const SCALE_STEP  = 0.05 // scale removed per step back while collapsed

export function computeStack(heights, { expanded, visibleCount, gap, placement }) {
  // Top placements stack downward (+y); bottom placements stack upward (-y).
  const sign = String(placement).startsWith("top") ? 1 : -1
  const n = heights.length
  let cumulative = 0 // sum of heights in front of the current toast (expanded)

  return heights.map((h, i) => {
    const front = i === 0
    const hidden = !expanded && i >= visibleCount
    let y, scale
    if (expanded) {
      y = sign * (cumulative + gap * i)
      scale = 1
      cumulative += h
    } else {
      y = sign * i * PEEK_OFFSET
      scale = Math.max(0, 1 - i * SCALE_STEP)
    }
    return { y, scale, zIndex: n - i, front, hidden }
  })
}
