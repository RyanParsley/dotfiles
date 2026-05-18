import { readFile, readdir, stat } from "node:fs/promises";
import { join, dirname } from "node:path";
import { homedir } from "node:os";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "typebox";

interface ProjectInfo {
  name: string;
  path: string;
  lastActivity: string;
  commits: number;
  sessions: number;
  todos: number;
  description?: string;
  next?: string;
}

interface JournalEntry {
  date: string;
  projects: number;
  sessions: number;
  commits: number;
  path: string;
}

interface GoalEntry {
  title: string;
  path: string;
  type: string;
}

function getCortexPath(): string {
  return process.env.CORTEX_PATH || join(homedir(), "Projects", "cortex");
}

async function fileExists(path: string): Promise<boolean> {
  try {
    await stat(path);
    return true;
  } catch {
    return false;
  }
}

async function parseIndexPage(content: string): Promise<ProjectInfo[]> {
  const projects: ProjectInfo[] = [];
  const lines = content.split("\n");
  
  let currentProject: Partial<ProjectInfo> = {};
  
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    
    // Match project header like ### [rpdc](./projects/rpdc.md)
    const headerMatch = line.match(/###\s+\[(\w+)\]\(\.\/projects\/([^.]+)\.md\)/);
    if (headerMatch) {
      if (currentProject.name) {
        projects.push(currentProject as ProjectInfo);
      }
      currentProject = {
        name: headerMatch[1],
        path: `./projects/${headerMatch[2]}.md`,
      };
      continue;
    }
    
    // Match "Last touched: X ago" or "Last touched: YYYY-MM-DD"
    const touchedMatch = line.match(/\*\*Last touched:\*\*\s*(.+)/);
    if (touchedMatch) {
      currentProject.lastActivity = touchedMatch[1].trim();
      continue;
    }
    
    // Match "Activity: X commits, Y sessions"
    const activityMatch = line.match(/\*\*Activity:\*\*\s*(\d+)\s+commits?,\s*(\d+)\s+sessions?/);
    if (activityMatch) {
      currentProject.commits = parseInt(activityMatch[1], 10);
      currentProject.sessions = parseInt(activityMatch[2], 10);
      continue;
    }
    
    // Match "TODOs: X"
    const todosMatch = line.match(/\*\*TODOs:\*\*\s*(\d+)/);
    if (todosMatch) {
      currentProject.todos = parseInt(todosMatch[1], 10);
      continue;
    }
  }
  
  if (currentProject.name) {
    projects.push(currentProject as ProjectInfo);
  }
  
  return projects;
}

async function parseProjectPage(content: string): Promise<{
  description?: string;
  next?: string;
  todos: string[];
  commits: { hash: string; message: string }[];
  sessions: { date: string; title: string }[];
}> {
  const result = {
    todos: [] as string[],
    commits: [] as { hash: string; message: string }[],
    sessions: [] as { date: string; title: string }[],
  };
  
  const lines = content.split("\n");
  let inNext = false;
  let inTodos = false;
  let inCommits = false;
  let inSessions = false;
  
  for (const line of lines) {
    if (line.startsWith("## Next")) {
      inNext = true;
      inTodos = false;
      inCommits = false;
      inSessions = false;
      continue;
    }
    
    if (line.startsWith("## TODOs")) {
      inNext = false;
      inTodos = true;
      inCommits = false;
      inSessions = false;
      continue;
    }
    
    if (line.startsWith("## Recent Commits")) {
      inNext = false;
      inTodos = false;
      inCommits = true;
      inSessions = false;
      continue;
    }
    
    if (line.startsWith("## OpenCode Sessions")) {
      inNext = false;
      inTodos = false;
      inCommits = false;
      inSessions = true;
      continue;
    }
    
    if (line.startsWith("## ")) {
      inNext = false;
      inTodos = false;
      inCommits = false;
      inSessions = false;
      continue;
    }
    
    if (inNext && line.trim().startsWith("- ")) {
      const next = line.replace(/^-\s*/, "").trim();
      if (!result.next) {
        result.next = next;
      }
    }
    
    if (inTodos && line.includes("**")) {
      const todoMatch = line.match(/\*\*[A-Z]+(?:\*\*)?\s*(.+)/);
      if (todoMatch) {
        result.todos.push(todoMatch[1].replace(/\*\*/g, "").trim());
      }
    }
    
    if (inCommits && line.includes("`")) {
      const commitMatch = line.match(/`([a-f0-9]+)`\s*[-–]\s*(.+)/);
      if (commitMatch) {
        result.commits.push({
          hash: commitMatch[1],
          message: commitMatch[2].trim(),
        });
      }
    }
    
    if (inSessions && line.includes("**")) {
      const sessionMatch = line.match(/\*\*([\d-]+)\*\*\s*[-–]\s*(.+)/);
      if (sessionMatch) {
        result.sessions.push({
          date: sessionMatch[1],
          title: sessionMatch[2].trim(),
        });
      }
    }
  }
  
  return result;
}

