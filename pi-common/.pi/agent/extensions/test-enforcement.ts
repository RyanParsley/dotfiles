/**
 * Test Enforcement — Pi extension
 *
 * Auto-detects the test framework for a project, runs tests on file changes,
 * and blocks commits when tests are failing.
 *
 * Both the watcher and the commit gate resolve the repository the work is
 * happening in rather than assuming the session's working directory: an agent
 * commits from `git worktree` checkouts all day, and grading the session
 * checkout would report on code the commit does not contain.
 */

import { existsSync } from "node:fs";
import { dirname, isAbsolute, join, resolve } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

const DEBOUNCE_MS = 2000;

interface TestResult {
  total: number;
  passed: number;
  failed: number;
  allPassed: boolean;
  /** The run was killed (timeout/abort): nothing was proven either way. */
  inconclusive: boolean;
  output: string;
  /** Repository the suite actually ran in. */
  root: string;
}

interface ExecLike {
  stdout?: string;
  stderr?: string;
  /** pi.exec reports the status as `code`; `killed` distinguishes a timeout. */
  code?: number;
  killed?: boolean;
}

interface Framework {
  name: string;
  files: string[];
  run: (cwd: string, pi: ExtensionAPI) => Promise<TestResult | null>;
  watchPatterns: string[];
}

function outputOf(result: ExecLike): string {
  return result.stdout || result.stderr || String(result.code ?? "");
}

function intGroup(pattern: RegExp, text: string): number {
  const match = pattern.exec(text);
  return match ? Number.parseInt(match[1], 10) || 0 : 0;
}

/**
 * Exit code is ground truth. A build that never produced test counts (a missing
 * system dependency, for example) must not be mistaken for "nothing failed".
 */
function green(result: ExecLike, failed: number): boolean {
  return result.code === 0 && failed === 0;
}

export function parseCargoOutput(result: ExecLike, root = ""): TestResult {
  const output = outputOf(result);
  const failed = intGroup(/(\d+)\s+failed/, output);
  return {
    total: intGroup(/running (\d+) test/, output),
    passed: intGroup(/(\d+)\s+passed/, output),
    failed,
    allPassed: green(result, failed),
    inconclusive: result.killed === true,
    output: output.slice(0, 500),
    root,
  };
}

function parseGoOutput(result: ExecLike, root = ""): TestResult {
  const output = outputOf(result);
  const failed = (output.match(/^FAIL/gm) || []).length + (output.match(/--- FAIL:/g) || []).length;
  return {
    total: 1,
    passed: failed === 0 ? 1 : 0,
    failed,
    allPassed: green(result, failed),
    inconclusive: result.killed === true,
    output: output.slice(0, 500),
    root,
  };
}

export function parseGenericOutput(result: ExecLike, root = ""): TestResult {
  const output = outputOf(result);
  const plain = output.replace(/\x1b\[[0-9;]*m/g, "");
  // Vitest and Jest print a Tests summary. Do not count numbers in test logs
  // (e.g. "Loading chunk 123 failed") or Vitest's separate Test Files summary.
  const summary = /^\s*Tests:?\s+([^\n]*)/m.exec(plain)?.[1];
  const failed = summary
    ? intGroup(/(\d+)\s+failed/, summary)
    : result.code === 0 ? 0 : intGroup(/(\d+)\s+failed/, plain) || (/(^|\n)FAIL|Error:/.test(plain) ? 1 : 0);
  const passed = intGroup(/(\d+)\s+passed/, summary ?? plain) || (/success|PASS/.test(plain) ? 1 : 0);
  return {
    total: passed + failed,
    passed,
    failed,
    allPassed: green(result, failed),
    inconclusive: result.killed === true,
    output: output.slice(0, 500),
    root,
  };
}

/**
 * Cucumber reports a summary line; when it is absent the run is inconclusive
 * rather than failed, so the caller decides what to say.
 */
function parseCucumberOutput(result: ExecLike, root = ""): TestResult | null {
  const output = outputOf(result);
  const scenarios = output.match(/(\d+) scenarios? \((\d+) passed, (\d+) skipped, (\d+) failed\)/);
  if (!scenarios) {
    if (result.code === 0 && result.killed !== true) return null;
    return {
      total: 0,
      passed: 0,
      failed: 1,
      allPassed: false,
      inconclusive: result.killed === true,
      output: output.slice(0, 500),
      root,
    };
  }
  const failed = Number.parseInt(scenarios[4], 10);
  return {
    total: Number.parseInt(scenarios[1], 10),
    passed: Number.parseInt(scenarios[2], 10),
    failed,
    allPassed: green(result, failed),
    inconclusive: result.killed === true,
    output: output.slice(0, 500),
    root,
  };
}

const FRAMEWORKS: Framework[] = [
  {
    name: "rust",
    files: ["Cargo.toml"],
    watchPatterns: [".rs"],
    async run(cwd, pi) {
      const result = await pi.exec("cargo", ["test"], { cwd });
      return parseCargoOutput(result, cwd);
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
      return parseGenericOutput(result, cwd);
    },
  },
  {
    name: "python",
    files: ["pytest.ini", "pyproject.toml", "setup.py", "setup.cfg"],
    watchPatterns: ["test_", "_test.py", "tests/"],
    async run(cwd, pi) {
      const result = await pi.exec("python", ["-m", "pytest"], { cwd });
      return parseGenericOutput(result, cwd);
    },
  },
  {
    name: "go",
    files: ["go.mod"],
    watchPatterns: ["_test.go"],
    async run(cwd, pi) {
      const result = await pi.exec("go", ["test", "./..."], { cwd });
      return parseGoOutput(result, cwd);
    },
  },
  {
    name: "ruby",
    files: [".rspec", "features/"],
    watchPatterns: ["_spec.rb", ".feature", "features/"],
    async run(cwd, pi) {
      if (existsSync(join(cwd, "features"))) {
        const result = await pi.exec("bundle", ["exec", "cucumber"], { cwd });
        return parseCucumberOutput(result, cwd);
      }
      const result = await pi.exec("bundle", ["exec", "rspec"], { cwd });
      return parseGenericOutput(result, cwd);
    },
  },
];

/** True when the command is a fresh commit (amend and dry-run are not gated). */
export function isGitCommitCommand(command: string): boolean {
  return command.includes("git commit") && !command.includes("--amend") && !command.includes("--dry-run");
}

/**
 * Directory a command changes into before running, e.g. the `/work/tree` in
 * `cd /work/tree && git commit`. Returns null when the command does not move.
 */
export function commandWorkdir(command: string): string | null {
  const match = /^\s*cd\s+(?:"([^"]+)"|'([^']+)'|([^\s;&|]+))\s*(?:&&|\|\||;|\n)/.exec(command);
  if (!match) return null;
  return match[1] ?? match[2] ?? match[3] ?? null;
}

