---
name: cargo-build
description: Build Rust projects. Use when the user asks to build, or as a final validation gate before claiming a Rust task is complete. Run `cargo build` and `cargo test` before declaring any Rust code change done.
---

# Building Rust Projects

## Dev build

```bash
cargo build
```

## Release build

```bash
cargo build --release
```

## Specific package

```bash
cargo build -p <package>
```

## Validation Gate

Before declaring a Rust task complete, verify:

1. `cargo build` — compiles and links
2. `cargo test` — tests pass

If either fails, fix the root cause and re-run. Do not claim the task is done until both succeed.

## Gotchas

- Build from project root (contains `Cargo.toml` with `[workspace]`)
- `cargo check` is faster for type-checking; `cargo build` is needed to verify linking and produce binaries
- `target/` directory holds build artifacts — safe to delete if corrupted
- Incremental builds are cached; use `cargo clean` only when chasing phantom errors
- Release builds use `LTO = true` and `codegen-units = 1` by default in most well-configured workspaces — expect longer compile times