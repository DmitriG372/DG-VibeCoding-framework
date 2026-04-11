---
name: testing
description: "Use when writing tests, running test suites, doing TDD, or fixing failing tests. NOT for one-off scripts or prod bug reproduction without intent to add coverage."
triggers: ["write tests", "run tests", "TDD", "coverage", "test failing", "spec", "vitest", "playwright", "jest"]
negative_triggers: ["simple bug fix without test", "one-off script", "prototype exploration", "database-only tweak"]
paths: "**/*.test.*, **/*.spec.*, **/tests/**, **/__tests__/**"
level: "2"
---

# Testing

> TDD with Vitest (unit) and Playwright (E2E). Test-first is the default.

## Validation Gate (HARD BLOCK)

Before marking any feature `done`:

1. Test file must exist AND be imported by the runner
2. `pnpm test` (or project equivalent) must have been executed in this session
3. Actual runner output must be visible — **not** "tests should pass"
4. Summary line must show `0 failed`

If any gate fails → feature stays `in_progress`. No exceptions.

## TDD Workflow

1. **Red** — Write failing test. Run it. SHOW the failing output.
2. **Green** — Minimal implementation to pass. Run. SHOW the passing output.
3. **Refactor** — Clean up. Re-run. SHOW the still-passing output.
4. **Commit** — `test(scope): F<ID> <what>` with runner evidence in body.

## When to use which tool

| Need | Tool |
|------|------|
| Pure function / module | Vitest unit |
| React/Vue component | Vitest + @testing-library |
| HTTP API route | Vitest + supertest OR Playwright API context |
| Full user flow | Playwright E2E |
| Visual regression | Playwright snapshot |

## Level 3 References (load on demand)

- `references/patterns.md` — Vitest describe/it/mock, Playwright page patterns, Vue/React component setup, organization layout

Load only when actively writing new test scaffolding. For modifying existing tests, read the neighboring test file instead.

## Anti-Patterns

- Asserting on output you haven't run (`expect(foo).toBe(...)` without evidence)
- Mocking the system under test (mock collaborators, not the target)
- Modifying tests to make them pass (blocked by `hooks/test-dir-protection.js`)
- Skipping tests via `.skip()` or `it.only()` without a tracked reason
