# Framework Components

Authoritative lists live in `framework.json`. This file is a one-screen pointer.

| Kind | Where | What it is |
|------|-------|-----------|
| Skills | `.claude/skills/<name>/SKILL.md` + `references/` | Progressive-disclosure knowledge with trigger + negative_triggers frontmatter |
| Agents | `.claude/agents/<name>.md` | Specialist sub-agents with tool restrictions and `model: inherit` |
| Commands | `.claude/commands/<name>.md` | Thin slash-command wrappers over skills + agents |
| Hooks | `hooks/<name>.js` | Lifecycle automation wired via `core/settings.template.json` |
| Rules | `.claude/rules/<name>.md` | Path-specific and global constraints loaded on demand |

Decision framework:
- **Repeatable workflow with guidance** → skill
- **Isolated context window / adversarial task** → agent
- **Inner-loop repetition ("commit", "done", "feature")** → command
- **Lifecycle automation with Exit Code 2 enforcement** → hook
- **Negative constraints & global rules** → `.claude/rules/`
