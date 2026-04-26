import { tool } from "@opencode-ai/plugin"
import path from "path"
import os from "os"

const CODEBERG_API = "https://codeberg.org/api/v1"

async function getGitRemote(dir: string): Promise<{ owner: string; repo: string; host: string } | null> {
  try {
    const result = await Bun.$`git -C ${dir} remote get-url origin`.text()
    const url = result.trim()
    // Match codeberg.org or any forgejo instance
    const match = url.match(/(?:git@|https?:\/\/)([^/]+)[:/]([^/]+)\/([^.]+?)(?:\.git)?$/)
    if (match) {
      return { host: match[1], owner: match[2], repo: match[3] }
    }
  } catch {
    // Not a git repo or no origin remote
  }
  return null
}

function getToken(): string | null {
  return process.env.CODEBERG_ACCESS_TOKEN || process.env.FORGEJO_ACCESS_TOKEN || process.env.GIT_TOKEN || null
}

function apiHeaders(token: string): Record<string, string> {
  return {
    "Authorization": `token ${token}`,
    "Content-Type": "application/json",
    "Accept": "application/json",
  }
}

async function apiGet(path: string, token: string): Promise<string> {
  const result = await Bun.$`curl -s -H Authorization: token ${token} -H Accept: application/json ${CODEBERG_API}${path}`.text()
  return result
}

async function apiPost(path: string, token: string, body: Record<string, unknown>): Promise<string> {
  const result = await Bun.$`curl -s -X POST -H Authorization: token ${token} -H Content-Type: application/json -H Accept: application/json -d ${JSON.stringify(body)} ${CODEBERG_API}${path}`.text()
  return result
}

async function apiPatch(path: string, token: string, body: Record<string, unknown>): Promise<string> {
  const result = await Bun.$`curl -s -X PATCH -H Authorization: token ${token} -H Content-Type: application/json -H Accept: application/json -d ${JSON.stringify(body)} ${CODEBERG_API}${path}`.text()
  return result
}

export const create_pr = tool({
  description: "Create a pull request on Codeberg. Auto-detects repo from git remote.",
  args: {
    title: tool.schema.string().describe("PR title"),
    body: tool.schema.string().optional().describe("PR description/body"),
    head: tool.schema.string().optional().describe("Source branch (default: current branch)"),
    base: tool.schema.string().optional().describe("Target branch (default: repo default branch)"),
    draft: tool.schema.boolean().optional().describe("Create as draft PR"),
  },
  async execute(args, context) {
    const token = getToken()
    if (!token) return "Error: CODEBERG_ACCESS_TOKEN environment variable not set. Create a token at codeberg.org → Settings → Applications."

    const remote = await getGitRemote(context.worktree)
    if (!remote) return "Error: Could not detect git remote. Are you in a git repo with an origin remote?"

    // Get current branch if head not specified
    let head = args.head
    if (!head) {
      try {
        head = (await Bun.$`git -C ${context.worktree} branch --show-current`.text()).trim()
      } catch {
        return "Error: Could not determine current branch. Specify --head explicitly."
      }
    }

    const body: Record<string, unknown> = {
      head,
      title: args.title,
    }
    if (args.body) body.body = args.body
    if (args.base) body.base = args.base
    if (args.draft) body.draft = true

    const result = await apiPost(`/repos/${remote.owner}/${remote.repo}/pulls`, token, body)
    const parsed = JSON.parse(result)
    if (parsed.message) return `Error: ${parsed.message}`
    return `PR #${parsed.number} created: ${parsed.html_url}\nTitle: ${parsed.title}\nState: ${parsed.state}`
  },
})

