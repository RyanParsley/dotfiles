/**
 * Test Enforcement Plugin
 *
 * Auto-detects the test framework for a project and provides helpful
 * test-running and pre-commit gating. Never lectures. Only activates
 * when a known framework is detected.
 *
 * Supports: Rust (cargo), Node (npm/pnpm/yarn), Python (pytest),
 * Go (go test), Ruby (rspec/cucumber).
 *
 * Install: Place in ~/.config/opencode/plugins/test-enforcement.js
 * Enable: Add "test-enforcement" to plugins array in opencode.json
 */

import { existsSync } from "fs";
import { join } from "path";

const DEBOUNCE_MS = 2000;

// Framework detection rules: ordered by specificity
const FRAMEWORKS = [
  {
    name: "rust",
    files: ["Cargo.toml"],
    run: async ($, dir) => {
      const result = await $`cargo test 2>&1`.cwd(dir).nothrow();
      return parseCargoOutput(result);
    },
    watchPatterns: [".rs"],
  },
  {
    name: "node",
    files: ["package.json"],
    run: async ($, dir) => {
      // Prefer pnpm > yarn > npm
      const pkgManager = existsSync(join(dir, "pnpm-lock.yaml"))
        ? "pnpm"
        : existsSync(join(dir, "yarn.lock"))
          ? "yarn"
          : "npm";
      const result = await $`${pkgManager} test 2>&1`.nothrow();
      return parseGenericOutput(result, "node");
    },
    watchPatterns: [".test.", ".spec.", "test/", "tests/", "__tests__/"],
  },
  {
    name: "python",
    files: ["pytest.ini", "pyproject.toml", "setup.py", "setup.cfg"],
    run: async ($) => {
      const result = await $`python -m pytest 2>&1`.nothrow();
      return parseGenericOutput(result, "pytest");
    },
    watchPatterns: ["test_", "_test.py", "tests/"],
  },
  {
    name: "go",
    files: ["go.mod"],
    run: async ($) => {
      const result = await $`go test ./... 2>&1`.nothrow();
      return parseGoOutput(result);
    },
    watchPatterns: ["_test.go"],
  },
  {
    name: "ruby",
    files: [".rspec", "features/"],
    run: async ($, dir) => {
      if (existsSync(join(dir, "features"))) {
        const result = await $`bundle exec cucumber 2>&1`.nothrow();
        return parseCucumberOutput(result);
      }
      const result = await $`bundle exec rspec 2>&1`.nothrow();
      return parseGenericOutput(result, "rspec");
    },
    watchPatterns: ["_spec.rb", ".feature", "features/"],
  },
];

function parseCargoOutput(result) {
  const output = stringify(result);
  const passMatch = output.match(/(\d+) passed/);
  const failMatch = output.match(/(\d+) failed/);
  const totalMatch = output.match(/running (\d+) test/);
  const total = totalMatch ? parseInt(totalMatch[1]) : 0;
  const passed = passMatch ? parseInt(passMatch[1]) : 0;
  const failed = failMatch ? parseInt(failMatch[1]) : 0;
  return {
    total,
    passed,
    failed,
    allPassed: failed === 0 && total > 0,
    output: output.slice(0, 500),
  };
}

function parseGoOutput(result) {
  const output = stringify(result);
  const passMatch = output.match(/^(ok\s+\d+|[\s\S]*?PASS)/m);
  const failMatch = output.match(/^(FAIL|[\s\S]*?--- FAIL:)/m);
  const allPassed = !failMatch && passMatch;
  return {
    total: null,
    passed: allPassed ? 1 : 0,
    failed: allPassed ? 0 : 1,
    allPassed,
    output: output.slice(0, 500),
  };
}

function parseCucumberOutput(result) {
  const output = stringify(result);
  const scenariosMatch = output.match(
    /(\d+) scenarios? \((\d+) passed, (\d+) skipped, (\d+) failed\)/,
  );
  const stepsMatch = output.match(
    /(\d+) steps? \((\d+) passed, (\d+) skipped, (\d+) failed\)/,
  );
  if (!scenariosMatch) return null;
  const failed = parseInt(scenariosMatch[4]);
  const total = parseInt(scenariosMatch[1]);
  return {
    total,
    passed: parseInt(scenariosMatch[2]),
    skipped: parseInt(scenariosMatch[3]),
    failed,
    allPassed: failed === 0,
    output: output.slice(0, 500),
  };
}

