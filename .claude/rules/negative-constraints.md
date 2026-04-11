# Negative Constraints (MANDATORY)

> Agents are biased toward action. Positive specs leave implied gaps — negative constraints close them. These apply to every session, every agent (CC and CX alike).

## Never modify

- `.env`, `.env.*`, `secrets/*` — any file with credentials or API keys
- `.git/` internals — use git commands, not file edits
- `node_modules/`, `dist/`, `build/`, `.next/`, `.vercel/` — build outputs
- Auto-generated files (`sprint/sprint.md`, lock files, generated types) — regenerate via their owning tool

## Never bypass safety

- Do NOT commit with `--no-verify`, `--no-gpg-sign`, or `-c commit.gpgsign=false` unless the user explicitly asks
- Do NOT use `git reset --hard`, `git push --force`, `git clean -f`, `git branch -D` without explicit user approval
- Do NOT run destructive DB operations (`DROP TABLE`, `TRUNCATE`, unreversible migrations) without a backup path
- Do NOT modify files under `tests/` or `__tests__/` to make a failing test pass (`hooks/test-dir-protection.js` blocks this)

## Never fabricate completion

- Do NOT claim "tests pass" without showing real runner output (execution-integrity Rule 3)
- Do NOT leave `TODO`, `FIXME`, `HACK`, `XXX`, or placeholder text (`lorem ipsum`, `asdf`, `foo/bar/baz`) in a feature marked `done`
- Do NOT stub functions with only `return null`, `return undefined`, or `pass`
- Do NOT use `console.log` / `print()` as the only body of a catch/except block
- Do NOT micro-manage Opus 4.5+ agents with implementation-level plans — plan at product level (`bd6c916a` pattern)

## Never expand scope silently

- Do NOT install new dependencies without asking first
- Do NOT refactor untouched code while fixing a bug
- Do NOT rename files or symbols unless the user asked
- Do NOT add backwards-compat shims, feature flags, or abstractions for hypothetical future needs
- Do NOT add docstrings, comments, or type annotations to code you did not modify

## Never leak ambient context

- Do NOT paste `.env` values, API keys, or DB URIs into chat or commit messages
- Do NOT include full file contents in commit messages — commits show the diff
- Do NOT upload project files to third-party web tools (pastebins, gists, diagram renderers) without user approval

## If you catch yourself doing one of these

Stop, report the constraint you were about to violate, and ask the user how to proceed. This is not failure — this is the guardrail working.
