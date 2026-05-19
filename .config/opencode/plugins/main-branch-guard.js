/**
 * Main Branch Guard Plugin — Global protection against committing to main/default branch
 *
 * Blocks ALL attempts to commit directly to the default branch.
 * This is a HARD guard — it throws and blocks execution.
 *
 * Checks the actual current branch via git, not the command string.
 * Also checks worktree branches — if any worktree is on a feature branch,
 * assumes the user is working there and allows the commit.
 */

const BLOCK_MESSAGE = `\n╔══════════════════════════════════════════════════════════════════╗
║  MAIN BRANCH COMMIT BLOCKED                                      ║
╠══════════════════════════════════════════════════════════════════╣
║  NEVER commit directly to main (or the default branch).          ║
║                                                                  ║
║  Always work on a feature/fix branch and merge via PR.           ║
║                                                                  ║
║  Correct workflow:                                               ║
║  1. git worktree add ../project-{branch} -b {branch}             ║
║  2. Make changes and commit on the branch                        ║
║  3. Rebase onto main before pushing                              ║
║  4. Push and create a PR                                         ║
╚══════════════════════════════════════════════════════════════════╝\n`;

export const MainBranchGuard = async ({ project, client, $, directory, worktree }) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return;

      const command = output.args?.command || "";

      // Only intercept git commit or git push commands
      const isCommit = /^git\s+commit\b/.test(command);
      const isPush = /^git\s+push\b/.test(command);

      if (!isCommit && !isPush) return;

      const repoDir = directory || ".";

      // Get the default branch
      let defaultBranch = "main";
      try {
        const result = await $`git -C ${repoDir} symbolic-ref refs/remotes/origin/HEAD`.cwd(repoDir).nothrow();
        const ref = result.stdout?.toString().trim() || "";
        if (ref) defaultBranch = ref.split("/").pop() || "main";
      } catch {
        // Fallback to main
      }

      // Check the main repo branch
      let mainBranch;
      try {
        const result = await $`git -C ${repoDir} branch --show-current`.cwd(repoDir).nothrow();
        mainBranch = result.stdout?.toString().trim();
      } catch {
        return; // Can't determine, allow
      }

      // If main repo is on a feature branch, allow
      if (mainBranch !== defaultBranch && mainBranch !== "main" && mainBranch !== "master") {
        return;
      }

      // Check worktrees — if any worktree is on a feature branch, allow
      try {
        const wtResult = await $`git -C ${repoDir} worktree list --porcelain`.cwd(repoDir).nothrow();
        const wtOutput = wtResult.stdout?.toString().trim() || "";
        const worktrees = wtOutput.split("\n\n").filter(Boolean);

        for (const wt of worktrees) {
          const wtBranch = wt.match(/^branch\s+(.+)$/m)?.[1];
          if (wtBranch) {
            // branch line looks like: branch refs/heads/feat/my-feature
            const branchName = wtBranch.split("/").slice(3).join("/");
            if (branchName !== defaultBranch && branchName !== "main" && branchName !== "master") {
              return; // Allow — there's a worktree on a feature branch
            }
          }
        }
      } catch {
        // Can't list worktrees, continue to block
      }

      // All checks indicate we're on the default branch
      await client.app.log({
        body: {
          service: "main-branch-guard",
          level: "error",
          message: "Main branch commit attempt blocked",
          extra: { command: command.slice(0, 200), mainBranch, defaultBranch },
        },
      });

      throw new Error(BLOCK_MESSAGE);
    },
  };
};
