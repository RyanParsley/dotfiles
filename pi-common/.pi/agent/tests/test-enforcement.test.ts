import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { commandWorkdir, isGitCommitCommand, parseCargoOutput, parseGenericOutput } from "../extensions/test-enforcement.ts";

describe("commandWorkdir", () => {
  it("reads the directory a chained cd runs the commit in", () => {
    assert.equal(commandWorkdir("cd /repo-wt && git commit -m x"), "/repo-wt");
    assert.equal(commandWorkdir('cd "/repo wt" && git commit -m x'), "/repo wt");
    assert.equal(commandWorkdir("cd '/repo wt' && git commit"), "/repo wt");
    assert.equal(commandWorkdir("cd .. && git commit"), "..");
    assert.equal(commandWorkdir("cd /repo-wt; git commit"), "/repo-wt");
  });

  it("returns null when the command does not change directory", () => {
    assert.equal(commandWorkdir("git commit -m x"), null);
    assert.equal(commandWorkdir("echo 'cd /not-a-directory-prefix'"), null);
    assert.equal(commandWorkdir("cargo test && git commit"), null);
  });
});

describe("isGitCommitCommand", () => {
  it("matches plain commits and ignores amend/dry-run", () => {
    assert.equal(isGitCommitCommand("git commit -m x"), true);
    assert.equal(isGitCommitCommand("cd /wt && git commit -F msg"), true);
    assert.equal(isGitCommitCommand("git commit --amend --no-edit"), false);
    assert.equal(isGitCommitCommand("git commit --dry-run"), false);
    assert.equal(isGitCommitCommand("cargo test"), false);
  });
});

describe("parseGenericOutput", () => {
  it("uses the Vitest test summary instead of logged failure text or file counts", () => {
    const result = parseGenericOutput({
      code: 0,
      stdout: [
        "stderr | should not cause page reload",
        "{ message: 'Loading chunk 123 failed' }",
        "Test Files  12 passed (12)",
        "     Tests  30 passed (30)",
      ].join("\n"),
    });

    assert.equal(result.failed, 0);
    assert.equal(result.passed, 30);
    assert.equal(result.allPassed, true);
  });

  it("still blocks a genuinely failing Vitest summary", () => {
    const result = parseGenericOutput({
      code: 1,
      stdout: "Test Files  1 failed | 11 passed (12)\n     Tests  1 failed | 29 passed (30)",
    });

    assert.equal(result.failed, 1);
    assert.equal(result.passed, 29);
    assert.equal(result.allPassed, false);
  });

  it("does not turn a zero-exit run's logged error message into a failure", () => {
    const result = parseGenericOutput({ code: 0, stdout: "Error: expected failure case\nPASS" });
    assert.equal(result.failed, 0);
    assert.equal(result.allPassed, true);
  });
});

describe("parseCargoOutput", () => {
  it("treats a passing run as passing", () => {
    const result = parseCargoOutput({
      code: 0,
      stdout: "running 10 tests\ntest result: ok. 10 passed; 0 failed; 0 ignored",
    });
    assert.equal(result.allPassed, true);
    assert.equal(result.passed, 10);
    assert.equal(result.failed, 0);
  });

  it("treats failing tests as failing", () => {
    const result = parseCargoOutput({
      code: 101,
      stdout: "test result: FAILED. 9 passed; 1 failed; 0 ignored",
    });
    assert.equal(result.allPassed, false);
    assert.equal(result.failed, 1);
  });

  it("treats a build failure as failing even though no test counts appear", () => {
    const result = parseCargoOutput({
      code: 101,
      stderr: "error: could not find directory of OpenSSL installation",
    });
    assert.equal(result.allPassed, false);
    assert.equal(result.total, 0);
    assert.match(result.output, /OpenSSL/);
  });

  it("treats a green run with nothing to execute as passing", () => {
    const result = parseCargoOutput({ code: 0, stdout: "running 0 tests" });
    assert.equal(result.allPassed, true);
    assert.equal(result.total, 0);
  });

  it("reports a missing exit code as unverified rather than passing", () => {
    const result = parseCargoOutput({ stdout: "test result: ok. 3 passed; 0 failed" });
    assert.equal(result.allPassed, false);
  });

  it("reads the field pi.exec actually returns", () => {
    // pi's ExecResult is { stdout, stderr, code, killed } -- not exitCode.
    // A gate that looks for the wrong field sees undefined on every green run
    // and blocks every commit forever.
    const result = parseCargoOutput({ code: 0, stdout: "test result: ok. 4 passed; 0 failed" });
    assert.equal(result.allPassed, true);
  });

  it("marks a killed run inconclusive instead of failing", () => {
    const result = parseCargoOutput({ code: 1, killed: true, stdout: "Compiling cerebro-core" });
    assert.equal(result.allPassed, false);
    assert.equal(result.inconclusive, true);
  });

  it("marks an unparsed summary inconclusive when the run was killed", () => {
    const result = parseGenericOutput({ code: 1, killed: true, stdout: "" });
    assert.equal(result.inconclusive, true);
  });
});