async function parseJournalIndex(content: string): Promise<JournalEntry[]> {
  const entries: JournalEntry[] = [];
  const lines = content.split("\n");
  
  for (const line of lines) {
    const match = line.match(/\[([A-Z][a-z]{2}\s[\d]{2})\]\(([^)]+)\)\s*[-–]\s*(\d+)\s+projects?,\s*(\d+)\s+sessions?,\s*(\d+)\s+commits?/);
    if (match) {
      entries.push({
        date: match[1],
        path: match[2],
        projects: parseInt(match[3], 10),
        sessions: parseInt(match[4], 10),
        commits: parseInt(match[5], 10),
      });
    }
  }
  
  return entries;
}

export default function (pi: ExtensionAPI) {
  const cortexPath = getCortexPath();
  const contentPath = join(cortexPath, "content");
  
  pi.on("session_start", async (_event, ctx) => {
    const exists = await fileExists(contentPath);
    if (!exists) {
      ctx.ui.notify(`Cortex not found at ${cortexPath}. Set CORTEX_PATH env var.`, "warning");
    } else {
      ctx.ui.notify("Cortex context loaded. Use tools to query projects, journals, goals.", "info");
    }
  });
  
  // Tool: List all projects
  pi.registerTool({
    name: "list_projects",
    label: "List Projects",
    description: "List all tracked projects with their status, activity, and TODO counts. Use this to get an overview of all projects in the system.",
    parameters: Type.Object({}),
    async execute(_toolCallId, _params, signal, _onUpdate, _ctx) {
      const indexPath = join(contentPath, "index.md");
      
      if (!await fileExists(indexPath)) {
        return {
          content: [{ type: "text", text: `Cortex content not found at ${contentPath}. Run 'just build' in cortex project.` }],
          details: {},
        };
      }
      
      const content = await readFile(indexPath, "utf-8");
      const projects = await parseIndexPage(content);
      
      const summary = projects.map(p => 
        `- **${p.name}**: ${p.todos || 0} TODOs, ${p.commits || 0} commits, ${p.sessions || 0} sessions, last activity: ${p.lastActivity || "unknown"}`
      ).join("\n");
      
      return {
        content: [{ type: "text", text: `Found ${projects.length} projects:\n\n${summary}` }],
        details: { projects },
      };
    },
  });
  
  // Tool: Get project details
  pi.registerTool({
    name: "get_project",
    label: "Get Project",
    description: "Get detailed information about a specific project including description, next steps, recent commits, TODO items, and recent sessions.",
    parameters: Type.Object({
      name: Type.String({ description: "Project name (e.g., 'cerebro', 'cortex', 'rpdc')" }),
    }),
    async execute(_toolCallId, params, signal, _onUpdate, _ctx) {
      const projectPath = join(contentPath, "projects", `${params.name}.md`);
      
      if (!await fileExists(projectPath)) {
        const indexPath = join(contentPath, "index.md");
        const indexContent = await readFile(indexPath, "utf-8");
        const projects = await parseIndexPage(indexContent);
        const names = projects.map(p => p.name).join(", ");
        return {
          content: [{ type: "text", text: `Project '${params.name}' not found. Available projects: ${names}` }],
          details: { error: "not_found" },
        };
      }
      
      const content = await readFile(projectPath, "utf-8");
      const details = await parseProjectPage(content);
      
      let response = `# ${params.name}\n\n`;
      
      if (details.description) {
        response += `**Description:** ${details.description}\n\n`;
      }
      
      if (details.next) {
        response += `**Next:** ${details.next}\n\n`;
      }
      
      if (details.todos.length > 0) {
        response += `## TODOs (${details.todos.length} total)\n`;
        response += details.todos.slice(0, 20).map(t => `- ${t}`).join("\n");
        if (details.todos.length > 20) {
          response += `\n... and ${details.todos.length - 20} more`;
        }
        response += "\n\n";
      }
      
      if (details.commits.length > 0) {
        response += `## Recent Commits\n`;
        response += details.commits.slice(0, 10).map(c => `- \`${c.hash}\`: ${c.message}`).join("\n");
        response += "\n\n";
      }
      
      if (details.sessions.length > 0) {
        response += `## Recent Sessions\n`;
        response += details.sessions.slice(0, 10).map(s => `- **${s.date}**: ${s.title}`).join("\n");
      }
      
      return {
        content: [{ type: "text", text: response }],
        details: { project: params.name, ...details },
      };
    },
  });
  
  // Tool: Search content
  pi.registerTool({
    name: "search_cortex",
    label: "Search Cortex",
    description: "Search across project descriptions, TODOs, commits, and journal entries. Use this to find specific topics, keywords, or patterns across all projects.",
    parameters: Type.Object({
      query: Type.String({ description: "Search query" }),
      type: Type.Optional(Type.Union([
        Type.Literal("projects"),
        Type.Literal("journals"),
        Type.Literal("all"),
      ] as const, { description: "Where to search" })),
    }),
    async execute(_toolCallId, params, signal, _onUpdate, _ctx) {
      const results: string[] = [];
      const query = params.query.toLowerCase();
      const searchType = params.type || "all";
      
      // Search projects
      if (searchType === "projects" || searchType === "all") {
        const projectsDir = join(contentPath, "projects");
        try {
          const files = await readdir(projectsDir);
          for (const file of files) {
            if (!file.endsWith(".md")) continue;
            const content = await readFile(join(projectsDir, file), "utf-8");
            if (content.toLowerCase().includes(query)) {
              const projectName = file.replace(".md", "");
              // Extract relevant snippet
              const lines = content.split("\n");
              const matches = lines.filter(l => l.toLowerCase().includes(query));
              results.push(`**${projectName}**: ${matches.slice(0, 2).join(" | ")}`);
            }
          }
        } catch (e) {
          // Ignore errors
        }
      }
      
      // Search journals
      if (searchType === "journals" || searchType === "all") {
        const journalDir = join(contentPath, "journal", "2026");
        try {
          const files = await readdir(journalDir);
          for (const file of files) {
            if (!file.endsWith(".md")) continue;
            const content = await readFile(join(journalDir, file), "utf-8");
            if (content.toLowerCase().includes(query)) {
              results.push(`**journal/${file}**: matches found`);
            }
          }
        } catch (e) {
          // Ignore errors
        }
      }
      
      if (results.length === 0) {
        return {
          content: [{ type: "text", text: `No results found for '${params.query}'` }],
          details: { results: [] },
        };
      }
      
      return {
        content: [{ type: "text", text: `Found ${results.length} matches:\n\n${results.join("\n")}` }],
        details: { results, query: params.query },
      };
    },
  });
  
  // Tool: Get recent activity
  pi.registerTool({
    name: "get_recent_activity",
    label: "Recent Activity",
    description: "Get recent journal entries showing activity across all projects. Shows dates, project counts, sessions, and commits.",
    parameters: Type.Object({
      days: Type.Optional(Type.Number({ description: "Number of days to show (default: 7)" })),
    }),
    async execute(_toolCallId, params, signal, _onUpdate, _ctx) {
      const journalIndexPath = join(contentPath, "journal", "index.md");
      
      if (!await fileExists(journalIndexPath)) {
        return {
          content: [{ type: "text", text: "Journal not found" }],
          details: {},
        };
      }
      
      const content = await readFile(journalIndexPath, "utf-8");
      const entries = await parseJournalIndex(content);
      
      const limit = params.days || 7;
      const recent = entries.slice(0, limit);
      
      const summary = recent.map(e => 
        `- **${e.date}**: ${e.projects} projects, ${e.sessions} sessions, ${e.commits} commits`
      ).join("\n");
      
      return {
        content: [{ type: "text", text: `Recent activity:\n\n${summary}` }],
        details: { entries: recent },
      };
    },
  });
  
  // Tool: Get goals (intent)
  pi.registerTool({
    name: "get_goals",
    label: "Get Goals",
    description: "Get current goals and intentions from the intent system. Shows daily and weekly goals.",
    parameters: Type.Object({}),
    async execute(_toolCallId, _params, signal, _onUpdate, _ctx) {
      const goals: string[] = [];
      
      // Try daily goals
      const dailyDir = join(contentPath, "intent", "daily");
      try {
        const files = await readdir(dailyDir);
        for (const file of files) {
          if (file.endsWith(".md")) {
            const content = await readFile(join(dailyDir, file), "utf-8");
            const lines = content.split("\n").filter(l => l.trim().startsWith("-") || l.trim().length > 0);
            if (lines.length > 0) {
              goals.push(`## Daily: ${file.replace(".md", "")}`);
              goals.push(lines.slice(0, 5).join("\n"));
            }
          }
        }
      } catch (e) {
        // Ignore
      }
      
      // Try weekly goals
      const weeklyDir = join(contentPath, "intent", "weekly");
      try {
        const files = await readdir(weeklyDir);
        for (const file of files) {
          if (file.endsWith(".md")) {
            const content = await readFile(join(weeklyDir, file), "utf-8");
            const lines = content.split("\n").filter(l => l.trim().startsWith("-") || l.trim().length > 0);
            if (lines.length > 0) {
              goals.push(`## Weekly: ${file.replace(".md", "")}`);
              goals.push(lines.slice(0, 5).join("\n"));
            }
          }
        }
      } catch (e) {
        // Ignore
      }
      
      if (goals.length === 0) {
        return {
          content: [{ type: "text", text: "No goals found in intent system." }],
          details: {},
        };
      }
      
      return {
        content: [{ type: "text", text: goals.join("\n\n") }],
        details: {},
      };
    },
  });
  
  // Tool: Get today's summary
  pi.registerTool({
    name: "get_today",
    label: "Today",
    description: "Get today's summary from the cortex dashboard. Shows today's date, projects worked on, and activity summary.",
    parameters: Type.Object({}),
    async execute(_toolCallId, _params, signal, _onUpdate, _ctx) {
      const todayPath = join(contentPath, "today.md");
      
      if (!await fileExists(todayPath)) {
        return {
          content: [{ type: "text", text: "Today's summary not found. Run 'just build' in cortex." }],
          details: {},
        };
      }
      
      const content = await readFile(todayPath, "utf-8");
      return {
        content: [{ type: "text", text: content }],
        details: {},
      };
    },
  });
}