---
name: cargo-test
description: Run Rust tests. Use when testing, or as a validation gate before claiming a Rust task is complete. Run `cargo build` and `cargo test` before declaring any Rust code change done.
---

# Running Tests

```bash
cargo test
```

## Specific test

```bash
cargo test <pattern>
```

## Workspace

```bash
cargo test --workspace
```

## Package

```bash
cargo test -p <package>
```

## Show output

```bash
cargo test -- --show-output
```

## Validation Gate

Before declaring a Rust task complete, verify:

1. `cargo build` — compiles and links
2. `cargo test --workspace` — tests pass

If either fails, fix the root cause and re-run. Do not claim the task is done until both succeed.

## Gotchas

- **Doc tests** run separately with `--doc`.
- **`--no-fail-fast`** runs all tests even after the first failure, useful for seeing the full picture.
- **`--lib`, `--bins`, `--tests`** filter by target type.
- **Release mode** (`--release`) may compile optimizations that mask timing bugs.
- **Tests in workspace library crates** may need dependent crates compiled first — run `cargo build` before `cargo test` if you see linking errors.