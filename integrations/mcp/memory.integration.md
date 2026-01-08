# Memory MCP Integration

## Overview

Memory MCP provides persistent knowledge graph storage across sessions. Use it to remember project decisions, patterns, and context that should persist.

## When to Use

- Storing architectural decisions
- Remembering user preferences
- Tracking project patterns
- Maintaining context across sessions
- Building project knowledge base

## Available Tools

### Entity Operations
| Tool | Description |
|------|-------------|
| create_entities | Create new knowledge entities |
| delete_entities | Remove entities |
| add_observations | Add info to existing entities |
| delete_observations | Remove specific observations |

### Relation Operations
| Tool | Description |
|------|-------------|
| create_relations | Link entities together |
| delete_relations | Remove links |

### Query Operations
| Tool | Description |
|------|-------------|
| read_graph | Get entire knowledge graph |
| search_nodes | Find entities by query |
| open_nodes | Get specific entities by name |

## Entity Structure

```yaml
entity:
  name: "unique-identifier"
  entityType: "type-category"
  observations:
    - "fact or detail 1"
    - "fact or detail 2"
```

## Common Entity Types

| Type | Use For |
|------|---------|
| Project | Project-level info |
| Decision | ADRs, choices made |
| Pattern | Code patterns used |
| Preference | User preferences |
| Convention | Naming, style conventions |
| Technology | Tech stack info |
| Person | Team member info |

## Integration Patterns

### Pattern 1: Store Decision
```yaml
workflow:
  1. create_entities:
       - name: "decision-auth-method"
         entityType: "Decision"
         observations:
           - "Chose JWT over sessions"
           - "Reason: stateless scaling"
           - "Date: 2025-11-29"
  2. create_relations:
       - from: "decision-auth-method"
         to: "project-main"
         relationType: "belongs_to"
```

### Pattern 2: Remember Preference
```yaml
workflow:
  1. create_entities:
       - name: "preference-code-style"
         entityType: "Preference"
         observations:
           - "Prefers explicit types"
           - "No default exports"
           - "Functional components only"
```

### Pattern 3: Query Context
```yaml
workflow:
  1. search_nodes: "auth"
  2. open_nodes: ["decision-auth-method"]
  3. Apply context to current task
```

## Auto-Trigger Keywords

Memory should be used when:
- "Remember that..."
- "We decided to..."
- "The pattern we use is..."
- "Save this for later..."
- "What did we decide about...?"

## Relation Types

| Relation | Use For |
|----------|---------|
| belongs_to | Hierarchy |
| depends_on | Dependencies |
| implements | Implementation link |
| related_to | General association |
| replaces | Supersession |

## Best Practices

1. **Unique Names**: Use descriptive, unique entity names
2. **Consistent Types**: Stick to defined entity types
3. **Atomic Observations**: One fact per observation
4. **Clean Up**: Remove outdated entities
5. **Link Thoroughly**: Create relations for context

## Example Knowledge Graph

```
[Project: my-app]
    ├── belongs_to ← [Decision: auth-jwt]
    │                    └── observations:
    │                        - "Use JWT tokens"
    │                        - "Refresh token rotation"
    │
    ├── belongs_to ← [Pattern: error-handling]
    │                    └── observations:
    │                        - "Use Result type"
    │                        - "No throwing in business logic"
    │
    └── uses ← [Technology: next-15]
                   └── observations:
                       - "App router"
                       - "Server components default"
```

## Session Continuity

Memory enables continuity:
1. Start of session: `read_graph` or `search_nodes`
2. During work: `add_observations` for new learnings
3. Decisions made: `create_entities` for ADRs
4. End of session: Context persists automatically

---

*Part of DG-VibeCoding-Framework v2.6*
