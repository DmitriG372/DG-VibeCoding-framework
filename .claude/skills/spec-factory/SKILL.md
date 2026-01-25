---
name: spec-factory
description: "Claude + Codex tandem workflow for large implementations. Aktiveerub kui mainitakse spec, specification, Codex implementation, implementation guide, Claude+Codex, tandem workflow, või suur ülesanne."
---

# Spec-Factory Skill

## Philosophy

```
┌─────────────────────────────────────────────────────────────┐
│  SPEC-FACTORY MODEL                                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Claude (Architect)          Codex (Executor)               │
│  ┌─────────────────┐         ┌─────────────────┐           │
│  │ • Ambiguity     │         │ • Clear spec    │           │
│  │ • Design        │  ──────>│ • Large volume  │           │
│  │ • Edge cases    │  Spec   │ • Autonomy      │           │
│  │ • Reasoning     │         │ • Execution     │           │
│  └─────────────────┘         └─────────────────┘           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

> **Core Principle:** Claude does NOT write code — Claude creates a *perfect specification* for Codex.

## When to Use Spec-Factory

### Use Spec-Factory (HIGH Complexity)
- 6+ files need modification
- New business logic with multiple edge cases
- Database schema changes
- Authentication/authorization implementation
- API design with multiple endpoints
- State management refactoring
- Multi-component feature implementation

### Use Direct Codex (LOW-MEDIUM Complexity)
- 1-2 file modifications
- Simple UI changes
- Adding a single function
- Bug fixes with clear cause
- Configuration changes
- Documentation updates

## Complexity Router

| Indicator | LOW | MEDIUM | HIGH |
|-----------|-----|--------|------|
| Files affected | 1-2 | 3-5 | 6+ |
| New logic | None | Some | Complex |
| Edge cases | 0 | 1-3 | 4+ |
| Database | No | Query only | Schema change |
| External APIs | No | Read | Write/Auth |
| State changes | Local | Component | Global |

**Decision:**
- LOW → Send directly to Codex
- MEDIUM → Brief spec + Codex
- HIGH → Full `/spec` workflow

## Spec Structure

A complete spec contains:

1. **Context** — Project info, tech stack, conventions
2. **Requirements** — MUST have (specific, measurable)
3. **Constraints** — MUST NOT do (explicit boundaries)
4. **Implementation Steps** — Ordered steps with file paths
5. **Edge Cases** — How to handle unusual inputs
6. **Verification** — Tests and expected outcomes
7. **Out of Scope** — Explicit exclusions

## Workflow

### Manual Mode (`/spec`)

```
User Request → Claude Clarifies → Claude Generates Spec →
User Copies to Codex → Codex Implements → /codex-review
```

### Auto-Execute Mode (`/spec --execute`)

```
┌──────────────────────────────────────────────────────────────┐
│ 1. User Request                                              │
│    /spec --execute "Add user authentication with JWT"        │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│ 2. Claude Clarifies (if needed)                              │
│    - What auth provider?                                     │
│    - Token storage?                                          │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│ 3. Claude Generates Spec                                     │
│    - Saves to /tmp/codex-spec-{timestamp}.md                 │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│ 4. Claude Executes Codex Headlessly                          │
│    codex exec --json --sandbox workspace-write --full-auto   │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│ 5. Claude Parses JSON Results                                │
│    - Extract actions taken                                   │
│    - List modified files                                     │
│    - Show Codex summary                                      │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│ 6. Automatic Review                                          │
│    - /codex-review on modified files                         │
│    - Claude fixes any issues found                           │
└──────────────────────────────────────────────────────────────┘
```

## Headless Communication

Claude and Codex communicate via `codex exec`:

```bash
# Read-only analysis
codex exec --json --sandbox read-only "Analyze this code"

# Code implementation
codex exec --json --sandbox workspace-write --full-auto "Implement X"

# Parse results
... | jq -r 'select(.type == "item.completed" and .item.type == "agent_message") | .item.text'
```

**JSON Event Types:**
| Type | Description |
|------|-------------|
| `thread.started` | Session ID |
| `turn.started/completed` | Turn lifecycle |
| `item.completed` + `reasoning` | Codex thinking |
| `item.completed` + `command_execution` | Shell commands |
| `item.completed` + `agent_message` | Final response |

## Spec Validation Checklist

Before handing spec to Codex, verify:

### Requirements
- [ ] Each requirement is specific and measurable
- [ ] No ambiguous language ("should", "maybe", "consider")
- [ ] Acceptance criteria are clear

### Constraints
- [ ] Scope boundaries are explicit
- [ ] File modification limits defined
- [ ] Dependency rules stated

### Implementation Steps
- [ ] Exact file paths provided
- [ ] Step order is logical
- [ ] Code hints included where helpful

### Edge Cases
- [ ] Null/undefined handling specified
- [ ] Error scenarios covered
- [ ] Concurrent access considered

### Verification
- [ ] Test commands provided
- [ ] Expected output defined
- [ ] Manual checks listed

## Best Practices

### DO
- Ask clarifying questions BEFORE writing spec
- Include code structure hints (not full code)
- Be explicit about what NOT to change
- Provide file paths, not vague locations
- Include relevant existing patterns to follow

### DON'T
- Write the actual implementation code
- Leave requirements ambiguous
- Assume Codex knows project conventions
- Skip edge case analysis
- Forget to define verification steps

## Integration with Other Commands

| Command | When | Workflow |
|---------|------|----------|
| `/spec` | Before large implementation | Generate spec → Copy to Codex |
| `/codex-review` | After Codex completes | Review quality → Fix issues |
| `/feature` | After spec approved | Track implementation progress |
| `/done` | After verification | Complete with tests and commit |

## Example Scenarios

### Scenario 1: Add OAuth Login

```
User: "Add Google OAuth login"

Claude: (asks clarifying questions)
- Use NextAuth.js or custom implementation?
- Store session in JWT or database?
- Which routes should be protected?
- Need refresh token handling?

User: (provides answers)

Claude: (generates full spec with)
- Context: Next.js 14, App Router, Prisma
- Requirements: Google OAuth, JWT sessions, /dashboard protected
- Constraints: Don't modify existing auth
- Steps: 1. Install dependencies, 2. Configure NextAuth, etc.
- Edge cases: Token expiry, OAuth failure, etc.
- Verification: Login flow test, token validation
```

### Scenario 2: Database Schema Migration

```
User: "Add user preferences table"

Claude: (routes as HIGH complexity - schema change)

Claude: (asks)
- What preferences? (theme, notifications, language)
- Relationship to users table?
- Default values needed?
- Migration strategy?

Claude: (generates spec with)
- Exact migration SQL
- Model updates
- API endpoint changes
- Validation rules
```

## Codex Output Translation

When Codex returns results:

1. **Success** → Verify with `/codex-review`
2. **Partial** → Note incomplete items, create follow-up spec
3. **Questions** → Answer in Codex, or revise spec
4. **Errors** → Analyze, fix spec, retry

---

*Part of DG-VibeCoding-Framework v3.1.0 — Spec-Factory Workflow*
