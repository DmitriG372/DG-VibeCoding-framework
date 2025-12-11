---
name: vibecoding
description: "VibeCoding methodology: context engineering, three development models (CEM/TDM/IAM), AI orchestration patterns"
---

# VibeCoding Methodology

> Context Engineering First - Developer as orchestrator, AI as generator.

---

## Core Concept

### Traditional vs VibeCoding Mindset
```
Old: "How do I write code?"
New: "How do I curate context?"
```

### Triadic Relationship
```
Developer (Orchestra Leader)
    ↕
PROJECT.md (Context Hub)
    ↕
AI Agent (Code Generator)
```

---

## Three Development Models

### Level 1: Context-Enhanced Model (CEM)
**When:** Basic features, clear requirements
**Focus:** Provide context, let AI generate

```markdown
## Context
**Stack:** Next.js 14, TypeScript, Supabase
**Patterns:** REST API, Server Components

## Active Work
- [ ] Create user profile endpoint
  - Returns user data with avatar
  - Use Supabase RLS
```

### Level 2: Test-Driven Model (TDM)
**When:** Complex logic, need validation
**Focus:** Define tests first, AI implements to pass

```markdown
## Tests Required
- [ ] userService.getProfile returns user with avatar
- [ ] Returns null for non-existent user
- [ ] Throws on invalid UUID
```

### Level 3: Iterative Architecture Model (IAM)
**When:** Complex systems, multi-step
**Focus:** Break into phases, iterate

```markdown
## Phase 1: Core API
- [ ] Basic CRUD endpoints
- [ ] Error handling

## Phase 2: Business Logic
- [ ] Validation rules
- [ ] Access control

## Phase 3: Optimization
- [ ] Caching
- [ ] Performance
```

---

## Context Engineering

### Minimal Context Loading
```
1. PROJECT.md (always)
2. One relevant skill
3. Feature context (if complex)
```

### Context Refresh
- After major changes
- When switching features
- If AI seems "lost"

### Red Flags
- AI repeating mistakes
- Suggestions don't match codebase
- Missing recent changes

**Solution:** Reload context with fresh PROJECT.md

---

## Session Flow

```
Start Session
    │
    ▼
Read PROJECT.md
    │
    ▼
Skills auto-activate
    │
    ▼
Work on task
    │
    ▼
Update PROJECT.md
    │
    ▼
Commit with context
```
