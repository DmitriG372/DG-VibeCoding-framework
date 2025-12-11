---
name: framework-philosophy
description: "Core AI-driven development principles: context engineering, PROJECT.md hub, modularity, feature-based decomposition"
---

# Framework Philosophy

> Context Engineering First - Developer as orchestrator, AI as generator.

---

## Core Principles

### 1. PROJECT.md as Single Source of Truth

```
PROJECT.md
├── 🎯 Active Tasks (current focus)
├── ✅ Completed (reference)
├── 📋 Backlog (prioritized)
└── 📌 Context (always loaded)
```

**Rule:** Update PROJECT.md FIRST before any work.

### 2. Modular Context Loading

```
Minimal Context → More as Needed
```

**Load Order:**
1. PROJECT.md (always)
2. Relevant skill (1-2 max)
3. Feature context (if needed)

### 3. Feature-Based Decomposition

```
Bad:  components/, services/, utils/
Good: features/auth/, features/projects/, features/tasks/
```

Each feature folder is self-contained:
```
features/auth/
├── components/
├── hooks/
├── services/
└── types.ts
```

### 4. Small PRs, Fast Iteration

```
One feature → One PR → One review
```

**Target:** < 400 lines changed per PR

---

## Decision Matrix

### Project Size

| Size | Views | Recommended Approach |
|------|-------|---------------------|
| Small | < 10 | Single file context |
| Medium | 10-30 | Modular skills |
| Large | 30+ | Feature folders |

### Complexity

| Complexity | Approach |
|------------|----------|
| Simple CRUD | Direct implementation |
| Business logic | TDD (tests first) |
| Complex workflows | Plan first, implement second |

---

## Anti-Patterns

### DON'T

- Put detailed plans in PROJECT.md (use docs/)
- Load all skills at once
- Write code without reading PROJECT.md first
- Create god-files (> 500 lines)
- Skip tests for business logic

### DO

- Keep PROJECT.md concise
- Load skills on-demand
- Update task status immediately
- Split large files
- Write tests for complex logic
