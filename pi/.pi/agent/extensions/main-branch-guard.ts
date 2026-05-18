/**
 * Main Branch Guard — Pi extension
 *
 * Blocks ALL attempts to commit or push to main/master/default branch.
 * Hard guard — returns { block: true, reason } to prevent execution.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { isToolCallEventType } from "@mariozechner/pi-coding-agent";

const BLOCK_MESSAGE =
  "NEVER commit directly to main (or the default branch). " +
  "Always work on a feature/fix branch and merge via PR. " +
  "Correct workflow: " +
  "1. git worktree add ../project-{branch} -b {branch} " +
  "2. Make changes and commit on the branch " +
  "3. Rebase onto main before pushing " +
  "4. Push and create a PR";

function isDefaultBranch(branch: string): boolean {
  const normalized = branch.toLowerCase().trim();
  return normalized === "main" || normalized === "master";
}

export default function (pi: ExtensionAPI) {
  let defaultBranch = "main";
  let detected = false;

  pi.on("session_start", async (_event, ctx) => {
    try {
      const result = await pi.exec("git", [
        "symbolic-ref",
        "refs/remotes/origin/HEAD",
      ], { cwd: ctx.cwd });
      const ref = result.stdout?.trim() || "";
      const branch = ref.split("/").pop();
      if (branch) {
        defaultBranch = branch;
        detected = true;
      }
    } catch {
      // Fallback to main
    }
  });

  pi.on("tool_call", async (event, ctx) => {
    if (!isToolCallEventType("bash", event)) return;

    const command = event.input.command || "";
    const branchesToCheck = [defaultBranch, "main", "master"];

    // Block git commit to default branch
    for (const branch of branchesToCheck) {
      if (
        command.includes(`git commit`) &&
        (command.includes(`-b ${branch}`) ||
          command.includes(`-b${branch}`) ||
          (command.includes(`git commit`) &&
            !command.includes("git commit --amend") &&
            !command.includes("--dry-run") &&
            command.includes(branch)))
      ) {
        return { block: true, reason: BLOCK_MESSAGE };
      }
    }

    // Block git push to default branch
    for (const branch of branchesToCheck) {
      if (
        command.includes(`git push`) &&
        (command.includes(` ${branch}`) ||
          command.includes(` ${branch} `) ||
          command.endsWith(` ${branch}`))
      ) {
        return { block: true, reason: BLOCK_MESSAGE };
      }
    }

    // Block checkout -b main/master directly
    for (const branch of branchesToCheck) {
      if (
        command.includes(`git checkout -b ${branch}`) ||
        command.includes(`git checkout -b${branch}`)
      ) {
        return { block: true, reason: BLOCK_MESSAGE };
      }
    }
  });
}
