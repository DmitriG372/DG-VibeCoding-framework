# Review policy

One policy for every review path: the `reviewer` subagent, `scripts/headless-review.sh`, and a
human reading a PR. Read `PROJECT.md` first — a project convention outranks a general rule here.

## Passes

Run three passes and tag every finding with its pass:

- **bugs** — logic errors, broken edge cases, regressions in adjacent behaviour
- **security** — hardcoded secrets, missing input validation, injection, auth or permission gaps,
  PII in logs
- **compliance** — the change does what was asked and only that; no test was edited to accommodate
  a bug; nothing under `## Never` in `AGENTS.md` was crossed

## Severity

- **Critical** — breaks behaviour, leaks data, or crosses a `## Never` rule. Blocks merge.
- **Major** — a real failure case with concrete inputs. Fix before merge.
- **Minor** — correct but fragile. Fix if cheap.

Everything else is a nit: style, naming, speculative future needs, missing abstractions.

## What counts as a finding

State the failure concretely: given input X, the code does Y, which is wrong because Z.
If you cannot describe how it fails, it is not a finding.

## Cap the nits

At most three nits, in one list at the end; summarise the rest as a count. A reviewer asked to
find gaps will always find some; chasing every one produces defensive code and tests for cases
that cannot happen. Silence on a clean change is the correct output — do not pad.

## Do not report

- Generated files and vendored code
- Anything CI or the linter already enforces
- Style opinions where `PROJECT.md` is silent
