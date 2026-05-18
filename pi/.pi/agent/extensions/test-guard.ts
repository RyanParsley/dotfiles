import { existsSync } from "node:fs";
import { join } from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

function isGitPushCommand(command: string): boolean {
  if (!command) return false;
  const cmd = command.toLowerCase();
  return cmd.includes("git push");
}

function detectTestFramework(cwd: string): string | null {
  // Rust
  if (existsSync(join(cwd, "Cargo.toml"))) {
    return "rust (cargo test)";
  }
  // Node
  if (existsSync(join(cwd, "package.json"))) {
    return "node (npm test)";
  }
  // Python
  if (existsSync(join(cwd, "pytest.ini")) || existsSync(join(cwd, "pyproject.toml"))) {
    return "python (pytest)";
  }
  // Go
  if (existsSync(join(cwd, "go.mod"))) {
    return "go (go test)";
  }
  return null;
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    // Only intercept bash tool
    if (event.toolName !== "bash") return;

    const command = event.input?.command || "";
    if (!isGitPushCommand(command)) return;

    const cwd = ctx.cwd || process.cwd();
    const framework = detectTestFramework(cwd);

    if (!framework) {
      ctx.ui.notify("No test framework detected - allowing push", "info");
      return;
    }

    // Block the push and require manual test confirmation
    ctx.ui.notify(`Test enforcement: ${framework} detected. Run tests before pushing.`, "warning");
    
    return {
      block: true,
      reason: `Test enforcement active for ${framework}. Run tests manually before pushing:\n` +
        `- Rust: cargo test\n` +
        `- Node: npm test\n` +
        `- Python: pytest\n` +
        `- Go: go test ./...`,
    };
  });
}