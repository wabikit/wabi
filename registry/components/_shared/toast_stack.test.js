import { describe, it, expect } from "vitest"
import { computeStack } from "./toast_stack.js"

describe("computeStack", () => {
  const heights = [80, 80, 80, 80]

  it("collapsed: front at y0/scale1, receding toasts offset + scaled down (bottom placement)", () => {
    const r = computeStack(heights, { expanded: false, visibleCount: 3, gap: 14, placement: "bottom_right" })
    // y is sign * 0 which yields -0 for bottom placements; use Object.is-safe check
    expect(r[0].y).toBeCloseTo(0)
    expect(r[0]).toMatchObject({ scale: 1, front: true, hidden: false })
    expect(r[1].y).toBeLessThan(0)        // bottom placement → recede upward (negative y)
    expect(r[1].scale).toBeLessThan(1)
    expect(r[2].scale).toBeLessThan(r[1].scale)
  })

  it("collapsed: toasts beyond visibleCount are hidden", () => {
    const r = computeStack(heights, { expanded: false, visibleCount: 3, gap: 14, placement: "bottom_right" })
    expect(r[3].hidden).toBe(true)
    expect(r[2].hidden).toBe(false)
  })

  it("expanded: scale 1, none hidden, cumulative offsets", () => {
    const r = computeStack(heights, { expanded: true, visibleCount: 3, gap: 14, placement: "bottom_right" })
    expect(r.every((t) => t.scale === 1)).toBe(true)
    expect(r.every((t) => t.hidden === false)).toBe(true)
    // r[1].y = sign * (heights[0] + gap * 1) = -1 * (80 + 14) = -94
    expect(Math.abs(r[1].y)).toBeCloseTo(80 + 14)
    // r[2].y = sign * (heights[0]+heights[1] + gap * 2) = -1 * (160 + 28) = -188
    expect(Math.abs(r[2].y)).toBeCloseTo((80 + 14) * 2)
  })

  it("top placement flips the sign (recede downward, positive y)", () => {
    const r = computeStack(heights, { expanded: false, visibleCount: 3, gap: 14, placement: "top_left" })
    expect(r[1].y).toBeGreaterThan(0)
  })

  it("zIndex: front highest, descending", () => {
    const r = computeStack(heights, { expanded: false, visibleCount: 3, gap: 14, placement: "bottom_right" })
    expect(r[0].zIndex).toBeGreaterThan(r[1].zIndex)
    expect(r[1].zIndex).toBeGreaterThan(r[2].zIndex)
  })
})
