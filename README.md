# DG-VibeCoding-Framework v9.0.0

> One contract both Claude Code and Codex actually load. Guardrails only where
> an action is irreversible.

v9 is a subtraction release. v8 made a small fix expensive: a hook denied every
edit until the task carried five written steps, four more hooks fired on each
edit, and finishing a 60-line change touched nine non-code artifacts. The
default path is now: understand, change, run the narrowest real check, report.

## The invariant

> **Anything an agent must know lives in `AGENTS.md`. Agent-specific surfaces
> add convenience, never capability.**

Codex reads `AGENTS.md` natively. `CLAUDE.md` opens with an `@AGENTS.md` import —
the interop mechanism Anthropic documents — and adds only Claude-specific
conveniences below it. That is what makes CC/CX parity structural rather than a
synchronisation chore — and it is enforced by
`tests/parity.test.js`, not by discipline.

The framework therefore ships **no** `.claude/rules/` and **no** `.claude/skills/`:
Codex cannot read either, so neither may carry anything an agent needs.

## Current components

- **1 shared contract** — `AGENTS.md`, under 150 lines
- **4 commands** — `/done`, `/review`, `/handoff`, `/sprint`, each a pointer into
  a section of the contract
- **2 subagents** — `reviewer` (fresh-context review), `debugger`
- **5 hooks** — `block-env`, `completion-guard`, `git-context`, `pre-compact`,
  `context-reload`. None of them runs on an edit.
- **2 runtime configurations** — Claude Code under `.claude/`, Codex under
  `.codex/`, wiring an identical hook set

## Quick start

New empty project:

```bash
./setup-project.sh /path/to/project
```

Replace framework-managed files in an initialized project, after a backup:

```bash
./setup-project.sh --force /path/to/project
```

Existing framework project (4.x–8.x):

```bash
./migrate-to-v9.sh /path/to/project --dry-run
./migrate-to-v9.sh /path/to/project
```

Migration removes the retired machinery by name, so custom skills, agents,
commands, and hooks survive. It backs everything up first, replaces the drifted
entry points with the v9 contract, and refuses to run inside a git worktree.

## Contracts

| File | Purpose |
|---|---|
| `PROJECT.md` | Stack, architecture, commands, project facts |
| `AGENTS.md` | The shared agent contract — behaviour, gates, constraints |
| `CLAUDE.md` | `@AGENTS.md` plus Claude-only conveniences |
| `sprint/sprint.json` | Optional. Who is working on what, on which branch. |
| `framework.json` | Inventory and installation manifest |

`sprint/sprint.json` is not installed and is never a precondition for writing
code. It exists only to coordinate CC and CX working in parallel:

```json
{ "schema_version": 4, "base_branch": "dev", "updated": "…",
  "tasks": [{ "id": "T1", "title": "…", "assigned_to": "cx",
              "status": "in_progress", "branch": "cx/t1-slug" }] }
```

```bash
node scripts/validate-sprint.js sprint/sprint.json
```

## Parallel work

```bash
/handoff T1
# updates the task, then:
scripts/handoff-worktree.sh T1 cx
```

The helper makes the coordination commit before creating the partner worktree,
so the new worktree sees its assignment immediately. Merging is always the
user's call.

## Runtime hooks

In an installed project:

- Claude Code: `.claude/settings.local.json`
- Codex: `.codex/hooks.json`
- Shared implementation: `hooks/*.js`

Both are generated from `core/settings.template.json` and
`core/codex-hooks.template.json`, which wire the same five hooks;
`tests/parity.test.js` compares those two templates and fails if they drift or if
any hook is ever wired on an edit. Hooks are guardrails, not a security
sandbox — deterministic validators, Git protections, tests, and OS permissions
remain authoritative.

## Repository access modes

Team guidance stays tracked in every mode: `PROJECT.md`, `AGENTS.md`,
`CLAUDE.md`, `framework.json`, `sprint/sprint.json`, and the reusable commands,
hooks, agents, and scripts. Local runtime settings, logs, usage markers,
environment files, credentials, and build output stay ignored in every mode.

```bash
scripts/switch-repo-access.sh private-solo
scripts/switch-repo-access.sh private-shared
scripts/switch-repo-access.sh public
```

## Headless review

```bash
scripts/headless-review.sh --tool claude --mode quick --staged
scripts/headless-review.sh --tool codex --mode full src/ --output review.json
```

## Verification

```bash
bash tests/run.sh
```

The suite covers CC/CX parity, sprint validation, hook behaviour, generated
artifacts, migration preservation, worktree coordination, headless review
parsing, documentation drift, and end-to-end smoke behaviour.

```bash
shellcheck setup-project.sh migrate-project.sh migrate-to-v9.sh scripts/*.sh tests/*.sh
git diff --check
```

## Structure

```text
core/       Runtime templates: the shared contract and both hook configurations
.claude/    Claude commands, subagents, and source settings
hooks/      Shared deterministic lifecycle hooks
scripts/    Validation, install, review, and worktree tools
templates/  Project and schema templates
tests/      Dependency-light unit and integration suites
archive/    Retired components, kept for reference and recovery
```

## Release history

See [CHANGELOG.md](CHANGELOG.md) and the `VERSION` file. Public distribution
also requires the repository owner to select and add an explicit software
license.
