import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { commandWorkdir, findLintDisables } from "../extensions/lint-enforcement.ts";

const DIFF = [
  "--- a/crates/core/src/lib.rs",
  "+++ b/crates/core/src/lib.rs",
  "@@ -10,0 +11,3 @@",
  "+#![allow(dead_code)]",
  "+let value = compute();",
  "+// eslint-disable-next-line no-console",
  "--- a/README.md",
  "+++ b/README.md",
  "@@ -1,0 +2 @@",
  "+docs only",
].join("\n");

describe("findLintDisables", () => {
  it("reports added suppressions with their file", () => {
    const findings = findLintDisables(DIFF);
    assert.equal(findings.length, 2);
    assert.match(findings[0], /crates\/core\/src\/lib\.rs: #!\[allow\(dead_code\)\]/);
    assert.match(findings[1], /eslint-disable-next-line/);
  });

  it("ignores context lines, removals, and untracked file types", () => {
    assert.deepEqual(findLintDisables("--- a/x.md\n+++ b/x.md\n+#[allow(dead_code)]"), []);
    assert.deepEqual(findLintDisables("--- a/a.rs\n+++ b/a.rs\n-#[allow(dead_code)]"), []);
    assert.deepEqual(findLintDisables(""), []);
  });

  it("catches clippy and rustfmt suppressions in added source lines", () => {
    const diff = ["+++ b/src/lib.rs", "+#[expect(clippy::too_many_lines)]", "+// clippy::allow"].join("\n");
    assert.equal(findLintDisables(diff).length, 2);
  });
});

describe("commandWorkdir", () => {
  it("reads the directory a chained cd runs the commit in", () => {
    assert.equal(commandWorkdir("cd /wt && git commit -F msg"), "/wt");
    assert.equal(commandWorkdir('cd "/wt two" && git commit'), "/wt two");
  });

  it("returns null when the command does not change directory", () => {
    assert.equal(commandWorkdir("git commit -m x"), null);
  });
});
