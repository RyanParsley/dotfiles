/**
 * TDD Enforcement — Pi extension
 *
 * Blocks editing a source file that has no test surface, so behaviour changes
 * land with tests (AGENTS.md "Definition of Done").
 *
 * Rust keeps tests in three shapes, only one of which is a `<file>_test.rs`
 * sibling: an inline `#[cfg(test)] mod tests`, a `<crate>/tests/<name>.rs`
 * integration test, or a `<crate>/tests/<name>/` test module directory. All
 * three count as evidence, so idiomatic Rust is not blocked. When a file has
 * no evidence at all the edit is refused — that is the guard working as
 * intended, and the fix is to add the test first.
 *
 * Only Rust and TypeScript are policed, because those are the layouts this
 * guard understands. Build files, docs and data have no test-surface notion
 * here at all: "I do not know where the tests for this would live" must never
 * be reported as "there are no tests for this".
 */

import { existsSync, readFileSync, readdirSync } from "node:fs";
import { basename, dirname, isAbsolute, join } from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

function blockMessage(sourcePath: string, lookedFor: string[]): string {
  const candidates = lookedFor.map((candidate) => `  - ${candidate}`).join("\n");
  return (
    `No test surface exists for ${sourcePath}.\n\n` +
    `Looked for:\n${candidates}\n\n` +
    "RULES (per AGENTS.md 'Definition of Done'):\n" +
    "- New component/widget: at least one snapshot test\n" +
    "- New function/method: unit tests for happy path + edge cases\n" +
    "- Bug fix: regression test that would have caught the bug\n\n" +
    "Write tests BEFORE changing source.\n" +
    "The test IS the log - don't add prints, add assertions."
  );
}

export function resolveSourcePath(cwd: string, filePath: string): string {
  return isAbsolute(filePath) ? filePath : join(cwd, filePath);
}

/**
 * True when the path is itself test or specification code.
 *
 * Matches on path segments and filename shapes rather than a substring, so a
 * module merely *named* around the word (untested.rs, latest.rs, contest.rs)
 * does not exempt itself from the guard.
 */
export function isTestPath(filePath: string): boolean {
  const parts = filePath.split(/[/\\]/).filter(Boolean);
  const file = parts[parts.length - 1] ?? "";
  const stem = file.replace(/\.[^.]+$/, "");

  if (file.endsWith(".feature")) return true;
  if (/\.(test|spec|cy)\.[cm]?[jt]sx?$/.test(file)) return true;
  if (/^test_.+$/.test(stem) || /.+_test$/.test(stem)) return true;

  return parts
    .slice(0, -1)
    .some((dir) => ["test", "tests", "spec", "specs", "__tests__", "features"].includes(dir));
}

/** Languages whose test layout this guard can reason about. */
export function isTrackedSource(filePath: string): boolean {
  return filePath.endsWith(".rs") || filePath.endsWith(".ts") || filePath.endsWith(".tsx");
}

/** Nearest ancestor directory holding a Cargo.toml, i.e. the crate root. */
export function crateRootOf(sourcePath: string): string | null {
  let dir = dirname(sourcePath);
  for (;;) {
    if (existsSync(join(dir, "Cargo.toml"))) return dir;
    const parent = dirname(dir);
    if (parent === dir) return null;
    dir = parent;
  }
}

function hasInlineRustTests(sourcePath: string): boolean {
  try {
    const source = readFileSync(sourcePath, "utf8");
    // `test` as a cfg predicate anywhere in the attribute: matches
    // `#[cfg(test)]` and gated forms like `#[cfg(all(test, feature = "ssr"))]`,
    // while a `test-utils` feature gate (not test code) does not qualify.
    return /#\s*\[\s*cfg\s*\([^#\]]*\btest\b(?!-)[^#\]]*\)\s*\]/.test(source);
  } catch {
    return false;
  }
}

function directoryHasRustFiles(dir: string, depth = 3): boolean {
  try {
    return readdirSync(dir, { withFileTypes: true }).some((entry) => {
      if (entry.isFile()) return entry.name.endsWith(".rs");
      // Cargo test targets may live in subdirectories (tests/e2e/main.rs),
      // so look a few levels down rather than only at direct children.
      return depth > 0 && entry.isDirectory()
        ? directoryHasRustFiles(join(dir, entry.name), depth - 1)
        : false;
    });
  } catch {
    return false;
  }
}

export function findRustTestEvidence(sourcePath: string): string | null {
  const dir = dirname(sourcePath);
  const stem = basename(sourcePath, ".rs");

  const sibling = join(dir, `${stem}_test.rs`);
  if (existsSync(sibling)) return sibling;

  if (hasInlineRustTests(sourcePath)) return `${sourcePath}: #[cfg(test)] mod tests`;

  const crate = crateRootOf(sourcePath);
  if (!crate) return null;

  const integrationFile = join(crate, "tests", `${stem}.rs`);
  if (existsSync(integrationFile)) return integrationFile;

  const integrationDir = join(crate, "tests", stem);
  if (existsSync(integrationDir)) return integrationDir;

  const testsDir = join(crate, "tests");
  if (directoryHasRustFiles(testsDir)) return `${testsDir}: crate-level integration tests`;

  return null;
}

export function findTypeScriptTestEvidence(sourcePath: string): string | null {
  const base = sourcePath.replace(/\.tsx?$/, "");
  const stem = basename(base, ".tsx");
  const candidates = [
    `${base}.test.ts`,
    `${base}.spec.ts`,
    join(dirname(base), "__tests__", `${stem}.test.ts`),
    join(dirname(base), "..", "tests", `${stem}.test.ts`),
  ];
  return candidates.find((candidate) => existsSync(candidate)) ?? null;
}

/** Returns a description of the test surface, or null when there is none. */
export function findTestEvidence(sourcePath: string): string | null {
  if (sourcePath.endsWith(".rs")) return findRustTestEvidence(sourcePath);
  if (sourcePath.endsWith(".ts") || sourcePath.endsWith(".tsx")) {
    return findTypeScriptTestEvidence(sourcePath);
  }
  return null;
}

function lookedForCandidates(sourcePath: string): string[] {
  if (sourcePath.endsWith(".rs")) {
    const dir = dirname(sourcePath);
    const stem = basename(sourcePath, ".rs");
    const crate = crateRootOf(sourcePath);
    return [
      join(dir, `${stem}_test.rs`),
      `${sourcePath} containing #[cfg(test)]`,
      ...(crate ? [join(crate, "tests", `${stem}.rs`), join(crate, "tests")] : []),
    ];
  }
  if (sourcePath.endsWith(".ts") || sourcePath.endsWith(".tsx")) {
    const base = sourcePath.replace(/\.tsx?$/, "");
    return [`${base}.test.ts`, `${base}.spec.ts`];
  }
  return [];
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    const tool = event.toolName;
    if (tool !== "write" && tool !== "edit") return;

    const filePath = event.input?.path || event.input?.filePath || "";
    if (!filePath) return;

    if (isTestPath(filePath)) return;
    if (filePath.includes("vendor") || filePath.includes("node_modules")) return;

    const sourcePath = resolveSourcePath(ctx.cwd, filePath);
    if (!isTrackedSource(sourcePath)) return;
    if (findTestEvidence(sourcePath)) return;

    // A brand new file can be created alongside the test that covers it, so an
    // absent file only blocks when the crate/module has no test surface at all.
    return { block: true, reason: blockMessage(sourcePath, lookedForCandidates(sourcePath)) };
  });
}
