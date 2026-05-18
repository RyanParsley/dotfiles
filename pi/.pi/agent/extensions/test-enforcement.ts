/**
 * Test Enforcement — Pi extension
 *
 * Auto-detects the test framework for a project, runs tests on file changes,
 * and blocks commits when tests are failing.
 */

import { existsSync } from "node:fs";
import { join } from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { isToolCallEventType } from "@mariozechner/pi-coding-agent";

const DEBOUNCE_MS = 2000;

interface TestResult {
  total: number;
  passed: number;
  failed: number;
  allPassed: boolean;
  output: string;
}

interface Framework {
  name: string;
  files: string[];
  run: (cwd: string, pi: ExtensionAPI) => Promise<TestResult | null>;
  watchPatterns: string[];
}

const FRAMEWORKS: Framework[] = [
  {
    name: "rust",
    files: ["Cargo.toml"],
    watchPatterns: [".rs"],
    async run(cwd, pi) {
      const result = await pi.exec("cargo", ["test"], { cwd });
      return parseCargoOutput(result);
    },
  },
  {
    name: "node",
    files: ["package.json"],
    watchPatterns: [".test.", ".spec.", "test/", "tests/", "__tests__/"],
    async run(cwd, pi) {
      const pkgManager = existsSync(join(cwd, "pnpm-lock.yaml"))
        ? "pnpm"
        : existsSync(join(cwd, "yarn.lock"))
          ? "yarn"
          : "npm";
      const result = await pi.exec(pkgManager, ["test"], { cwd });
      return parseGenericOutput(result, "node");
    },
  },
  {
    name: "python",
    files: ["pytest.ini", "pyproject.toml", "setup.py", "setup.cfg"],
    watchPatterns: ["test_", "_test.py", "tests/"],
    async run(cwd, pi) {
      const result = await pi.exec("python", ["-m", "pytest"], { cwd });
      return parseGenericOutput(result, "pytest");
    },
  },
  {
    name: "go",
    files: ["go.mod"],
    watchPatterns: ["_test.go"],
    async run(cwd, pi) {
      const result = await pi.exec("go", ["test", "./..."], { cwd });
      return parseGoOutput(result);
    },
  },
  {
    name: "ruby",
    files: [".rspec", "features/"],
    watchPatterns: ["_spec.rb", ".feature", "features/"],
    async run(cwd, pi) {
      if (existsSync(join(cwd, "features"))) {
        const result = await pi.exec("bundle", ["exec", "cucumber"], { cwd });
        return parseCucumberOutput(result);
      }
      const result = await pi.exec("bundle", ["exec", "rspec"], { cwd });
      return parseGenericOutput(result, "rspec");
    },
  },
];

function stringifyResult(result: { stdout?: string; stderr?: string; exitCode?: number }): string {
  return result.stdout || result.stderr || String(result.exitCode ?? "");
}

function parseCargoOutput(result: { stdout?: string; stderr?: string; exitCode?: number }): TestResult | null {
  const output = stringifyResult(result);
  const passMatch = output.match(/(\d+) passed/);
  const failMatch = output.match(/(\d+) failed/);
  const totalMatch = output.match(/running (\d+) test/);
  const total = totalMatch ? parseInt(totalMatch[1]) : 0;
  const passed = passMatch ? parseInt(passMatch[1]) : 0;
  const failed = failMatch ? parseInt(failMatch[1]) : 0;
  return { total, passed, failed, allPassed: failed === 0 && total > 0, output: output.slice(0, 500) };
}

function parseGoOutput(result: { stdout?: string; stderr?: string; exitCode?: number }): TestResult | null {
  const output = stringifyResult(result);
  const passMatch = output.match(/^(ok\s+\d+|[\s\S]*?PASS)/m);
  const failMatch = output.match(/^(FAIL|[\s\S]*?--- FAIL:)/m);
  const allPassed = !failMatch && !!passMatch;
  return { total: 1, passed: allPassed ? 1 : 0, failed: allPassed ? 0 : 1, allPassed, output: output.slice(0, 500) };
}

