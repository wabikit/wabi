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
  },
  resolve: {
    alias: [{ find: /^controllers\/wabi\/_shared\//, replacement: sharedDir }],
  },
})
