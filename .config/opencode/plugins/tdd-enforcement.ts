import type { Plugin } from "@opencode-ai/plugin";

const TEST_COVERAGE_BLOCK_MESSAGE = `
╔══════════════════════════════════════════════════════════════════╗
║  TEST COVERAGE REQUIRED                                          ║
╠══════════════════════════════════════════════════════════════════╣
║  No test exists for this source file.                             ║
║                                                                  ║
║  RULES (per AGENTS.md "Definition of Done"):                      ║
║  - New component/widget: at least one snapshot test              ║
║  - New function/method: unit tests for happy path + edge cases    ║
║  - Bug fix: regression test that would have caught the bug       ║
║                                                                  ║
║  Write tests BEFORE committing source code changes.              ║
║  The test IS the log - don't add prints, add assertions.          ║
╚══════════════════════════════════════════════════════════════════╝
`;

export const TddEnforcementPlugin: Plugin = async ({ client, directory }) => {
  function getTestFileForSource(sourcePath: string): string | null {
    if (sourcePath.endsWith(".rs")) {
      const base = sourcePath.replace(/\.rs$/, "");
      return `${base}_test.rs`;
    }
    if (sourcePath.endsWith(".ts") || sourcePath.endsWith(".tsx")) {
      const base = sourcePath.replace(/\.tsx?$/, "");
      return `${base}.test.ts`;
    }
    return null;
  }

  async function checkTestCoverage(filePath: string): Promise<boolean> {
    const testFile = getTestFileForSource(filePath);
    if (!testFile) return true;

    const fs = await import("fs");
    const path = await import("path");
    const testPath = path.join(directory, testFile);
    return fs.existsSync(testPath);
  }

  return {
    "tool.execute.before": async (input, _output) => {
      const tool = input.tool;
      const isEditTool = tool === "edit" || tool === "write";

      if (!isEditTool) return;

      const filePath = input.args?.filePath || "";
      if (!filePath) return;

      if (filePath.includes("test") || filePath.includes("spec")) return;
      if (filePath.includes("vendor")) return;

      const hasCoverage = await checkTestCoverage(filePath);
      if (!hasCoverage) {
        await client.app.log({
          body: {
            service: "tdd-enforcement",
            level: "error",
            message: `TEST COVERAGE BLOCKED: ${filePath} has no test file`,
            extra: {
              sourceFile: filePath,
              expectedTestFile: getTestFileForSource(filePath),
            },
          },
        });

        throw new Error(TEST_COVERAGE_BLOCK_MESSAGE);
      }
    },
  };
};