function parseCucumberOutput(result: { stdout?: string; stderr?: string; exitCode?: number }): TestResult | null {
  const output = stringifyResult(result);
  const scenariosMatch = output.match(/(\d+) scenarios? \((\d+) passed, (\d+) skipped, (\d+) failed\)/);
  if (!scenariosMatch) return null;
  const failed = parseInt(scenariosMatch[4]);
  const total = parseInt(scenariosMatch[1]);
  return { total, passed: parseInt(scenariosMatch[2]), failed, allPassed: failed === 0, output: output.slice(0, 500) };
}

function parseGenericOutput(result: { stdout?: string; stderr?: string; exitCode?: number }, _label: string): TestResult | null {
  const output = stringifyResult(result);
  const failMatch = output.match(/(\d+)\s+failed/) || output.match(/FAIL/) || output.match(/Error:/);
  const passMatch = output.match(/(\d+)\s+passed/) || output.match(/success/i) || output.match(/PASS/);
  const failed = failMatch ? parseInt(failMatch[1]) || 1 : 0;
  const passed = passMatch ? parseInt(passMatch[1]) || 1 : 0;
  return { total: passed + failed, passed, failed, allPassed: failed === 0 && passed > 0, output: output.slice(0, 500) };
}

function detectFramework(directory: string): Framework | null {
  for (const fw of FRAMEWORKS) {
    if (fw.files.some((f) => existsSync(join(directory, f)))) {
      return fw;
    }
  }
  return null;
}

function isWatchedFile(filePath: string, framework: Framework): boolean {
  if (!filePath) return false;
  return framework.watchPatterns.some((pattern) => filePath.includes(pattern));
}

function isGitCommitCommand(command: string): boolean {
  return (
    command.includes("git commit") &&
    !command.includes("git commit --amend") &&
    !command.includes("--dry-run")
  );
}

export default function (pi: ExtensionAPI) {
  let framework: Framework | null = null;
  let lastResult: TestResult | null = null;
  let lastRunTime = 0;
  let isRunning = false;

  pi.on("session_start", async (_event, ctx) => {
    framework = detectFramework(ctx.cwd);
    if (framework) {
      ctx.ui.notify(`Detected ${framework.name} test framework — auto-test enabled`, "info");
    }
  });

  async function runTests(cwd: string) {
    if (!framework) return;
    const now = Date.now();
    if (now - lastRunTime < DEBOUNCE_MS || isRunning) return;
    isRunning = true;
    lastRunTime = now;

    try {
      const result = await framework.run(cwd, pi);
      lastResult = result;

      if (result) {
        if (result.failed > 0) {
          ctx.ui.notify(`${result.failed} test(s) failing — ${framework.name}`, "error");
        } else if (result.passed > 0) {
          ctx.ui.notify(`${result.passed} test(s) passing — ${framework.name}`, "info");
        }
      }
    } catch (e) {
      lastResult = null;
      ctx.ui.notify(`Test run failed: ${e instanceof Error ? e.message : String(e)}`, "error");
    } finally {
      isRunning = false;
    }
  }

  // Auto-run on watched file changes
  pi.on("file.edited", async (event, ctx) => {
    if (!framework) return;
    const filePath = event.path || "";
    if (isWatchedFile(filePath, framework)) {
      await runTests(ctx.cwd);
    }
  });

  // Pre-commit gate
  pi.on("tool_call", async (event, ctx) => {
    if (!framework) return;
    if (!isToolCallEventType("bash", event)) return;

    const command = event.input.command || "";
    if (!isGitCommitCommand(command)) return;

    // Re-run fresh before allowing commit
    await runTests(ctx.cwd);

    if (lastResult && !lastResult.allPassed) {
      const { failed, passed, total } = lastResult;
      return {
        block: true,
        reason:
          `Test enforcement: ${failed} test(s) failing (${passed}/${total} passing).\n` +
          `Fix the failing tests before committing.`,
      };
    }
  });
}
