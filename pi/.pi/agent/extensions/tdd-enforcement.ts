/**
 * TDD Enforcement — Pi extension
 *
 * Blocks editing source files without corresponding test files.
 * Hard guard — returns { block: true, reason } to prevent execution.
 */

import { existsSync } from "node:fs";
import { join } from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { isToolCallEventType } from "@mariozechner/pi-coding-agent";

const BLOCK_MESSAGE =
  "No test exists for this source file.\n\n" +
  "RULES (per AGENTS.md 'Definition of Done'):\n" +
  "- New component/widget: at least one snapshot test\n" +
  "- New function/method: unit tests for happy path + edge cases\n" +
  "- Bug fix: regression test that would have caught the bug\n\n" +
  "Write tests BEFORE committing source code changes.\n" +
  "The test IS the log - don't add prints, add assertions.";

function getTestFileForSource(sourcePath: string): string | null {
  if (sourcePath.endsWith(".rs")) {
    const base = sourcePath.replace(/\.rs$/, "");
    return `${base}_test.rs`;
  }
  if (sourcePath.endsWith(".ts") || sourcePath.endsWith(".tsx")) {
    const base = sourcePath.replace(/\.tsx?$/, "");
    return `${base}.test.ts`;
  }
  return null;
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    const tool = event.toolName;
    if (tool !== "write" && tool !== "edit") return;

    const filePath = event.input?.path || event.input?.filePath || "";
    if (!filePath) return;

    // Skip test files themselves
    if (filePath.includes("test") || filePath.includes("spec")) return;
    // Skip vendor
    if (filePath.includes("vendor")) return;

    const testFile = getTestFileForSource(filePath);
    if (!testFile) return; // Not a source file we track

    const testPath = join(ctx.cwd, testFile);
    if (!existsSync(testPath)) {
      return {
        block: true,
        reason: BLOCK_MESSAGE,
      };
    }
  });
}
