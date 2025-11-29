# Project Skills Index

> Project-specific patterns. Load only when working on that specific project.

---

## Available Projects

| Project | Skill File | Description | Status |
|---------|------------|-------------|--------|
| Melior Plus MVP | `melior-patterns.skill` | Internal PM tool for electrical engineering | Active |

---

## When to Load

**Only load project skills when:**
- Working directly on that project
- Need project-specific conventions
- Implementing features for that project

**Do NOT load project skills when:**
- Working on different project
- General learning or exploration
- Project is completed/archived

---

## Current Project Skills

### melior-patterns.skill
**Project:** Melior Plus MVP
**Tech Stack:** Vue.js → React, Node.js + Express, Supabase, TypeScript
**Tokens:** ~500

**Contains:**
- API response format
- Authentication patterns
- Database schema conventions
- Frontend component structure
- Backend service patterns
- TypeScript types
- Naming conventions

**Load when:**
```
Working on Melior Plus → Load: melior-patterns.skill + [task skill]
```

---

## Creating New Project Skills

### When to Create
Create a project skill when:
- Project has unique conventions
- Multiple team members need same context
- Project deviates from standard patterns
- Custom API formats or data structures

### File Location
```
project-skills/[project-name]-patterns.skill
```

### Template
```markdown
# [Project Name] Patterns Skill

> [Brief project description]

**Tech Stack:** [Technologies used]
**Status:** [Active/Maintenance/Archived]

---

## Project Overview

[What this project does, who uses it]

---

## API Patterns

### Response Format
[Project-specific API conventions]

---

## Database Patterns

### Tables
[Key tables and relationships]

---

## Frontend Patterns

### Component Structure
[Project-specific component organization]

---

## Backend Patterns

### Service Layer
[Project-specific service conventions]

---

## Naming Conventions

[Project-specific naming rules]

---

## Avoid

- [Project-specific anti-patterns]
```

### After Creating
1. Add to the table above
2. Document when to load
3. Notify team members

---

## Archiving Project Skills

When a project is completed:
1. Move skill to `project-skills/archived/`
2. Update status in this index to "Archived"
3. Keep for reference (don't delete)
