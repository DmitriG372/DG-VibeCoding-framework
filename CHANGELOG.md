# Changelog

All notable changes to DG-VibeCoding-Framework.

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

Run `./migrate-project.sh` to migrate existing projects to v3.0.1.

## Archive

Project-specific components preserved in `archive/`:
- `archive/skills/` — 16 skills (vue, react, nextjs, etc.)
- `archive/agents/` — 11 specialist agents
- `archive/commands/` — 14 workflow commands
