# TDD Enforcement for Debugging

When debugging or fixing bugs, ALWAYS follow red-green-refactor TDD:

## Rules

1. **Write the test FIRST** — Before touching any source code, write a test that reproduces the bug. The test must FAIL against the current code.

2. **Confirm it fails** — Run the test and verify it fails with the expected error. If it passes, the test isn't testing the right thing.

3. **Implement the minimal fix** — Make the smallest change needed to make the test pass.

4. **Verify it passes** — Run the test suite to confirm the fix works and doesn't break anything.

5. **Refactor if needed** — Clean up the code while keeping tests green.

## Enforcement

- NEVER apply a fix without a corresponding test that would have caught the bug.
- If a test already exists but didn't catch the bug, the test is wrong — fix the test first.
- If you catch yourself editing source code before writing a test, STOP and write the test first.
- The test IS the log. Don't add debug prints — improve the assertion.

## Exceptions

TDD is not required when:
- The change is purely declarative (adding a config field, renaming a file, updating docs)
- The user explicitly asks to skip tests
- Exploratory investigation where the root cause is unknown (but tests must be written before the fix)
