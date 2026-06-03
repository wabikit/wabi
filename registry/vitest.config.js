import { defineConfig } from "vitest/config"
import { fileURLToPath } from "node:url"

// Map the importmap specifier base the controllers use
// ("controllers/wabi/_shared/<x>") to the real shared files on disk.
const sharedDir = fileURLToPath(new URL("./components/_shared/", import.meta.url))

export default defineConfig({
  test: {
    environment: "jsdom",
    globals: true,
    include: ["**/*.test.js"],
    exclude: ["node_modules/**"],
    setupFiles: ["./test/support/setup.js"],
    coverage: {
      provider: "v8",
      reporter: ["text", "html"],
      include: ["components/**/*.js"],
      exclude: ["**/*.test.js", "test/**", "node_modules/**"],
      // Regression floors a few points below the Phase-2 baseline (statements
      // 81.3% / branches 71.3% / functions 74.8% / lines 81.3%) so CI fails if
      // coverage drops. `npm run test:coverage` enforces them; raise as coverage
      // improves (e.g. once combobox async paths get a server-backed test).
      thresholds: {
        statements: 78,
        branches: 67,
        functions: 70,
        lines: 78,
      },
    },
  },
  resolve: {
    alias: [{ find: /^controllers\/wabi\/_shared\//, replacement: sharedDir }],
  },
})
