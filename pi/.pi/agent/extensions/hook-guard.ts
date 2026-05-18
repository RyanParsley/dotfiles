/**
 * Hook Guard — Pi extension
 *
 * Blocks ALL attempts to bypass git hooks via --no-verify or other mechanisms.
 * Hard guard — returns { block: true, reason } to prevent execution.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { isToolCallEventType } from "@mariozechner/pi-coding-agent";

const BYPASS_PATTERNS = [
  /--no-verify/,
  /-c\s+core\.hooksPath\s*=/,
  /GIT_CONFIG_GLOBAL\s*=/,
  /GIT_CONFIG_SYSTEM\s*=/,
];

const BLOCK_MESSAGE =
  "You are NEVER allowed to bypass git hooks. " +
  "Remove --no-verify or any hook bypass flag and fix the ACTUAL problem instead. " +
  "The lefthook pre-commit/pre-push hooks are there to catch exactly the mistakes you're about to make. Do not defeat them.";

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (!isToolCallEventType("bash", event)) return;

    const command = event.input.command || "";

    for (const pattern of BYPASS_PATTERNS) {
      if (pattern.test(command)) {
        return { block: true, reason: BLOCK_MESSAGE };
      }
    }
  });
}
