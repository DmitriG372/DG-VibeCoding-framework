# DG-VibeCoding-Framework v8.0.0

> Disciplined Claude Code + Codex collaboration with validated sprint state.

DG-VibeCoding-Framework gives Claude Code (CC) and Codex (CX) a shared project
contract while keeping their runtime integrations platform-specific. The core
model is simple: project rules live in Markdown, sprint coordination lives in a
validated JSON contract, and deterministic hooks provide guardrails around
edits, tests, reviews, and context recovery.

## Current components

- **8 core skills** — debugging, finish, git, housekeeping, partnership, start,
  testing, vibecoding
- **12 commands** — sprint-init, feature, done, review, fix, orchestrate,
  peer-review, handoff, sprint-status, context-refresh, sync-notebook,
  framework-update
- **6 starter agents** — orchestrator, implementer, reviewer, tester, debugger,
  plan-checker
- **15 hooks** — security, decomposition, scope, validation, formatting,
  context, sprint synchronization, test evidence, and completion guardrails
- **2 runtime configurations** — Claude Code under `.claude/`, Codex under
  `.codex/`

## Quick start

New empty project:

```bash
./setup-project.sh /path/to/project
```

Replace framework-managed files in an initialized project only after creating
a backup:

```bash
./setup-project.sh --force /path/to/project
```

Existing framework project:

```bash
./migrate-v7-to-v8.sh /path/to/project --dry-run
./migrate-v7-to-v8.sh /path/to/project
```

Both setup and migration verify the resulting artifact before reporting
success.

## Contracts

| Contract | Purpose |
|---|---|
| `PROJECT.md` | Stack, architecture, commands, and project rules |
| `AGENTS.md` | Durable Codex guidance |
| `CLAUDE.md` | Durable Claude Code guidance |
| `EXECUTION_PROTOCOL.md` | Shared execution and safety rules |
| `sprint/sprint.json` | Mutable sprint-v3 coordination state |
| `framework.json` | Framework inventory and installation manifest |

Sprint state references `templates/sprint.schema.json` and is checked by:

```bash
node scripts/validate-sprint.js sprint/sprint.json
```

Non-trivial features require measurable acceptance criteria, 5–10 structured
steps, and an explicit file corridor.

## Parallel work

`branch_strategy: "sequential"` means one agent at a time in one checkout.
Parallel CC/CX work always uses `branch_strategy: "worktree"`.

```bash
/handoff F003
# command validates and updates sprint state, then calls:
scripts/handoff-worktree.sh F003 cx
```

The helper creates a dedicated sprint coordination commit before creating the
partner worktree. Therefore the new worktree sees its assignment immediately.
Implementation and sprint-state commits are separate because a commit cannot
contain its own hash.

## Runtime hooks

- Claude Code: `.claude/settings.local.json`
- Codex: `.codex/hooks.json`
- Shared implementation: `hooks/*.js` and `hooks/lib/hook-input.js`

Hooks accept Claude edit payloads and Codex `apply_patch` payloads. They are
guardrails rather than a complete security sandbox; deterministic validators,
Git protections, tests, and normal OS permissions remain authoritative.

## Repository access modes

Team guidance and sprint contracts stay tracked in every mode:

- `PROJECT.md`, `AGENTS.md`, `CLAUDE.md`
- `EXECUTION_PROTOCOL.md`, `framework.json`
- `sprint/sprint.json`
- reusable skills, commands, hooks, agents, and scripts

Local/private state stays ignored in every mode:

- local runtime settings and Notebook configuration
- narrative/context snapshots, logs, usage markers
- `manifest.md`, environment files, credentials, local databases, build output

Change the local access declaration with:

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

The review runner reads Git-tracked files, rejects secret-like paths, sends
large prompts over stdin, limits input bytes, parses Codex JSONL, and validates
structured review output.

## Verification

```bash
bash tests/run.sh
```

The suite covers sprint validation, cross-runtime hooks, generated artifacts,
migration preservation, worktree coordination, malicious filenames, headless
review parsing, documentation drift, and end-to-end smoke behavior.

Additional local checks:

```bash
shellcheck setup-project.sh migrate-project.sh migrate-v7-to-v8.sh scripts/*.sh tests/*.sh
git diff --check
```

## Structure

```text
core/                 Runtime templates and protocol documentation
.claude/              Claude skills, commands, agents, and source settings
hooks/                Shared deterministic lifecycle hooks
scripts/              Validation, install, migration, review, and worktree tools
templates/            Project, sprint, snapshot, and output schemas
tests/                Dependency-light unit and integration suites
archive/              Historical components not installed by default
```

## Release history

See [CHANGELOG.md](CHANGELOG.md) and the `VERSION` file. Public distribution
also requires the repository owner to select and add an explicit software
license.
