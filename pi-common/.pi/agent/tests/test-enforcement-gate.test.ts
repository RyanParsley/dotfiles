import assert from "node:assert/strict";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { describe, it } from "node:test";
import defaultFactory from "../extensions/test-enforcement.ts";

type ExecResult = { stdout: string; stderr: string; code: number; killed: boolean };
type Handler = (event: unknown, ctx: unknown) => Promise<unknown>;

/**
 * Drives the real tool_call handler against a stubbed pi.exec, so the gate's
 * end-to-end behaviour -- which tree it tests, and what it decides -- is
 * covered, not just its output parsing. This is the layer that silently graded
 * the wrong repository before.
 */
function harness(
  options: Partial<ExecResult> & { stdout?: string; stderr?: string; manifest?: boolean | "node" } = {},
) {
  const root = mkdtempSync(join(tmpdir(), "test-enforcement-"));
  if (options.manifest === "node") {
    writeFileSync(join(root, "package.json"), '{"scripts":{"test":"vitest run"}}\n');
  } else if (options.manifest !== false) {
    writeFileSync(join(root, "Cargo.toml"), "[workspace]\nmembers = []\n");
  }

  const handlers = new Map<string, Handler>();
  const execCalls: Array<{ command: string; args: string[]; cwd?: string }> = [];
  const notifications: string[] = [];

  const pi = {
    on: (event: string, fn: Handler) => handlers.set(event, fn),
    exec: async (command: string, args: string[], opts?: { cwd?: string }): Promise<ExecResult> => {
      execCalls.push({ command, args, cwd: opts?.cwd });
      if (command === "git" && args[0] === "rev-parse") {
        return { stdout: `${opts?.cwd ?? root}\n`, stderr: "", code: 0, killed: false };
      }
      return {
        stdout: options.stdout ?? "test result: ok. 4 passed; 0 failed",
        stderr: options.stderr ?? "",
        code: options.code ?? 0,
        killed: options.killed ?? false,
      };
    },
  };

  defaultFactory(pi as never);
  const ctx = { cwd: root, ui: { notify: (message: string) => notifications.push(message) } };

  return {
    root,
    execCalls,
    notifications,
    async commit(command: string) {
      try {
        return (await handlers.get("tool_call")!(
          { toolName: "bash", input: { command } },
          ctx,
        )) as { block?: boolean; reason?: string } | undefined;
      } finally {
        rmSync(root, { recursive: true, force: true });
      }
    },
  };
}

describe("commit gate", () => {
  it("does not block a passing node suite because a test logs a failure message", async () => {
    const h = harness({
      manifest: "node",
      stdout: [
        "{ message: 'Loading chunk 123 failed' }",
        "Test Files  12 passed (12)",
        "     Tests  30 passed (30)",
      ].join("\n"),
    });
    const result = await h.commit(`cd ${h.root} && git commit -m x`);

    assert.equal(result, undefined);
    assert.deepEqual(h.execCalls.find((call) => call.command === "npm")?.args, ["test"]);
  });

  it("runs the suite in the repository the commit happens in", async () => {
    const h = harness();
    const result = await h.commit(`cd ${h.root} && git commit -m x`);

    assert.equal(result, undefined, "a green suite must not block");
    const cargo = h.execCalls.find((call) => call.command === "cargo");
    assert.deepEqual(cargo?.args, ["test"]);
    assert.equal(cargo?.cwd, h.root);
  });

  it("blocks when the suite exits non-zero", async () => {
    const h = harness({ code: 101, stdout: "test result: FAILED. 3 passed; 1 failed" });
    const result = await h.commit(`cd ${h.root} && git commit -m x`);

    assert.equal(result?.block, true);
    assert.match(result?.reason ?? "", /1 test\(s\) failing/);
    assert.match(result?.reason ?? "", new RegExp(h.root));
  });

  it("blocks a build failure that produced no test counts", async () => {
    const h = harness({ code: 101, stdout: "", stderr: "error: could not find OpenSSL" });
    const result = await h.commit(`cd ${h.root} && git commit -m x`);

    assert.equal(result?.block, true);
    assert.match(result?.reason ?? "", /the build, when no counts appear/);
  });

  it("does not block a run that was killed", async () => {
    const h = harness({ code: 1, killed: true, stdout: "   Compiling cerebro-core v0.2.2" });
    const result = await h.commit(`cd ${h.root} && git commit -m x`);

    assert.equal(result, undefined, "an unfinished run proves nothing");
    assert.ok(h.notifications.some((message) => message.includes("did not finish")));
  });

  it("leaves commits alone outside a supported project", async () => {
    const h = harness({ manifest: false });
    const result = await h.commit(`cd ${h.root} && git commit -m x`);

    assert.equal(result, undefined);
    assert.equal(
      h.execCalls.some((call) => call.command === "cargo"),
      false,
    );
    assert.ok(h.notifications.some((message) => message.includes("No supported test framework")));
  });

  it("ignores amends", async () => {
    const h = harness();
    assert.equal(await h.commit(`cd ${h.root} && git commit --amend --no-edit`), undefined);
    assert.equal(
      h.execCalls.some((call) => call.command === "cargo"),
      false,
    );
  });

  it("grades the worktree rather than the session directory", async () => {
    const session = mkdtempSync(join(tmpdir(), "session-"));
    const worktree = mkdtempSync(join(tmpdir(), "worktree-"));
    writeFileSync(join(session, "Cargo.toml"), "[workspace]\nmembers = []\n");
    writeFileSync(join(worktree, "Cargo.toml"), "[workspace]\nmembers = []\n");

    try {
      const handlers = new Map<string, Handler>();
      const tested: string[] = [];
      defaultFactory({
        on: (event: string, fn: Handler) => handlers.set(event, fn),
        exec: async (command: string, args: string[]) => {
          if (command === "git") {
            return { stdout: `${worktree}\n`, stderr: "", code: 0, killed: false };
          }
          tested.push(args.join(" "));
          return { stdout: "test result: ok. 1 passed; 0 failed", stderr: "", code: 0, killed: false };
        },
      } as never);

      await handlers.get("tool_call")!(
        { toolName: "bash", input: { command: `cd ${worktree} && git commit -m x` } },
        { cwd: session, ui: { notify: () => {} } },
      );

      assert.deepEqual(tested, ["test"], "the suite runs once, against the worktree");
    } finally {
      rmSync(session, { recursive: true, force: true });
      rmSync(worktree, { recursive: true, force: true });
    }
  });
});
