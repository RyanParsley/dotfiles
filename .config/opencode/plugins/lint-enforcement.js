/**
 * Lint Enforcement Plugin — Blocks disabling of linters
 *
 * Prevents commits that contain inline lint disabling comments like:
 * - eslint-disable
 * - stylelint-disable
 * - tslint:disable
 * - disable-next-line
 *
 * Install: Symlink or copy to ~/.config/opencode/plugins/lint-enforcement.js
 * Enable: Add "~/.config/opencode/plugins/lint-enforcement.js" to plugins array in ~/.config/opencode/opencode.json
 */

export default {
  name: 'lint-enforcement',
  hooks: {
    'git:pre-commit': async (context) => {
      const disablePatterns = [
        /eslint-disable/,
        /stylelint-disable/,
        /tslint:disable/,
        /disable-next-line/,
        /disable-line/,
        /golint:disable/,
        /ruff:disable/,
        /pylint:disable/,
      ];

      const problematicFiles = [];

      for (const file of (context.files || [])) {
        // Only check source files
        if (!file.path.match(/\.(js|ts|jsx|tsx|py|go|rs|css|scss|less)$/)) {
          continue;
        }

        // Read file content if available
        const content = file.content || '';
        const lines = content.split('\n');

        for (let i = 0; i < lines.length; i++) {
          const line = lines[i];
          for (const pattern of disablePatterns) {
            if (pattern.test(line)) {
              problematicFiles.push(`${file.path}:${i + 1}: ${line.trim()}`);
              break;
            }
          }
        }
      }

      if (problematicFiles.length > 0) {
        console.error('❌ Lint disable comments found:');
        problematicFiles.forEach(f => console.error(`   ${f}`));
        throw new Error('Lint disable comments are not allowed. Fix the underlying issues instead.');
      }
    }
  }
};
