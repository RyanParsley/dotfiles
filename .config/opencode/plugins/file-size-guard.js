/**
 * File Size Guard Plugin — Blocks oversized files
 *
 * Enforces maximum line count per file to prevent the "huge files"
 * anti-pattern. Configurable threshold (default: 300 lines).
 *
 * Install: Place in ~/.config/opencode/plugins/file-size-guard.js
 * Enable: Add to plugins array in opencode.json
 */

const MAX_LINES = 300

const SIZE_BLOCK_MESSAGE = `
╔══════════════════════════════════════════════════════════════════╗
║  FILE SIZE LIMIT EXCEEDED                                         ║
╠══════════════════════════════════════════════════════════════════╣
║  This file exceeds ${MAX_LINES} lines.                              ║
║                                                                  ║
║  REFACTOR REQUIRED:                                               ║
║  - Split into smaller modules/files                               ║
║  - Extract related functions into separate files                  ║
║  - Use composition over monolith                                  ║
║                                                                  ║
║  Small files are easier to: read, test, review, and reason about.  ║
╚══════════════════════════════════════════════════════════════════╝
`

export const FileSizeGuard = async ({ client, directory }) => {
  async function getLineCount(filePath) {
    const fs = await import("fs")
    const content = fs.readFileSync(filePath, "utf-8")
    return content.split("\n").length
  }

  return {
    "tool.execute.before": async (input, _output) => {
      const tool = input.tool
      if (tool !== "edit" && tool !== "write") return

      const filePath = input.args?.filePath || ""
      if (!filePath) return

      if (filePath.includes("vendor") || filePath.includes("node_modules")) return

      const fullPath = `${directory}/${filePath}`
      const fs = await import("fs")
      if (!fs.existsSync(fullPath)) return

      const lineCount = await getLineCount(fullPath)
      if (lineCount > MAX_LINES) {
        await client.app.log({
          body: {
            service: "file-size-guard",
            level: "error",
            message: `File too large: ${filePath} has ${lineCount} lines (max: ${MAX_LINES})`,
            extra: {
              file: filePath,
              lines: lineCount,
              max: MAX_LINES,
            },
          },
        })

        throw new Error(SIZE_BLOCK_MESSAGE)
      }
    },
  }
}