export function detectFramework(directory: string): Framework | null {
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

function absoluteIn(cwd: string, filePath: string): string {
  return isAbsolute(filePath) ? filePath : resolve(cwd, filePath);
}

export default function (pi: ExtensionAPI) {
  const frameworkByRoot = new Map<string, Framework | null>();
  const lastResult = new Map<string, TestResult>();
  const lastRunAt = new Map<string, number>();
  const inFlight = new Map<string, Promise<TestResult | null>>();

  function frameworkFor(root: string): Framework | null {
    const cached = frameworkByRoot.get(root);
    if (cached !== undefined) return cached;
    const detected = detectFramework(root);
    frameworkByRoot.set(root, detected);
    return detected;
  }

  /** Git toplevel containing `dir`, so subdirectories grade the whole repo. */
  async function repoRootOf(dir: string, fallback: string): Promise<string> {
    try {
      const result = await pi.exec("git", ["rev-parse", "--show-toplevel"], { cwd: dir });
      const root = result.stdout?.trim();
      if (root) return root;
    } catch {
      // Not a repository (or git unavailable) — fall through.
    }
    return fallback;
  }

  async function runTests(root: string, ctx: ExtensionContext, force = false): Promise<TestResult | null> {
    const framework = frameworkFor(root);
    if (!framework) return null;

    const pending = inFlight.get(root);
    if (pending) {
      // Wait for the run already in progress rather than grading a commit
      // against a result produced from an older tree.
      return force ? await pending : (lastResult.get(root) ?? null);
    }
    if (!force && Date.now() - (lastRunAt.get(root) ?? 0) < DEBOUNCE_MS) {
      return lastResult.get(root) ?? null;
    }

    lastRunAt.set(root, Date.now());
    const run = framework.run(root, pi);
    inFlight.set(root, run);
    try {
      const result = await run;
      if (!result) {
        ctx.ui.notify(`${framework.name}: no parseable test summary from ${root} — not blocking`, "info");
        lastResult.delete(root);
        return null;
      }
      lastResult.set(root, result);
      if (result.inconclusive) {
        ctx.ui.notify(`${framework.name} run did not finish in ${root}`, "info");
      } else if (!result.allPassed) {
        ctx.ui.notify(`${framework.name} tests failing in ${root} (${result.failed} failing)`, "error");
      } else if (result.passed > 0) {
        ctx.ui.notify(`${result.passed} ${framework.name} test(s) passing in ${root}`, "info");
      } else {
        ctx.ui.notify(`${framework.name} tests green in ${root} (no tests executed)`, "info");
      }
      return result;
    } catch (error) {
      lastResult.delete(root);
      ctx.ui.notify(`Test run failed in ${root}: ${error instanceof Error ? error.message : String(error)}`, "error");
      return null;
    } finally {
      inFlight.delete(root);
    }
  }

  pi.on("session_start", async (_event, ctx) => {
    const root = await repoRootOf(ctx.cwd, ctx.cwd);
    const framework = frameworkFor(root);
    if (framework) {
      ctx.ui.notify(`Detected ${framework.name} test framework in ${root} — auto-test enabled`, "info");
    }
  });

  pi.on("file.edited", async (event, ctx) => {
    const filePath = event.path || "";
    if (!filePath) return;
    const root = await repoRootOf(dirname(absoluteIn(ctx.cwd, filePath)), ctx.cwd);
    const framework = frameworkFor(root);
    if (!framework || !isWatchedFile(filePath, framework)) return;
    await runTests(root, ctx);
  });

  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return;

    const command: string = event.input?.command || "";
    if (!isGitCommitCommand(command)) return;

    const startDir = commandWorkdir(command);
    const cwd = startDir ? absoluteIn(ctx.cwd, startDir) : ctx.cwd;
    const root = await repoRootOf(cwd, cwd);

    const framework = frameworkFor(root);
    if (!framework) {
      ctx.ui.notify(`No supported test framework at ${root} — commit not gated`, "info");
      return;
    }

    const result = await runTests(root, ctx, true);
    if (result?.inconclusive) {
      ctx.ui.notify(`Test run did not finish in ${root} — commit not gated`, "info");
      return;
    }
    if (result && !result.allPassed) {
      return {
        block: true,
        reason:
          `Test enforcement: ${result.failed} test(s) failing in ${result.root} ` +
          `(${result.passed}/${result.total} reported passing).\n` +
          `Fix the failing tests — or the build, when no counts appear — before committing.\n\n` +
          `${result.output}`,
      };
    }
  });
}