function parseGenericOutput(result, label) {
  const output = stringify(result);
  // Heuristic: look for common pass/fail indicators
  const failMatch =
    output.match(/(\d+)\s+failed/) ||
    output.match(/FAIL/) ||
    output.match(/Error:/);
  const passMatch =
    output.match(/(\d+)\s+passed/) ||
    output.match(/success/i) ||
    output.match(/PASS/);
  const failed = failMatch ? parseInt(failMatch[1]) || 1 : 0;
  const passed = passMatch ? parseInt(passMatch[1]) || 1 : 0;
  return {
    total: passed + failed,
    passed,
    failed,
    allPassed: failed === 0 && passed > 0,
    output: output.slice(0, 500),
  };
}

function stringify(result) {
  return result.stdout
    ? result.stdout.toString()
    : result.stderr
      ? result.stderr.toString()
      : String(result);
}

function detectFramework(directory) {
  for (const fw of FRAMEWORKS) {
    if (fw.files.some((f) => existsSync(join(directory, f)))) {
      return fw;
    }
  }
  return null;
}

function isWatchedFile(filePath, framework) {
  if (!filePath) return false;
  return framework.watchPatterns.some((pattern) =>
    filePath.includes(pattern),
  );
}

function isGitCommitCommand(args) {
  if (!args || !args.command) return false;
  const cmd = args.command;
  return (
    cmd.includes("git commit") &&
    !cmd.includes("git commit --amend") &&
    !cmd.includes("--dry-run")
  );
}

export const TestEnforcement = async ({ client, directory, $ }) => {
  let framework = detectFramework(directory);
  let lastResult = null;
  let lastRunTime = 0;
  let isRunning = false;

  if (!framework) {
    // Quietly exit: no test framework detected
    return {};
  }

  await client.app.log({
    body: {
      service: "test-enforcement",
      level: "info",
      message: `Detected ${framework.name} test framework — auto-test enabled`,
    },
  });

  async function runTests() {
    const now = Date.now();
    if (now - lastRunTime < DEBOUNCE_MS || isRunning) return;
    isRunning = true;
    lastRunTime = now;

    try {
      const result = await framework.run($, directory);
      lastResult = result;

      if (result) {
        const status = result.failed > 0 ? "warn" : "info";
        const message =
          result.failed > 0
            ? `${result.failed} test(s) failing — ${framework.name}`
            : result.passed > 0
              ? `${result.passed} test(s) passing — ${framework.name}`
              : `Tests ran — no results parsed — ${framework.name}`;

        await client.app.log({
          body: {
            service: "test-enforcement",
            level: status,
            message,
            extra: {
              framework: framework.name,
              passed: result.passed,
              failed: result.failed,
              total: result.total,
            },
          },
        });
      }
    } catch (e) {
      lastResult = null;
      await client.app.log({
        body: {
          service: "test-enforcement",
          level: "error",
          message: `Test run failed: ${e.message}`,
        },
      });
    } finally {
      isRunning = false;
    }
  }

  return {
    // Auto-run on watched file changes
    event: async ({ event }) => {
      if (event?.type === "file.edited" && event.file?.path) {
        if (isWatchedFile(event.file.path, framework)) {
          await runTests();
        }
      }
    },

    // Pre-commit gate: only if we have a failing result
    "tool.execute.before": async (input) => {
      if (input.tool !== "bash") return;
      const command = input.args?.command || "";
      if (!isGitCommitCommand(input.args)) return;

      // Re-run fresh before allowing commit
      await runTests();

      if (lastResult && !lastResult.allPassed) {
        const { failed, passed, total } = lastResult;
        const msg =
          `Test enforcement: ${failed} test(s) failing (${passed}/${total} passing).\n` +
          `Fix the failing tests before committing.`;
        throw new Error(msg);
      }
    },
  };
};
