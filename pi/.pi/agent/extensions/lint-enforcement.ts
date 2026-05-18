/**
 * Lint Enforcement — Pi extension
 *
 * Blocks commits that contain inline lint disabling comments in staged changes.
 * Hard guard — returns { block: true, reason } to prevent execution.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { isToolCallEventType } from "@mariozechner/pi-coding-agent";

const DISABLE_PATTERNS = [
  /eslint-disable/,
  /stylelint-disable/,
  /tslint:disable/,
  /disable-next-line/,
  /disable-line/,
  /golint:disable/,
  /ruff:disable/,
  /pylint:disable/,
];

const SOURCE_FILE_RE = /\.(js|ts|jsx|tsx|py|go|rs|css|scss|less)$/;

function isGitCommit(command: string): boolean {
  return (
    command.includes("git commit") &&
    !command.includes("--amend") &&
    !command.includes("--dry-run")
  );
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (!isToolCallEventType("bash", event)) return;

    const command = event.input.command || "";
    if (!isGitCommit(command)) return;

    // Get staged diff
    let diff = "";
    try {
      const result = await pi.exec("git", ["-C", ctx.cwd, "diff", "--cached", "--unified=0"]);
      diff = result.stdout || "";
    } catch {
      return; // can't read staged content — don't block
    }

    if (!diff) return;

    // Parse the diff into per-file sections and scan added lines
    const findings: string[] = [];
    let currentFile: string | null = null;

    for (const line of diff.split("\n")) {
      if (line.startsWith("+++ b/")) {
        currentFile = line.slice(6);
        continue;
      }

      if (!currentFile || !SOURCE_FILE_RE.test(currentFile)) continue;

      // Only look at added lines (starts with +, not +++)
      if (!line.startsWith("+") || line.startsWith("+++")) continue;

      const content = line.slice(1);
      for (const pattern of DISABLE_PATTERNS) {
        if (pattern.test(content)) {
          findings.push(`${currentFile}: ${content.trim()}`);
          break;
        }
      }
    }

    if (findings.length === 0) return;

    const list = findings.map((f) => `  ${f}`).join("\n");
    return {
      block: true,
      reason:
        `Lint disable comments found in staged changes:\n${list}\n\n` +
        `Lint disable comments are not allowed. Fix the underlying issues instead.`,
    };
  });
}
