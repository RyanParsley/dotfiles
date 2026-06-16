---
name: cargo-check
description: Fast Rust compilation check. Use during active coding for quick type-check feedback without full codegen. Prefer over `cargo build` when you only need to verify types, borrows, and syntax.
---

# Checking

```bash
cargo check
```

## Workspace

```bash
cargo check --workspace
```

## Specific package

```bash
cargo check -p <package>
```

## Release mode

```bash
cargo check --release
```

## Gotchas

- **`--workspace`** checks all packages; `--all` is deprecated — always use `--workspace`.
- Much faster than `cargo build` (skips codegen) but does not verify linking.
- Use during active editing cycles; switch to `cargo build` before claiming done.
- **`--all-targets`** includes tests, benches, and examples.