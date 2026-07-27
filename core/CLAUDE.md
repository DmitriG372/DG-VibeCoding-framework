@AGENTS.md

## Claude Code

Everything above is the shared contract, identical for Codex. This section is Claude-only convenience.

- Commands: `/done`, `/review`, `/handoff`, `/sprint` — each runs the matching section of `AGENTS.md`.
- Subagents: `reviewer` (fresh-context review), `debugger` (active bug with a real error message).
  Delegate only for independent, sizeable work. Do not use a subagent to double-check your own work.
- Plan mode is optional. If you could describe the diff in one sentence, skip the plan.
- Hook wiring lives in `.claude/settings.local.json`; the same hooks are wired for Codex in
  `.codex/hooks.json`.
