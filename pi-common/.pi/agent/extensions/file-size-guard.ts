/**
 * File Size Guard — Pi extension
 *
 * Enforces maximum line count per file to prevent the "huge files" anti-pattern.
 * Hard guard — returns { block: true, reason } to prevent execution.
 */

import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { isToolCallEventType } from "@mariozechner/pi-coding-agent";

const MAX_LINES = 300;

const BLOCK_MESSAGE =
  `This file exceeds ${MAX_LINES} lines.\n\n` +
  "REFACTOR REQUIRED:\n" +
  "- Split into smaller modules/files\n" +
  "- Extract related functions into separate files\n" +
  "- Use composition over monolith\n\n" +
  "Small files are easier to: read, test, review, and reason about.";

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    const tool = event.toolName;
    if (tool !== "write" && tool !== "edit") return;

    const filePath = event.input?.path || event.input?.filePath || "";
    if (!filePath) return;

    // Skip vendor/node_modules
    if (filePath.includes("vendor") || filePath.includes("node_modules")) return;

    const fullPath = join(ctx.cwd, filePath);
    if (!existsSync(fullPath)) return;

    try {
      const content = readFileSync(fullPath, "utf-8");
      const lineCount = content.split("\n").length;

      if (lineCount > MAX_LINES) {
        return {
          block: true,
          reason: BLOCK_MESSAGE,
        };
      }
    } catch {
      // Can't read file — don't block
    }
  });
}
