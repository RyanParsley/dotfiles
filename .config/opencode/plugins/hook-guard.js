/**
 * Hook Guard Plugin — Global protection against hook bypasses
 *
 * Blocks ALL attempts to bypass git hooks via --no-verify or other mechanisms.
 * This is a HARD guard — it throws and blocks execution.
 *
 * Install: Symlink or copy to ~/.config/opencode/plugins/hook-guard.js
 * Enable: Add "hook-guard" to plugins array in ~/.config/opencode/opencode.json
 */

const BYPASS_PATTERNS = [
  // --no-verify variants
  /--no-verify/,
  /--no-verify/,
  // Hooks path overrides
  /-c\s+core\.hooksPath\s*=/,
  /-c\s+core\.hooksPath\s*=/,
  // Direct git command with hook bypass env
  /GIT_CONFIG_GLOBAL\s*=/,
  /GIT_CONFIG_SYSTEM\s*=/,
];

const BYPASS_MESSAGE = `\n╔══════════════════════════════════════════════════════════════════╗
║  HOOK BYPASS BLOCKED                                             ║
╠══════════════════════════════════════════════════════════════════╣
║  You are NEVER allowed to bypass git hooks.                      ║
║                                                                  ║
║  Remove --no-verify, --no-verify, or any hook bypass flag        ║
║  and fix the ACTUAL problem instead.                             ║
║                                                                  ║
║  The lefthook pre-commit/pre-push hooks are there to catch       ║
║  exactly the mistakes you're about to make. Do not defeat them.  ║
╚══════════════════════════════════════════════════════════════════╝\n`;

export const HookGuard = async ({ client }) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return;

      const command = input.args?.command || "";

      for (const pattern of BYPASS_PATTERNS) {
        if (pattern.test(command)) {
          await client.app.log({
            body: {
              service: "hook-guard",
              level: "error",
              message: "Hook bypass attempt blocked",
              extra: { command: command.slice(0, 200) },
            },
          });

          throw new Error(BYPASS_MESSAGE);
        }
      }
    },
  };
};
