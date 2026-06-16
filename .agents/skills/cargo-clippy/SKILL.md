---
name: cargo-clippy
description: Lint Rust code with clippy. Use before committing, reviewing, or when checking code quality. Catches style issues, common mistakes, and suboptimal patterns beyond what the compiler finds.
---

# Linting

```bash
cargo clippy --workspace -- -D warnings
```

## Fix

```bash
cargo clippy --workspace --fix --allow-dirty
```

## Specific package

```bash
cargo clippy -p <package> -- -D warnings
```

## Gotchas

- **Always use `-D warnings`** — without it, clippy prints warnings but exits 0, hiding problems.
- **Run `cargo fmt --check` before clippy**: `cargo fmt --check && cargo clippy --workspace -- -D warnings`.
- **`--fix --allow-dirty`** auto-applies fixable lints without requiring a clean git tree.
- **Do NOT add suppressions** (`#[allow(...)]`, `#[expect(...)]`, `// clippy::...`, `--allow-dirty`) to silence lints. Fix the root cause instead.