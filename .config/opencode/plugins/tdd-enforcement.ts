import type { Plugin } from "@opencode-ai/plugin"

/**
 * TDD Enforcement Plugin
 *
 * When the agent is debugging or fixing bugs, this plugin ensures tests are
 * written BEFORE implementation changes. It intercepts file edit/write
 * operations and checks for corresponding test coverage.
 *
 * Hooks into tool.execute.before to validate TDD compliance.
 */
export const TddEnforcementPlugin: Plugin = async ({ client, directory }) => {
  // Track whether we're in a debugging/fixing session
  let debuggingSession = false
  // Track files that have associated tests written
  const testedFiles = new Set<string>()

  // Keywords that indicate a debugging session
  const debugKeywords = [
    "debug",
    "fix",
    "bug",
    "issue",
    "broken",
    "error",
    "crash",
    "panic",
    "fails",
    "failing",
    "regression",
    "not working",
    "incorrect",
    "wrong",
    "repair",
  ]

  function isDebuggingSession(message: string): boolean {
    const lower = message.toLowerCase()
    return debugKeywords.some((kw) => lower.includes(kw))
  }

  function getTestFileForSource(sourcePath: string): string | null {
    // Rust: src/foo.rs -> tests/foo.rs or src/foo.rs -> tests/integration.rs
    // or src/foo.rs -> src/foo_test.rs
    if (sourcePath.endsWith(".rs")) {
      const base = sourcePath.replace(/\.rs$/, "")
      return `${base}_test.rs`
    }
    // TypeScript: src/foo.ts -> src/foo.test.ts
    if (sourcePath.endsWith(".ts") || sourcePath.endsWith(".tsx")) {
      const base = sourcePath.replace(/\.tsx?$/, "")
      return `${base}.test.ts`
    }
    return null
  }

  return {
    "message.updated": async ({ event }) => {
      // Detect if we're entering a debugging session
      if (event?.type === "message" && event?.role === "user") {
        const content = event?.content || ""
        if (isDebuggingSession(content) && !debuggingSession) {
          debuggingSession = true
          await client.app.log({
            body: {
              service: "tdd-enforcement",
              level: "info",
              message: "Debugging session detected - TDD enforcement active",
              extra: { directory },
            },
          })
        }
      }
    },

    "tool.execute.before": async (input, output) => {
      if (!debuggingSession) return

      const tool = input.tool
      const isEditTool =
        tool === "edit" ||
        tool === "write" ||
        tool === "bash"

      if (!isEditTool) return

      // For edit/write operations on source files, check if tests exist
      if (tool === "edit" || tool === "write") {
        const filePath = output.args?.filePath || ""
        const testFile = getTestFileForSource(filePath)

        if (testFile && !testedFiles.has(filePath)) {
          // Check if test file exists
          const fs = await import("fs")
          const path = await import("path")
          const testPath = path.join(directory, testFile)
          const sourcePath = path.join(directory, filePath)

          // Only enforce for source files, not test files themselves
          if (
            fs.existsSync(sourcePath) &&
            !filePath.includes("test") &&
            !filePath.includes("spec") &&
            !fs.existsSync(testPath)
          ) {
            await client.app.log({
              body: {
                service: "tdd-enforcement",
                level: "warn",
                message: `TDD violation: ${filePath} being modified without test coverage`,
                extra: {
                  sourceFile: filePath,
                  expectedTestFile: testFile,
                  suggestion: "Write a failing test first, then implement the fix",
                },
              },
            })
          }
        }
      }
    },

    "session.created": async () => {
      debuggingSession = false
      testedFiles.clear()
    },
  }
}
