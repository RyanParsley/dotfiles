/**
 * Main Branch Guard — Pi extension
 *
 * Blocks ALL attempts to commit or push to main/master/default branch.
 * Hard guard — returns { block: true, reason } to prevent execution.
 *
 * Checks the actual current branch via git, not the command string.
 * Also checks worktree branches — if any worktree is on a feature branch,
 * assumes the user is working there and allows the commit.
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

async function getCurrentBranch(pi: ExtensionAPI, cwd: string): Promise<string | null> {
  try {
    const result = await pi.exec("git", ["branch", "--show-current"], { cwd });
    return result.stdout?.trim() || null;
  } catch {
    return null;
  }
}

async function getDefaultBranch(pi: ExtensionAPI, cwd: string): Promise<string> {
  try {
    const result = await pi.exec("git", ["symbolic-ref", "refs/remotes/origin/HEAD"], { cwd });
    const ref = result.stdout?.trim() || "";
    return ref.split("/").pop() || "main";
  } catch {
    return "main";
  }
}

async function hasFeatureBranchWorktree(pi: ExtensionAPI, cwd: string, defaultBranch: string): Promise<boolean> {
  try {
    const result = await pi.exec("git", ["worktree", "list", "--porcelain"], { cwd });
    const output = result.stdout?.trim() || "";
    const worktrees = output.split("\n\n").filter(Boolean);

    for (const wt of worktrees) {
      const wtBranch = wt.match(/^branch\s+(.+)$/m)?.[1];
      if (wtBranch) {
        const branchName = wtBranch.split("/").slice(3).join("/");
        if (branchName !== defaultBranch && branchName !== "main" && branchName !== "master") {
          return true;
        }
      }
    }
  } catch {
    // Can't list worktrees
  }
  return false;
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (!isToolCallEventType("bash", event)) return;

    const command = event.input.command || "";
    const isCommit = /^git\s+commit\b/.test(command);
    const isPush = /^git\s+push\b/.test(command);

    if (!isCommit && !isPush) return;

    const cwd = ctx.cwd || process.cwd();
    const defaultBranch = await getDefaultBranch(pi, cwd);
    const currentBranch = await getCurrentBranch(pi, cwd);

    if (!currentBranch) return; // Can't determine, allow

    // If current branch is a feature branch, allow
    if (currentBranch !== defaultBranch && currentBranch !== "main" && currentBranch !== "master") {
      return;
    }

    // Check worktrees — if any worktree is on a feature branch, allow
    if (await hasFeatureBranchWorktree(pi, cwd, defaultBranch)) {
      return;
    }

    return { block: true, reason: BLOCK_MESSAGE };
  });
}
