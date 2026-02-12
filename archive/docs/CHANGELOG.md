# Changelog

All notable changes to DG-VibeCoding-Framework.

## [4.0.0] - 2026-02-12

### Philosophy Change
- **Equal Partnership:** CC and CX are now equal partners, not architect/executor
- Shared task board (`.tasks/board.md`) replaces spec-factory pipeline
- Both agents read `PROJECT.md` for context

```
v3.1.0:  Claude (Architect) ──spec──> Codex (Executor)
v4.0.0:  CC (Partner) <──.tasks/──> CX (Partner)
```

### Added
- `core/AGENTS.md` — CX entry point (equivalent to CLAUDE.md for Codex)
- `partnership` skill — CC + CX coordination, worktree patterns, handoff protocol
- `/handoff` command — Hand off tasks to CX partner with worktree setup
- `/peer-review` command — Agent-agnostic peer code review (replaces `/codex-review`)
- `/sync-tasks` command — Task board status and CX branch overview
- `templates/tasks-board.template.md` — Shared task board template
- `templates/project-init/AGENTS.md` — CX starter template
- `scripts/worktree-setup.sh` — Generic worktree setup with auto-detect package manager
- `scripts/worktree-cleanup.sh` — Safe worktree removal with uncommitted change check
- Agent Coordination section in `core/CLAUDE.md` and `core/PROJECT.md`
- CX routing in `/orchestrate` agent matrix

### Changed
- `core/CLAUDE.md` — Updated skills/commands lists, added Agent Coordination section
- `core/PROJECT.md` — Added Agent Coordination section
- `/orchestrate` — Added CX to agent routing matrix
- `setup-project.sh` — Now copies AGENTS.md, .tasks/board.md, worktree scripts (8 steps)
- `migrate-project.sh` — Added v3→v4 migration path (9 steps)
- `framework.json` — v4.0.0, agents block, tasks path, codex_config path

### Removed
- `codex` skill → archived to `archive/skills/codex/`
- `spec-factory` skill → archived to `archive/skills/spec-factory/`
- `/spec` command → archived to `archive/commands/`, replaced by `/handoff`
- `/codex-review` command → archived to `archive/commands/`, replaced by `/peer-review`
- `templates/codex-spec.template.md` → archived

### Migration
Run `./migrate-project.sh` to migrate v3.x projects to v4.0.0.

---

## [3.1.0] - 2025-01-25

### Added
- **Spec-Factory Model** — Claude + Codex tandem workflow for large implementations
- `/spec` command — Generate structured implementation specs for Codex
- `/spec --execute` — Auto-execute specs via Codex headlessly (no manual copy-paste!)
- `spec-factory` skill — Workflow guidance for Claude-Codex collaboration
- `templates/codex-spec.template.md` — Spec structure template

### Headless Claude-Codex Communication
```bash
# Claude can now invoke Codex automatically:
codex exec --json --sandbox workspace-write --full-auto "spec"
```

### Philosophy
- Claude as **Architect**: Handles ambiguity, design, edge cases, reasoning
- Codex as **Executor**: Receives clear spec, handles large volume, autonomous execution

### Complexity Router
| Complexity | Files | Approach |
|------------|-------|----------|
| LOW | 1-2 | Direct to Codex |
| MEDIUM | 3-5 | Brief spec + Codex |
| HIGH | 6+ | Full `/spec` workflow |

---

## [3.0.1] - 2025-01-25

### Changed
- **Simplified structure**: 82 → ~35 files
- **6 core skills**: sub-agent, debugging, testing, git, vibecoding, codex
- **7 universal commands**: feature, done, review, fix, orchestrate, codex-review, framework-update
- **5 starter agents**: orchestrator, implementer, reviewer, tester, debugger
- **CLAUDE.md**: Reduced from 512 to ~95 lines

### Added
- `framework.json` — Central configuration (no hardcoded paths)
- `/framework-update` command — Check for Claude Code updates
- `templates/` — Project initialization templates
- `archive/` — Project-specific components preserved

### Removed
- Outdated: REASONING_MODES.md, WORKTREE_ISOLATION.md, SESSION_LOG.md
- Empty directories: meta/, scale/, devops/, prompts/
- Session commands: start-session, end-session, iterate
- Sprint commands: sprint-init, sprint-reconstruct, sprint-status, sprint-validate
- Specialist agents: 11 moved to archive/

### Codex Integration
- Retained: `/codex-review` command with CLI support
- Prepared: Cloud and GitHub Action integration (framework.json flags)

## [2.7] - 2025-01-08

- Previous stable version
- 82 files, 23 skills, 17 commands, 17 agents
- Full feature set with project-specific components

---

## Migration

- **v3.x → v4.0.0:** Run `./migrate-project.sh`
- **v2.x → v4.0.0:** Run `./migrate-project.sh` (handles both paths)

## Archive

Project-specific and deprecated components preserved in `archive/`:
- `archive/skills/` — codex, spec-factory, + 16 project-specific
- `archive/agents/` — 11 specialist agents
- `archive/commands/` — spec, codex-review, codex-spec.template, + 14 workflow commands
- `archive/hooks/` — 4 additional hooks
