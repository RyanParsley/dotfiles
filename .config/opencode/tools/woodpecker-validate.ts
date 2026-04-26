import { tool } from "@opencode-ai/plugin"
import path from "path"
import fs from "fs"

const GITHUB_PATTERNS = [
  { pattern: /uses:\s*['"]?actions\//, message: "GitHub Actions 'uses:' directive found — Woodpecker uses 'image:' with container images" },
  { pattern: /runs-on:/, message: "GitHub Actions 'runs-on:' found — Woodpecker uses 'image:' to specify containers" },
  { pattern: /\$\{\{\s*secrets\./, message: "GitHub secrets syntax '${{ secrets.X }}' — Woodpecker uses '${X}' with secrets set via 'from_secret:'" },
  { pattern: /\$\{\{\s*github\./, message: "GitHub context '${{ github.* }}' — Woodpecker uses CI_* environment variables" },
  { pattern: /on:\s*[\n\r]/, message: "GitHub Actions 'on:' trigger — Woodpecker uses 'when:' with event arrays" },
  { pattern: /strategy:\s*[\n\r]/, message: "GitHub Actions 'strategy:' — Woodpecker uses matrix via environment variable arrays" },
]

const WOODPECKER_PATTERNS = [
  { pattern: /^steps:/m, message: "Valid: 'steps:' block found", valid: true },
]

function findWoodpeckerFiles(dir: string): string[] {
  const files: string[] = []
  const single = path.join(dir, ".woodpecker.yml")
  if (fs.existsSync(single)) files.push(single)

  const dirPath = path.join(dir, ".woodpecker")
  if (fs.existsSync(dirPath)) {
    const entries = fs.readdirSync(dirPath)
    for (const entry of entries) {
      if (entry.endsWith(".yml") || entry.endsWith(".yaml")) {
        files.push(path.join(dirPath, entry))
      }
    }
  }
  return files
}

function validateFile(filePath: string): { file: string; errors: string[]; warnings: string[]; valid: boolean } {
  const content = fs.readFileSync(filePath, "utf-8")
  const lines = content.split("\n")
  const errors: string[] = []
  const warnings: string[] = []

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i]
    for (const { pattern, message } of GITHUB_PATTERNS) {
      if (pattern.test(line)) {
        errors.push(`Line ${i + 1}: ${message}`)
      }
    }
  }

  // Check for env array syntax (common mistake)
  const envArrayMatch = content.match(/environment:\s*\n(\s+-\s+\w+:)/)
  if (envArrayMatch) {
    warnings.push("Environment variables use array syntax ('- KEY: value') — Woodpecker prefers map syntax ('KEY: value')")
  }

  // Check for empty commands
  const commandsMatch = content.match(/commands:\s*\n\s*-\s*$/)
  if (commandsMatch) {
    warnings.push("Empty command found in 'commands:' block")
  }

  return {
    file: path.relative(process.cwd(), filePath),
    errors,
    warnings,
    valid: errors.length === 0,
  }
}

export const woodpecker_validate = tool({
  description: "Validate Woodpecker CI configuration files. Checks for GitHub Actions anti-patterns and common Woodpecker syntax issues.",
  args: {
    dir: tool.schema.string().optional().describe("Directory to search (default: current working directory)"),
  },
  async execute(args, context) {
    const dir = args.dir || context.worktree
    const files = findWoodpeckerFiles(dir)

    if (files.length === 0) {
      return "No Woodpecker CI files found (.woodpecker.yml or .woodpecker/ directory)"
    }

    const results = files.map(f => validateFile(f))
    const totalErrors = results.reduce((sum, r) => sum + r.errors.length, 0)
    const totalWarnings = results.reduce((sum, r) => sum + r.warnings.length, 0)

    let output = `Woodpecker CI Validation\n${"=".repeat(40)}\n\n`
    output += `Files checked: ${files.length}\n`
    output += `Errors: ${totalErrors} | Warnings: ${totalWarnings}\n\n`

    for (const result of results) {
      output += `${result.file}: ${result.valid ? "✅ PASS" : "❌ FAIL"}\n`
      for (const err of result.errors) {
        output += `  ERROR: ${err}\n`
      }
      for (const warn of result.warnings) {
        output += `  WARN: ${warn}\n`
      }
      output += "\n"
    }

    return output.trim()
  },
})
