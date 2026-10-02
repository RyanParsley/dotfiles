import assert from "node:assert/strict";
import { existsSync, mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { after, before, describe, it } from "node:test";
import defaultFactory, {
  crateRootOf,
  findTestEvidence,
  isTestPath,
  isTrackedSource,
  resolveSourcePath,
} from "../extensions/tdd-enforcement.ts";

/**
 * A scratch fixture tree is used instead of a real repository so the suite does
 * not depend on what happens to exist on disk outside the temp directory.
 */
function fixture(): string {
  const root = mkdtempSync(join(tmpdir(), "tdd-enforcement-"));
  mkdirSync(join(root, "crates/core/src/components"), { recursive: true });
  mkdirSync(join(root, "crates/ui/src"), { recursive: true });
  writeFileSync(join(root, "crates/core/Cargo.toml"), "[package]\nname = \"core\"\n");
  writeFileSync(join(root, "crates/ui/Cargo.toml"), "[package]\nname = \"ui\"\n");
  return root;
}

describe("resolveSourcePath", () => {
  it("keeps absolute paths as-is instead of doubling cwd", () => {
    assert.equal(
      resolveSourcePath("/repo", "/repo/crates/core/src/lib.rs"),
      "/repo/crates/core/src/lib.rs",
    );
  });

  it("joins relative paths onto cwd", () => {
    assert.equal(resolveSourcePath("/repo", "crates/core/src/lib.rs"), "/repo/crates/core/src/lib.rs");
  });
});

describe("isTestPath", () => {
  it("recognises Rust integration tests and BDD features", () => {
    assert.equal(isTestPath("/repo/crates/ui/tests/integration.rs"), true);
    assert.equal(isTestPath("/repo/crates/ui/tests/cucumber.rs"), true);
    assert.equal(isTestPath("/repo/features/navigation.feature"), true);
    assert.equal(isTestPath("/repo/crates/ui/src/components/journal.rs"), false);
  });

  it("recognises *_test.rs, .test.ts, and Cypress .cy.ts files", () => {
    assert.equal(isTestPath("/repo/src/db/pins_test.rs"), true);
    assert.equal(isTestPath("/repo/extensions/main.test.ts"), true);
    assert.equal(isTestPath("/repo/src/widget.component.cy.ts"), true);
    assert.equal(isTestPath("/repo/src/widget.component.cy.tsx"), true);
  });

  it("is not fooled by module names that merely contain the word", () => {
    assert.equal(isTestPath("/repo/crates/core/src/untested.rs"), false);
    assert.equal(isTestPath("/repo/src/latest.rs"), false);
    assert.equal(isTestPath("/repo/src/contest.rs"), false);
    assert.equal(isTestPath("/repo/src/test-helpers.rs"), false);
  });
});

describe("crateRootOf", () => {
  it("finds the nearest ancestor holding a Cargo.toml", () => {
    const root = fixture();
    try {
      const source = join(root, "crates/core/src/components/journal.rs");
      assert.equal(crateRootOf(source), join(root, "crates/core"));
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  it("returns null when no manifest is above the file", () => {
    assert.equal(crateRootOf("/definitely/not/anywhere/here/src/lib.rs"), null);
  });
});

describe("findTestEvidence — rust", () => {
  it("counts an inline #[cfg(test)] module", () => {
    const root = fixture();
    try {
      const source = join(root, "crates/core/src/components/journal.rs");
      writeFileSync(source, "pub struct Journal;\n\n#[cfg(test)]\nmod tests {\n    #[test]\n    fn renders() {}\n}\n");
      assert.match(findTestEvidence(source) ?? "", /#\[cfg\(test\)\]/);
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  it("counts a feature-gated inline module: #[cfg(all(test, feature))]", () => {
    // Regression: `includes("#[cfg(test)]")` missed the common gated form,
    // blocking edits to files that plainly have tests.
    const root = fixture();
    try {
      const source = join(root, "crates/core/src/components/gated.rs");
      writeFileSync(
        source,
        "pub struct Gated;\n\n#[cfg(all(test, feature = \"ssr\"))]\nmod tests {\n    #[test]\n    fn renders() {}\n}\n",
      );
      assert.match(findTestEvidence(source) ?? "", /#\[cfg/);
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  it("does not mistake a test-utils feature gate for test code", () => {
    const root = fixture();
    try {
      const source = join(root, "crates/core/src/components/utils.rs");
      writeFileSync(
        source,
        "#[cfg(feature = \"test-utils\")]\npub mod test_support {}\n",
      );
      assert.equal(findTestEvidence(source), null);
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  it("counts crate integration coverage in a tests subdirectory", () => {
    // Regression: tests/e2e/main.rs (a [[test]] target in a subdir) was not
    // seen by the shallow readdir, blocking every src file in the crate.
    const root = fixture();
    try {
      const source = join(root, "crates/ui/src/widgets.rs");
      writeFileSync(source, "pub struct Widgets;\n");
      mkdirSync(join(root, "crates/ui/tests/e2e"), { recursive: true });
      writeFileSync(join(root, "crates/ui/tests/e2e/main.rs"), "fn main() {}\n");
      assert.match(findTestEvidence(source) ?? "", /tests/);
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  it("counts a sibling _test.rs", () => {
    const root = fixture();
    try {
      const source = join(root, "crates/core/src/storage.rs");
      writeFileSync(source, "pub fn store() {}\n");
      writeFileSync(join(root, "crates/core/src/storage_test.rs"), "#[test]\nfn stores() {}\n");
      assert.equal(findTestEvidence(source), join(root, "crates/core/src/storage_test.rs"));
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  it("counts a matching integration test file", () => {
    const root = fixture();
    try {
      const source = join(root, "crates/ui/src/report.rs");
      writeFileSync(source, "pub fn render() {}\n");
      mkdirSync(join(root, "crates/ui/tests"), { recursive: true });
      writeFileSync(join(root, "crates/ui/tests/report.rs"), "#[test]\nfn renders() {}\n");
      assert.equal(findTestEvidence(source), join(root, "crates/ui/tests/report.rs"));
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  it("counts crate integration coverage for a module with no own tests", () => {
    const root = fixture();
    try {
      const source = join(root, "crates/ui/src/widgets.rs");
      writeFileSync(source, "pub struct Widgets;\n");
      mkdirSync(join(root, "crates/ui/tests"), { recursive: true });
      writeFileSync(join(root, "crates/ui/tests/integration.rs"), "#[test]\nfn boots() {}\n");
      assert.match(findTestEvidence(source) ?? "", /tests/);
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  it("reports no evidence for a source file with no test surface at all", () => {
    const root = fixture();
    try {
      const source = join(root, "crates/core/src/components/untested.rs");
      writeFileSync(source, "pub struct Untested;\n");
      assert.equal(findTestEvidence(source), null);
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });
});

describe("findTestEvidence — typescript", () => {
  it("counts a sibling .test.ts", () => {
    const root = fixture();
    try {
      const source = join(root, "packages/app/src/render.ts");
      mkdirSync(join(root, "packages/app/src"), { recursive: true });
      writeFileSync(source, "export const render = () => {};\n");
      writeFileSync(join(root, "packages/app/src/render.test.ts"), "export {};\n");
      assert.equal(findTestEvidence(source), join(root, "packages/app/src/render.test.ts"));
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  it("counts a companion under a sibling tests directory", () => {
    const root = fixture();
    try {
      const source = join(root, "packages/app/src/render.ts");
      mkdirSync(join(root, "packages/app/src"), { recursive: true });
      mkdirSync(join(root, "packages/app/tests"), { recursive: true });
      writeFileSync(source, "export const render = () => {};\n");
      writeFileSync(join(root, "packages/app/tests/render.test.ts"), "export {};\n");
      assert.equal(findTestEvidence(source), join(root, "packages/app/tests/render.test.ts"));
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  it("stays out of the way for languages it does not model", () => {
    assert.equal(findTestEvidence("/repo/README.md"), null);
    assert.equal(findTestEvidence("/repo/main.py"), null);
  });
});

describe("isTrackedSource", () => {
  it("tracks only the languages whose test layout it understands", () => {
    assert.equal(isTrackedSource("/repo/crates/core/src/storage.rs"), true);
    assert.equal(isTrackedSource("/repo/extensions/guard.ts"), true);
    assert.equal(isTrackedSource("/repo/packages/app/render.tsx"), true);
  });

  it("stays out of the way of build, docs and data files", () => {
    for (const path of [
      "/repo/crates/cerebro/Cargo.toml",
      "/repo/AGENTS.md",
      "/repo/.woodpecker/ci.yml",
      "/repo/justfile",
      "/repo/main.py",
      "/repo/assets/logo.svg",
    ]) {
      assert.equal(isTrackedSource(path), false, `${path} is not a tracked source file`);
    }
  });
});

describe("tool_call handler", () => {
  /** Loads the extension with a stub API and returns its tool_call handler. */
  function handler() {
    const handlers = new Map<string, (event: unknown, ctx: unknown) => Promise<unknown>>();
    defaultFactory({ on: (event: string, fn: never) => handlers.set(event, fn) } as never);
    return (path: string) =>
      handlers.get("tool_call")!({ toolName: "edit", input: { path } }, { cwd: "/repo" });
  }

  it("does not demand a companion test for a Cypress spec", async () => {
    const ask = handler();
    assert.equal(await ask("/repo/src/widget.component.cy.ts"), undefined);
  });

  it("does not block untracked file types", async () => {
    const ask = handler();
    assert.equal(await ask("/repo/crates/cerebro/Cargo.toml"), undefined);
    assert.equal(await ask("crates/cerebro/Cargo.toml"), undefined);
    assert.equal(await ask("AGENTS.md"), undefined);
  });

  it("does not block tracked source that has a test surface", async () => {
    const root = fixture();
    try {
      const source = join(root, "crates/core/src/inline.rs");
      writeFileSync(source, "pub struct Inline;\n\n#[cfg(test)]\nmod tests {}\n");
      const ask = handler();
      assert.equal(await ask(source), undefined);
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  it("blocks tracked source with no test surface", async () => {
    const root = fixture();
    try {
      const source = join(root, "crates/core/src/untested.rs");
      writeFileSync(source, "pub struct Untested;\n");
      const ask = handler();
      const result = (await ask(source)) as { block?: boolean; reason?: string };
      assert.equal(result?.block, true);
      assert.match(result?.reason ?? "", /No test surface/);
      assert.match(result?.reason ?? "", /crates\/core\/tests/);
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });
});

describe("fixture hygiene", () => {
  const roots: string[] = [];
  before(() => {
    roots.push(fixture());
  });
  after(() => {
    for (const root of roots) {
      assert.equal(existsSync(root), false, "temp fixtures must be removed after the run");
      rmSync(root, { recursive: true, force: true });
    }
  });
  it("creates a scratch tree that is cleaned up", () => {
    assert.equal(existsSync(roots[0]), true);
    rmSync(roots[0], { recursive: true, force: true });
  });
});
