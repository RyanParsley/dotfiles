/**
 * Lint Disable Guard
 *
 * Blocks the assistant from adding lint-disable comments, vale-off directives,
 * or QUOTE-EXEMPT tags as a lazy workaround. If a legitimate need arises,
 * the human must add it by hand.
 *
 * Install: Place in ~/.config/opencode/plugins/lint-disable-guard.js
 * Enable: Add "lint-disable-guard" to plugins array in opencode.json
 */

const DISABLE_PATTERNS = [
  /rumdl-disable-file/i,    // INVALID: rumdl has no such comment syntax
  /rumdl-disable-line/i,    // INVALID: rumdl has no such comment syntax
  /<!--\s*vale\s+off\s*-->/i,   // Valid: disables vale for file
  /<!--\s*QUOTE-EXEMPT/i,     // Invalid: workaround for broken verify-quotes
  /markdownlint-disable/i,
  /mdl-disable/i,
];

const ALLOWED_PATHS = [
  /src\/32-references\/.*-transcript\.md$/,
  /src\/32-references\/.*\.md$/,
];

// Teaching messages for invalid syntax classes
const TEACHING = {
  'rumdl-disable': 'rumdl is a CLI wrapper, not a file format. No rumdl-* comments exist.',
  'vale off': 'Use <!-- vale off --> to disable vale. This is valid HTML comment syntax.',
  'QUOTE-EXEMPT': 'QUOTE-EXEMPT is a workaround for a broken script. Fix verify-quotes.rs instead.',
};

function containsDisableComment(text) {
  if (typeof text !== "string") return false;
  return DISABLE_PATTERNS.some((p) => p.test(text));
}

function isAllowedPath(filePath) {
  if (!filePath) return false;
  return ALLOWED_PATHS.some((p) => p.test(filePath));
}

function getTeaching(text) {
  for (const [key, msg] of Object.entries(TEACHING)) {
    if (text.includes(key)) {
      return `\n-> ${msg}`;
    }
  }
  return '';
}

export const LintDisableGuard = async ({ client }) => {
  await client.app.log({
    body: {
      service: "lint-disable-guard",
      level: "info",
      message: "Lint-disable guard active — blocking ALL lint-disable circumventions",
    },
  });

  function checkContent(content, tool, filePath) {
    // Reference files with transcripts are the ONLY allowed exception
    if (isAllowedPath(filePath)) {
      return;
    }

    if (containsDisableComment(content)) {
      const matched = DISABLE_PATTERNS.find((p) => p.test(content));
      const teaching = getTeaching(content);
      throw new Error(
        `Lint-disable guard blocked ${tool} to ${filePath}:\n` +
          `Detected forbidden pattern: ${matched.source}${teaching}\n\n` +
          `You may NOT disable linters to avoid fixing real issues.\n` +
          `Fix the underlying problem, or ask the human to add the disable comment by hand if truly justified.\n` +
          `Allowed exceptions: src/32-references/*-transcript.md (raw transcripts only).`,
      );
    }
  }

  return {
    "tool.execute.before": async (input) => {
      const tool = input.tool;
      const args = input.args || {};
      let content = null;
      let filePath = null;

      if (tool === "write") {
        content = args.content;
        filePath = args.filePath;
        checkContent(content, tool, filePath);
      } else if (tool === "edit") {
        content = args.newString;
        filePath = args.filePath;
        checkContent(content, tool, filePath);
      } else if (tool === "bash") {
        // Intercept bash commands that would inject forbidden patterns
        const command = args.command || "";
        if (containsDisableComment(command)) {
          const teaching = getTeaching(command);
          throw new Error(
            `Lint-disable guard blocked bash command:\n` +
              `Command would inject forbidden lint-disable patterns.${teaching}\n\n` +
              `Use OpenCode write/edit tools instead, or ask the human to run the command by hand.\n` +
              `Forbidden class: ALL lint-disable circumventions (rumdl-*, <!-- vale off -->, <!-- QUOTE-EXEMPT, etc.)`,
          );
        }
      }
    },
  };
};
