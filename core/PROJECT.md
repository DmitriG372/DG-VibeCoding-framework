# Project: [NAME]

> Single source of truth. All other files reference this.

---

## Context

**Stack:** [e.g., Next.js 14, TypeScript, Supabase]
**Type:** [webapp/api/cli/library]
**Status:** [planning/active/maintenance]

<details>
<summary>Extended Context</summary>

**Repository:** [url]
**Deploy:** [url]
**Domain:** [brief description of problem domain]

</details>

---

## Tech Stack

### Core
- **Framework:** [e.g., Next.js 14]
- **Language:** [e.g., TypeScript 5.3]
- **Database:** [e.g., PostgreSQL via Supabase]
- **Styling:** [e.g., Tailwind CSS]

### Key Libraries
- [lib]: [purpose]
- [lib]: [purpose]

<details>
<summary>Dev Dependencies</summary>

- ESLint + Prettier
- Vitest / Jest
- [others]

</details>

---

## Structure

```
[project]/
├── src/
│   ├── app/          # Routes/pages
│   ├── components/   # UI components
│   ├── lib/          # Utilities
│   └── types/        # TypeScript types
├── tests/
└── docs/
```

---

## Current Sprint

### Active Tasks
- [ ] [Task 1] — [acceptance criteria]
- [ ] [Task 2] — [acceptance criteria]

### Completed
- [x] [Done task]

<details>
<summary>Backlog</summary>

- [ ] [Future task 1]
- [ ] [Future task 2]

</details>

---

## Patterns

### Code Style
- **Naming:** camelCase (vars), PascalCase (components)
- **Files:** kebab-case.ts
- **Max line:** 100 chars
- **Imports:** absolute paths (`@/`)

### Architecture
- [Pattern]: [where used]
- [Pattern]: [where used]

---

## Rules

### Always
- Write tests for new features
- Use TypeScript strict mode
- Handle errors explicitly

### Never
- Commit to main directly
- Push secrets to repo
- Skip pre-commit hooks

---

## Commands

```bash
# Dev
npm run dev           # Start dev server
npm run build         # Production build
npm run test          # Run tests

# Quality
npm run lint          # Lint code
npm run typecheck     # Type check
npm run format        # Format code
```

---

## Git

### Commit Format
```
<type>(<scope>): <description>

Types: feat, fix, refactor, docs, test, chore
```

### Branch Strategy
- `main` — production
- `dev` — development
- `feat/*` — features
- `fix/*` — bugfixes

---

## Skills (Auto-Activated)

Skills in `.claude/skills/` auto-activate based on task context:

- `ui.md` — Frontend/UI work
- `database.md` — DB/queries
- `testing.md` — Writing tests
- `api.md` — Building APIs

→ See `.claude/skills/` for all 22 skills
→ Claude auto-activates relevant skills based on task keywords

---

## Session Log

→ See `SESSION_LOG.md` for detailed session history

### Quick Status
**Last session:** [date]
**Focus:** [topic]
**Next priority:** [task]

---

## Iteration Log

Track significant attempts and learnings. Use `/iterate` to add entries.

### Recent Iterations

#### Attempt 1 — [date]
**Request:** [what was asked]
**Result:** [what happened]
**Feedback:** [what to improve]
**Learned:** [pattern for future]

<details>
<summary>Older iterations</summary>

[Previous iterations moved here after 5+ entries]

</details>

---

## Decisions Log

Track architectural and significant decisions. Reference these to avoid re-discussing.

| Date | Decision | Rationale | Alternatives |
|------|----------|-----------|--------------|
| [date] | [what was decided] | [why] | [what was considered] |

<details>
<summary>Decision template</summary>

```markdown
| 2025-01-15 | Use Zustand over Redux | Simpler API, smaller bundle, sufficient for app size | Redux, Jotai, Context |
```

</details>
