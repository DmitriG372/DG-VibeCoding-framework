# DG-VibeCoding-Framework v9.1.0

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

The framework therefore ships **no** `.claude/rules/`: Codex cannot read them,
so they may not carry anything an agent needs. It also ships no skills — not
because Codex cannot read them (it can, see below) but because none has yet
earned the context every session would pay for it.

### Skills

Both runtimes implement the open [Agent Skills](https://agentskills.io)
standard: a directory with a `SKILL.md` carrying `name` and `description`.
Codex discovers project skills under `.agents/skills/`, Claude Code under
`.claude/skills/`. A project that adds one keeps a single copy:

```bash
mkdir -p .agents/skills/<name>          # SKILL.md lives here
ln -s ../.agents/skills .claude/skills  # Claude Code reads the same set
```

`scripts/verify-install.js` checks `references/` links in both locations.

## Current components

- **1 shared contract** — `AGENTS.md`, under 150 lines
- **1 review policy** — `REVIEW.md`: passes, severities, what is never reported.
  The `reviewer` subagent and `scripts/headless-review.sh` both read it
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

Existing framework project (4.x–9.0):

```bash
./migrate-to-v9.sh /path/to/project --dry-run
./migrate-to-v9.sh /path/to/project
```

Migration removes the retired machinery by name, so custom skills, agents,
commands, and hooks survive. On a 9.0 project it only refreshes the
framework-owned files and adds `REVIEW.md`. It backs everything up first, replaces the drifted
entry points with the v9 contract, and refuses to run inside a git worktree.

## Contracts

| File | Purpose |
|---|---|
| `PROJECT.md` | Stack, architecture, commands, project facts |
| `AGENTS.md` | The shared agent contract — behaviour, gates, constraints |
| `CLAUDE.md` | `@AGENTS.md` plus Claude-only conveniences |
| `REVIEW.md` | The review policy both review paths apply |
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

## Security scanning

Codex Security is an optional, explicit pre-merge check for changes that affect an
attack surface: authentication, permissions, public APIs, uploads, payments,
secrets, or database access. It does not run as a hook and it is not a replacement
for tests or code review.

Install the CLI through the access path approved for your organisation, then point
the wrapper at its executable. The wrapper never adds an npm dependency to the
project, never reads credentials from project files, and writes results outside
the repository with private permissions. See the [Codex Security CLI
quickstart](https://learn.chatgpt.com/docs/security/cli) for access and local
authentication requirements:

```bash
CODEX_SECURITY_BIN=/approved/path/codex-security \
  scripts/security-scan.sh --working-tree --dry-run

CODEX_SECURITY_BIN=/approved/path/codex-security \
  scripts/security-scan.sh --diff origin/main --mode standard
```

Start CI in advisory mode and preserve JSON/SARIF results for review. After the
repository has a useful baseline, add `--fail-on-severity high` to the PR scan.
Keep the CI credential scoped to the scan step and install the approved CLI outside
the checkout, as required by the [Codex Security CI guidance](https://learn.chatgpt.com/docs/security/cli/ci).

## Verification

```bash
bash tests/run.sh
```

The suite covers CC/CX parity, sprint validation, hook behaviour, generated
artifacts, migration preservation, worktree coordination, headless review
parsing, security-scan behaviour, documentation drift, the eval harness, and
end-to-end smoke behaviour.

## Behavioural evals

`tests/run.sh` proves the machinery works. It does not prove that an agent
loading `AGENTS.md` behaves as the contract says. `tests/evals/` holds small
real tasks with deterministic checks for that — run them before changing the
contract, a hook, or the review policy, and again after:

```bash
scripts/run-evals.sh --list
scripts/run-evals.sh --tool claude
scripts/run-evals.sh --tool codex --case fix-keeps-tests
```

Each case builds a throwaway project with the framework installed, runs the
agent headless on `task.md`, and runs `check.sh` against the result. Add a case
whenever an agent gets something wrong twice; see `tests/evals/README.md`.

```bash
shellcheck setup-project.sh migrate-project.sh migrate-to-v9.sh scripts/*.sh tests/*.sh
git diff --check
```

## Structure

```text
core/       Runtime templates: the shared contract and both hook configurations
.claude/    Claude commands, subagents, and source settings
hooks/      Shared deterministic lifecycle hooks
scripts/    Validation, install, review, security-scan, and worktree tools
templates/  Project and schema templates
tests/      Dependency-light unit and integration suites
archive/    Retired components, kept for reference and recovery
```

## Release history

See [CHANGELOG.md](CHANGELOG.md) and the `VERSION` file. Public distribution
also requires the repository owner to select and add an explicit software
license.