export const list_prs = tool({
  description: "List pull requests on Codeberg. Auto-detects repo from git remote.",
  args: {
    state: tool.schema.enum(["open", "closed", "all"]).optional().describe("Filter by state (default: open)"),
    limit: tool.schema.number().optional().describe("Max results (default: 30)"),
  },
  async execute(args, context) {
    const token = getToken()
    if (!token) return "Error: CODEBERG_ACCESS_TOKEN not set."

    const remote = await getGitRemote(context.worktree)
    if (!remote) return "Error: Could not detect git remote."

    const params = new URLSearchParams({ state: args.state || "open" })
    if (args.limit) params.set("limit", String(args.limit))

    const result = await apiGet(`/repos/${remote.owner}/${remote.repo}/pulls?${params}`, token)
    const prs = JSON.parse(result)
    if (!Array.isArray(prs)) return `Error: ${JSON.stringify(prs)}`
    if (prs.length === 0) return "No pull requests found."

    return prs.map((pr: Record<string, unknown>) =>
      `#${pr.number} - ${pr.title} (${pr.state})\n  ${pr.html_url}\n  by ${pr.user?.login} · ${pr.created_at}`
    ).join("\n\n")
  },
})

export const view_pr = tool({
  description: "View details of a specific pull request on Codeberg.",
  args: {
    number: tool.schema.number().describe("PR number"),
  },
  async execute(args, context) {
    const token = getToken()
    if (!token) return "Error: CODEBERG_ACCESS_TOKEN not set."

    const remote = await getGitRemote(context.worktree)
    if (!remote) return "Error: Could not detect git remote."

    const result = await apiGet(`/repos/${remote.owner}/${remote.repo}/pulls/${args.number}`, token)
    const pr = JSON.parse(result)
    if (pr.message) return `Error: ${pr.message}`

    return `#${pr.number} - ${pr.title}\nState: ${pr.state} · Draft: ${pr.draft}\nURL: ${pr.html_url}\nFrom: ${pr.head?.ref} → ${pr.base?.ref}\nBy: ${pr.user?.login}\nCreated: ${pr.created_at}\n\n${pr.body || "(no description)"}`
  },
})

export const create_issue = tool({
  description: "Create an issue on Codeberg. Auto-detects repo from git remote.",
  args: {
    title: tool.schema.string().describe("Issue title"),
    body: tool.schema.string().optional().describe("Issue description"),
    labels: tool.schema.array(tool.schema.string()).optional().describe("Labels to apply"),
    milestone: tool.schema.number().optional().describe("Milestone ID"),
  },
  async execute(args, context) {
    const token = getToken()
    if (!token) return "Error: CODEBERG_ACCESS_TOKEN not set."

    const remote = await getGitRemote(context.worktree)
    if (!remote) return "Error: Could not detect git remote."

    const body: Record<string, unknown> = { title: args.title }
    if (args.body) body.body = args.body
    if (args.labels?.length) body.labels = args.labels
    if (args.milestone) body.milestone = args.milestone

    const result = await apiPost(`/repos/${remote.owner}/${remote.repo}/issues`, token, body)
    const parsed = JSON.parse(result)
    if (parsed.message) return `Error: ${parsed.message}`
    return `Issue #${parsed.number} created: ${parsed.html_url}\nTitle: ${parsed.title}`
  },
})

export const list_issues = tool({
  description: "List issues on Codeberg. Auto-detects repo from git remote.",
  args: {
    state: tool.schema.enum(["open", "closed", "all"]).optional().describe("Filter by state (default: open)"),
    limit: tool.schema.number().optional().describe("Max results (default: 30)"),
  },
  async execute(args, context) {
    const token = getToken()
    if (!token) return "Error: CODEBERG_ACCESS_TOKEN not set."

    const remote = await getGitRemote(context.worktree)
    if (!remote) return "Error: Could not detect git remote."

    const params = new URLSearchParams({ state: args.state || "open" })
    if (args.limit) params.set("limit", String(args.limit))

    const result = await apiGet(`/repos/${remote.owner}/${remote.repo}/issues?${params}`, token)
    const issues = JSON.parse(result)
    if (!Array.isArray(issues)) return `Error: ${JSON.stringify(issues)}`
    if (issues.length === 0) return "No issues found."

    return issues.map((issue: Record<string, unknown>) =>
      `#${issue.number} - ${issue.title} (${issue.state})\n  ${issue.html_url}\n  by ${issue.user?.login} · ${issue.created_at}`
    ).join("\n\n")
  },
})

