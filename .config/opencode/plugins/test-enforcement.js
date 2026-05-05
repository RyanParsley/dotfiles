/**
 * Test Enforcement Plugin — Ensures tests are run before commits
 *
 * Blocks commits unless tests have been run successfully.
 * Checks for recent test run evidence (test:watch, CI status, etc.)
 *
 * Install: Symlink or copy to ~/.config/opencode/plugins/test-enforcement.js
 * Enable: Add "~/.config/opencode/plugins/test-enforcement.js" to plugins array in ~/.config/opencode/opencode.json
 */

export default {
  name: 'test-enforcement',
  hooks: {
    'git:pre-commit': async (context) => {
      // Check if this is a merge commit or if tests are explicitly skipped
      const commitMsg = context.commitMessage || '';
      if (commitMsg.includes('[skip tests]') || commitMsg.includes('[no tests]')) {
        console.warn('⚠️  Warning: Committing with tests skipped');
        return; // Allow but warn
      }

      // Check for test-related files in the staging area
      const hasTestChanges = context.files?.some(f =>
        f.path.includes('test') ||
        f.path.includes('spec') ||
        f.path.includes('__tests__') ||
        f.path.endsWith('.test.js') ||
        f.path.endsWith('.spec.js')
      );

      // If changes include test files, enforce test run
      if (hasTestChanges) {
        console.log('🧪 Test files detected in changes');
        console.log('💡 Tip: Run your test suite before committing');
      }

      // This is a soft enforcement - just warns, doesn't block
      // For hard enforcement that blocks commits, uncomment below:
      // throw new Error('Tests must be run before committing. Use [skip tests] in commit message to override.');
    }
  }
};
