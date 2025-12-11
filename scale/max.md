# Scale: Max

> For complex, long-term projects

## When to Use

- Months of work
- Multiple features/modules
- Production deployment
- Needs long-term maintenance

## PROJECT.md Additions

Add these sections to your PROJECT.md:

```markdown
---

## Architecture

### System Overview
```
[Mermaid or ASCII diagram]
```

### Key Decisions (ADRs)
| Decision | Date | Status | Rationale |
|----------|------|--------|-----------|
| [What] | [When] | accepted | [Why] |

### Modules
- **[Module]**: [Purpose] — `src/[path]/`
- **[Module]**: [Purpose] — `src/[path]/`

### External Dependencies
- [Service]: [Purpose]
- [API]: [Purpose]

---

## Sprints

### Current: [Name] (W[XX])

**Goal:** [Sprint goal]
**Status:** [on-track/at-risk/blocked]

| Task | Status | Notes |
|------|--------|-------|
| [Task] | in-progress | [notes] |
| [Task] | pending | |

### Next Up
- [Planned sprint/feature]

<details>
<summary>Sprint History</summary>

| Sprint | Goal | Outcome |
|--------|------|---------|
| W[XX] | [goal] | [result] |

</details>

---

## Security

### Auth
- [Method]: [Details]

### Data Protection
- [Measure]: [Implementation]

### Known Risks
- [Risk]: [Mitigation]

---

## Performance

### Targets
- API response: < [X]ms
- Page load: < [X]s
- DB queries: < [X]ms

### Monitoring
- [Tool]: [What it monitors]

---

## Deployment

### Environments
| Env | URL | Branch |
|-----|-----|--------|
| prod | [url] | main |
| staging | [url] | dev |

### Process
1. [Step 1]
2. [Step 2]
3. [Step 3]
```

## DevOps

Add from `devops/`:
- `ci.yml` — Full CI/CD pipeline
- `pre-commit.yaml` — Quality gates

## Skills

Auto-activated from `.claude/skills/` as needed:

- `ui.md`
- `database.md`
- `testing.md`
- `api.md`
- Consider adding project-specific skills to `.claude/skills/`

## Workflow

```
Epic → Sprint Plan → Tasks → Branch → Code → Test → Review → Merge → Deploy → Monitor
```

Strict branching, mandatory reviews, automated deployment.
