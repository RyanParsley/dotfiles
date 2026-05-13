/**
 * Lint Enforcement Plugin — Blocks disabling of linters
 *
 * Prevents commits that contain inline lint disabling comments like:
 * - eslint-disable
 * - stylelint-disable
 * - tslint:disable
 * - disable-next-line
 *
 * Uses tool.execute.before to intercept bash git commit calls, reads staged
 * content via `git diff --cached`, and scans it for disable patterns.
 *
 * Install: Symlink or copy to ~/.config/opencode/plugins/lint-enforcement.js
 * Enable: Add "~/.config/opencode/plugins/lint-enforcement.js" to plugins array in ~/.config/opencode/opencode.json
 */

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

function isGitCommit(command) {
  return (
    typeof command === 'string' &&
    command.includes('git commit') &&
    !command.includes('--amend') &&
    !command.includes('--dry-run')
  );
}

export const LintEnforcement = async ({ $, directory }) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return;

      const command = input.args?.command || "";
      if (!isGitCommit(command)) return;

      // Get staged diff: added (+) lines only, unified=0 to keep it tight
      let diff = "";
      try {
        const result = await $`git -C ${directory} diff --cached --unified=0`.nothrow();
        diff = result.stdout?.toString() || "";
      } catch {
        return; // can't read staged content — don't block
      }

      if (!diff) return;

      // Parse the diff into per-file sections and scan added lines
      const findings = [];
      let currentFile = null;

      for (const line of diff.split('\n')) {
        // +++ b/path/to/file.rs
        if (line.startsWith('+++ b/')) {
          currentFile = line.slice(6);
          continue;
        }

        // Skip files that aren't source files we care about
        if (!currentFile || !SOURCE_FILE_RE.test(currentFile)) continue;

        // Only look at added lines (starts with +, not +++)
        if (!line.startsWith('+') || line.startsWith('+++')) continue;

        const content = line.slice(1); // strip leading +
        for (const pattern of DISABLE_PATTERNS) {
          if (pattern.test(content)) {
            findings.push(`${currentFile}: ${content.trim()}`);
            break;
          }
        }
      }

      if (findings.length === 0) return;

      const list = findings.map(f => `  ${f}`).join('\n');
      throw new Error(
        `\n❌ Lint disable comments found in staged changes:\n${list}\n\n` +
        `Lint disable comments are not allowed. Fix the underlying issues instead.`
      );
    },
  };
};
