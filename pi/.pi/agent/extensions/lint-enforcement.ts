/**
 * Lint Enforcement — Pi extension
 *
 * Blocks commits whose staged changes add inline lint suppressions, per
 * AGENTS.md: "Never add suppressions to cheat the linter."
 *
 * Scope is suppressions written into source. Bypassing the enforcement layer
 * itself is command-level, and hook-guard.ts owns that.
 *
 * The staged diff is read from the repository the commit command actually runs
 * in (a `cd <worktree> && git commit`), not the session's working directory --
 * otherwise every worktree commit is graded against someone else's index.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const DISABLE_PATTERNS = [
  /eslint-disable/,
  /stylelint-disable/,
  /tslint:disable/,
  /disable-next-line/,
  /disable-line/,
  /golint:disable/,
  /ruff:disable/,
  /pylint:disable/,
  // Rust: AGENTS.md names these explicitly, so the guard has to know them.
  /#!?\[allow\(/,
  /#!?\[expect\(/,
  /\/\/\s*clippy::/,
  /#!?\[rustfmt::skip\]/,
];

const SOURCE_FILE_RE = /\.(js|ts|jsx|tsx|py|go|rs|css|scss|less)$/;

export function isGitCommitCommand(command: string): boolean {
  return command.includes("git commit") && !command.includes("--amend") && !command.includes("--dry-run");
}

/** Directory a command changes into before running, or null when it does not move. */
export function commandWorkdir(command: string): string | null {
  const match = /^\s*cd\s+(?:"([^"]+)"|'([^']+)'|([^\s;&|]+))\s*(?:&&|\|\||;|\n)/.exec(command);
  if (!match) return null;
  return match[1] ?? match[2] ?? match[3] ?? null;
}

/**
 * Added suppression lines in a staged diff, as `file: content` findings.
 * Only `+` lines count: context and removals are not part of this commit.
 */
export function findLintDisables(diff: string): string[] {
  const findings: string[] = [];
  let currentFile: string | null = null;

  for (const line of diff.split("\n")) {
    if (line.startsWith("+++ b/")) {
      currentFile = line.slice(6);
      continue;
    }
    if (!currentFile || !SOURCE_FILE_RE.test(currentFile)) continue;
    if (!line.startsWith("+") || line.startsWith("+++")) continue;

    const content = line.slice(1);
    if (DISABLE_PATTERNS.some((pattern) => pattern.test(content))) {
      findings.push(`${currentFile}: ${content.trim()}`);
    }
  }

  return findings;
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return;

    const command: string = event.input?.command || "";
    if (!isGitCommitCommand(command)) return;

    const repoDir = commandWorkdir(command) ?? ctx.cwd;

    let diff = "";
    try {
      const result = await pi.exec("git", ["-C", repoDir, "diff", "--cached", "--unified=0"], { cwd: repoDir });
      diff = result.stdout || "";
    } catch {
      return; // can't read staged content — don't block
    }

    const findings = findLintDisables(diff);
    if (findings.length === 0) return;

    const list = findings.map((finding) => `  ${finding}`).join("\n");
    return {
      block: true,
      reason:
        `Lint disable comments found in staged changes at ${repoDir}:\n${list}\n\n` +
        `Lint disable comments are not allowed (see AGENTS.md). Fix the underlying issue instead.`,
    };
  });
}