export const view_issue = tool({
  description: "View details of a specific issue on Codeberg.",
  args: {
    number: tool.schema.number().describe("Issue number"),
  },
  async execute(args, context) {
    const token = getToken()
    if (!token) return "Error: CODEBERG_ACCESS_TOKEN not set."

    const remote = await getGitRemote(context.worktree)
    if (!remote) return "Error: Could not detect git remote."

    const result = await apiGet(`/repos/${remote.owner}/${remote.repo}/issues/${args.number}`, token)
    const issue = JSON.parse(result)
    if (issue.message) return `Error: ${issue.message}`

    return `#${issue.number} - ${issue.title}\nState: ${issue.state}\nURL: ${issue.html_url}\nBy: ${issue.user?.login}\nCreated: ${issue.created_at}\nLabels: ${(issue.labels || []).map((l: Record<string, string>) => l.name).join(", ") || "(none)"}\n\n${issue.body || "(no description)"}`
  },
})

export const create_release = tool({
  description: "Create a release on Codeberg. Auto-detects repo from git remote.",
  args: {
    tag_name: tool.schema.string().describe("Tag name (e.g., v1.0.0)"),
    name: tool.schema.string().optional().describe("Release title (default: tag name)"),
    body: tool.schema.string().optional().describe("Release notes"),
    target_commitish: tool.schema.string().optional().describe("Target branch/commit (default: repo default)"),
    draft: tool.schema.boolean().optional().describe("Create as draft release"),
    prerelease: tool.schema.boolean().optional().describe("Mark as prerelease"),
  },
  async execute(args, context) {
    const token = getToken()
    if (!token) return "Error: CODEBERG_ACCESS_TOKEN not set."

    const remote = await getGitRemote(context.worktree)
    if (!remote) return "Error: Could not detect git remote."

    const body: Record<string, unknown> = {
      tag_name: args.tag_name,
      name: args.name || args.tag_name,
    }
    if (args.body) body.body = args.body
    if (args.target_commitish) body.target_commitish = args.target_commitish
    if (args.draft) body.draft = true
    if (args.prerelease) body.prerelease = true

    const result = await apiPost(`/repos/${remote.owner}/${remote.repo}/releases`, token, body)
    const parsed = JSON.parse(result)
    if (parsed.message) return `Error: ${parsed.message}`
    return `Release created: ${parsed.html_url}\nTag: ${parsed.tag_name}\nName: ${parsed.name}`
  },
})

export const list_releases = tool({
  description: "List releases on Codeberg. Auto-detects repo from git remote.",
  args: {
    limit: tool.schema.number().optional().describe("Max results (default: 30)"),
  },
  async execute(args, context) {
    const token = getToken()
    if (!token) return "Error: CODEBERG_ACCESS_TOKEN not set."

    const remote = await getGitRemote(context.worktree)
    if (!remote) return "Error: Could not detect git remote."

    const params = new URLSearchParams()
    if (args.limit) params.set("limit", String(args.limit))

    const result = await apiGet(`/repos/${remote.owner}/${remote.repo}/releases?${params}`, token)
    const releases = JSON.parse(result)
    if (!Array.isArray(releases)) return `Error: ${JSON.stringify(releases)}`
    if (releases.length === 0) return "No releases found."

    return releases.map((r: Record<string, unknown>) =>
      `${r.tag_name} - ${r.name}\n  ${r.html_url}\n  Published: ${r.published_at}${r.draft ? " (draft)" : ""}${r.prerelease ? " (prerelease)" : ""}`
    ).join("\n\n")
  },
})

export const repo_info = tool({
  description: "Get repository info from Codeberg. Auto-detects repo from git remote.",
  args: {},
  async execute(_args, context) {
    const token = getToken()
    if (!token) return "Error: CODEBERG_ACCESS_TOKEN not set."

    const remote = await getGitRemote(context.worktree)
    if (!remote) return "Error: Could not detect git remote."

    const result = await apiGet(`/repos/${remote.owner}/${remote.repo}`, token)
    const repo = JSON.parse(result)
    if (repo.message) return `Error: ${repo.message}`

    return `${repo.full_name}\n${repo.description || "(no description)"}\nURL: ${repo.html_url}\nDefault branch: ${repo.default_branch}\nStars: ${repo.stars_count} · Forks: ${repo.forks_count}\nPrivate: ${repo.private}\nCreated: ${repo.created_at}`
  },
})
