---
name: cargo-clippy
description: Lint Rust code with clippy. Use before committing, reviewing, or when checking code quality. Catches style issues, common mistakes, and suboptimal patterns beyond what the compiler finds.
---

# Linting

```bash
cargo clippy -- -D warnings
```

## Fix

```bash
cargo clippy --fix --allow-dirty
```

## Workspace

```bash
cargo clippy --workspace -- -D warnings
```

## Specific package

```bash
cargo clippy -p <package> -- -D warnings
```

## Gotchas

- Always use `-D warnings` — without it, clippy prints warnings but exits 0, hiding problems
- Run `cargo fmt --check` before clippy: `cargo fmt --check && cargo clippy -- -D warnings`
- `--fix --allow-dirty` auto-applies fixable lints without requiring a clean git tree; preferred over manually accepting each prompt
- Clippy lints can be allowed per-line with `#[allow(clippy::lint_name)]` or project-wide in `clippy.toml`
