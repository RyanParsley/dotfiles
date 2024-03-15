def commandsNX [] {
  [ "add", "affected", "affected:graph", "connect", "daemon", "graph", "exec", "format:check", "format:write", "generate", "init", "migrate", "print-affected", "release", "repair", "report", "reset", "run", "run-many", "show", "view-logs", "watch",  ]
}

# Smart Monorepos · Fast CI
export extern "nx" [
  target
	project
  --help								# Show help
  --version							# Show version number
  --batch								# Run task(s) in batches for executors which support batches
  -c, --configuration   # This is the configuration to use when performing tasks on projects
	--output-style				# Defines how Nx emits outputs tasks logs
	--exclude							# Exclude certain projects from being processed                                                                                    [string]
	--parallel						# Max number of parallel processes [default is 3]                                                                                  [string]
	--runner							# This is the name of the tasks runner configured in nx.json                                                                       [string]
	--graph								# Show the task graph of the command. Pass a file path to save the graph data instead of viewing it in the browser.                [string]
	--verbose							# Prints additional information about the commands (e.g., stack traces)                                                           [boolean]
	--nxBail							# Stop command execution after the first failed task                                                             [boolean] [default: false]
	--nxIgnoreCycles			# Ignore cycles in the task graph                                                                                [boolean] [default: false]
	--skipNxCache					# Rerun the tasks even when the results are available in the cache                                               [boolean] [default: false]
	--project							# Target project
]

# Install a plugin and initialize it
export extern "nx add" [
  packageSpecifier
	--help                  # Show help                                                                                                                     [boolean]
  --version               # Show version number                                                                                                           [boolean]
  --updatePackageScripts  # Update `package.json` scripts with inferred targets. Defaults to `true` when the package is a core Nx plugin                  [boolean]
  --verbose               # Prints additional information about the commands (e.g., stack traces)                                                         [boolean]
]

# Run target for affected projects
export extern "nx affected" [
  --help(-h)                # Help for config
]

# Connect workspace to Nx Cloud
export extern "nx connect" [
  --help(-h)                # Help for config
]

# Prints information about the Nx Daemon process or starts a daemon process
export extern "nx daemon" [
  --help(-h)                # Help for config
]

# Graph dependencies within workspace                                                       [aliases: dep-graph]
export extern "nx graph" [
  --help(-h)                # Help for config
]

# Executes any command as if it was a target on the project
export extern "nx exec" [
  --help(-h)                # Help for config
]

# Check for un-formatted files
export extern "nx format:check" [
  --help(-h)                # Help for config
]

# Overwrite un-formatted files                                                                 [aliases: format]
export extern "nx format:write" [
  --help(-h)                # Help for config
]

# Generate or update source code (e.g., nx generate @nx/js:lib mylib).                              [aliases: g]
export extern "nx generate" [
  string
  --help(-h)                # Help for config
]

# Adds Nx to any type of workspace. It installs nx, creates an nx.json configuration file and optionally sets up
# remote caching. For more info, check https://nx.dev/recipes/adopting-nx.
export extern "nx init" [
  --help(-h)                # Help for config
]

# Lists installed plugins, capabilities of installed plugins and other available plugins.
export extern "nx list" [
		string
  --help(-h)                # Help for config
]

# Creates a migrations file or runs migrations from the migrations file.
# - Migrate packages and create migrations.json (e.g., nx migrate @nx/workspace@latest)
# - Run migrations (e.g., nx migrate --run-migrations=migrations.json). Use flag --if-exists to run migrations
# only if the migrations file exists.
export extern "nx migrate" [
  string
  --help(-h)                # Help for config
]
# Prints information about the projects and targets affected by changes
# [deprecated: Use `nx show projects --affected`, `nx affected --graph -t build` or `nx graph --affected` depending on which best suits your use case. The
# `print-affected` command will be removed in Nx 19.]
export extern "nx print-affected" [
  --help(-h)                # Help for config
]

# **ALPHA**: Orchestrate versioning and publishing of applications and libraries
export extern "nx release" [
  --help(-h)                # Help for config
]

# Repair any configuration that is no longer supported by Nx.
export extern "nx repair" [
  --help(-h)                # Help for config
]

# Reports useful version numbers to copy into the Nx issue template
export extern "nx report" [
  --help(-h)                # Help for config
]

# Clears all the cached Nx artifacts and metadata about the workspace and shuts down the Nx Daemon.
# [aliases: clear-cache]
export extern "nx reset" [
  --help(-h)                # Help for config
]

# Run a target for a project
export extern "nx run" [
  --help(-h)                # Help for config
]

# Run target for multiple listed projects
export extern "nx run-many" [
  --help(-h)                # Help for config
]

# Show information about the workspace (e.g., list of projects)
export extern "nx show" [
  --help(-h)                # Help for config
]

# Enables you to view and interact with the logs via the advanced analytic UI from Nx Cloud to help you debug
# your issue. To do this, Nx needs to connect your workspace to Nx Cloud and upload the most recent run details.
# Only the metrics are uploaded, not the artefacts.
export extern "nx view-logs" [
  --help(-h)                # Help for config
]

# Watch for changes within projects, and execute commands
export extern "nx watch" [
  --help(-h)                # Help for config
]
