# Core Skills Index

> Universal skills for any project. Load based on current task.

---

## Always Loaded

| Skill | Purpose | Tokens |
|-------|---------|--------|
| `framework-philosophy.skill` | Core principles: TDD, modularity, decomposition, migrations | ~400 |

This skill is automatically loaded via `CLAUDE.md`.

---

## Available Skills

### Architecture & Planning
| Skill | Load When | Tokens |
|-------|-----------|--------|
| `techstack.skill` | Starting new project, architecture decisions | ~400 |
| `vibecoding.skill` | Planning methodology (TDM/PDM/ICCM) | ~300 |

### Frontend
| Skill | Load When | Tokens |
|-------|-----------|--------|
| `react.skill` | React 18+ development | ~600 |
| `vue.skill` | Vue 3 + Composition API development | ~500 |
| `ui.skill` | Frontend design, CSS decomposition | ~300 |
| `vue-to-react.skill` | Migrating Vue → React | ~700 |

### Backend & Database
| Skill | Load When | Tokens |
|-------|-----------|--------|
| `api.skill` | REST API, service layer patterns | ~200 |
| `database.skill` | Schema design, queries, Supabase | ~600 |
| `supabase-migrations.skill` | Migration workflows, rollbacks, CI/CD | ~600 |

### Testing & Quality
| Skill | Load When | Tokens |
|-------|-----------|--------|
| `testing.skill` | Writing tests, TDD workflow | ~200 |
| `typescript.skill` | TypeScript patterns, types | ~400 |
| `security.skill` | Input validation, auth, CORS | ~300 |
| `debugging.skill` | Debugging techniques, logging | ~300 |

### Tooling
| Skill | Load When | Tokens |
|-------|-----------|--------|
| `git.skill` | Git workflows, commits, branching | ~300 |
| `cli.skill` | Shell commands, scripting | ~300 |
| `markdown.skill` | Documentation, README patterns | ~200 |
| `regex.skill` | Regular expressions | ~200 |

### AI & Orchestration
| Skill | Load When | Tokens |
|-------|-----------|--------|
| `openrouter.skill` | LLM API integration | ~300 |
| `sub-agent.skill` | Parallel tasks with Haiku sub-agents | ~800 |

---

## Loading Strategy

### Always Loaded (via CLAUDE.md)
```
framework-philosophy.skill
```

### Frontend Task
```
Load: ui.skill + [react.skill OR vue.skill]
```

### Full-Stack Feature
```
Load: [react.skill OR vue.skill] + api.skill + database.skill
```

### Database Work
```
Load: database.skill + supabase-migrations.skill
```

### Writing Tests
```
Load: testing.skill + [react.skill OR vue.skill]
```

### Vue → React Migration
```
Load: vue-to-react.skill + react.skill
```

### Parallel Work (Sub-Agents)
```
Load: sub-agent.skill + [task-specific skill]
```

### Starting New Project
```
Load: techstack.skill + vibecoding.skill
```

### AI-Powered App
```
Load: techstack.skill + openrouter.skill + database.skill + [react.skill OR vue.skill]
```

---

## Cross-References

Skills reference each other for consistency:

```
framework-philosophy.skill (ALWAYS LOADED)
    ↓ referenced by
├── techstack.skill     → Framework selection criteria
├── testing.skill       → TDD workflow
├── database.skill      → Migration-first principle
├── ui.skill            → CSS decomposition
├── api.skill           → Service layer pattern
├── react.skill         → When to use React
└── vue.skill           → When to use Vue
```

---

## Creating New Skills

### File Location
```
core-skills/[skill-name].skill
```

### Template
```markdown
# [Domain] Skill

> Brief description of what this skill covers.

**See also:** `framework-philosophy.skill` for [relevant principle].

---

## [Main Section]

### [Subsection]
[Content]

---

## Avoid

- [Anti-pattern 1]
- [Anti-pattern 2]
```

### Update This Index
After creating a new skill, add it to the appropriate table above.
