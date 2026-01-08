---
name: sub-agent
description: "Sub-agent orchestration patterns: when to use Haiku agents, task decomposition, parallel execution"
context: fork
agent: haiku
allowed-tools:
  - Task
  - Read
  - Glob
  - Grep
---

# Sub-Agent Orchestration

> Patterns for orchestrating Haiku sub-agents with Opus/Sonnet.

---

## When to Use Sub-Agents

### Good Use Cases
- **Parallel tasks** - Independent tasks that can run simultaneously
- **Token-intensive** - Code generation, large file analysis
- **Repetitive** - Same operation on multiple files
- **Batch processing** - Generate tests for 10 functions

### When NOT to Use
- **Full context needed** - Tasks requiring entire codebase understanding
- **Sequential dependencies** - Step 2 depends on step 1 output
- **Quick operations** - Overhead exceeds benefit
- **Complex decisions** - Architectural choices need orchestrator

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│              OPUS/SONNET (Orchestrator)                 │
│  • Reads PROJECT.md for context                         │
│  • Skills auto-activate based on task                   │
│  • Decomposes task into sub-tasks                       │
│  • Spawns sub-agents                                    │
│  • Aggregates and validates results                     │
└─────────────────────┬───────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│    HAIKU      │ │    HAIKU      │ │    HAIKU      │
│  Sub-Agent    │ │  Sub-Agent    │ │  Sub-Agent    │
│               │ │               │ │               │
│ 1 skill       │ │ 1 skill       │ │ 1 skill       │
│ 1 task        │ │ 1 task        │ │ 1 task        │
│ 1 output      │ │ 1 output      │ │ 1 output      │
└───────────────┘ └───────────────┘ └───────────────┘
```

---

## Sub-Agent Prompt Template

```markdown
# Task: [Specific task name]

## Context
- Project: [Brief project description]
- File: [Target file path]
- Pattern: [Relevant pattern from skill]

## Requirements
1. [Specific requirement 1]
2. [Specific requirement 2]
3. [Specific requirement 3]

## Constraints
- Do NOT modify other files
- Follow existing code style
- Output only the requested content

## Output Format
[Specify exact format: code, JSON, markdown, etc.]
```

---

## Decomposition Patterns

### File-Based Decomposition
```markdown
Task: "Migrate 5 Vue components to React"

Sub-tasks:
1. Migrate UserCard.vue → UserCard.tsx
2. Migrate ProjectList.vue → ProjectList.tsx
3. Migrate TaskItem.vue → TaskItem.tsx
4. Migrate Header.vue → Header.tsx
5. Migrate Footer.vue → Footer.tsx
```

### Function-Based Decomposition
```markdown
Task: "Add error handling to all API functions"

Sub-tasks:
1. Add error handling to getUsers()
2. Add error handling to createProject()
3. Add error handling to updateTask()
4. Add error handling to deleteItem()
```

### Type-Based Decomposition
```markdown
Task: "Generate TypeScript types for database tables"

Sub-tasks:
1. Generate types for users table
2. Generate types for projects table
3. Generate types for tasks table
4. Generate types for comments table
```

---

## Orchestrator Pattern

```typescript
// Pseudo-code for orchestration
async function orchestrate(mainTask: string) {
  // 1. Analyze and decompose
  const subTasks = decomposeTask(mainTask)

  // 2. Execute in parallel
  const results = await Promise.all(
    subTasks.map(task => executeSubAgent(task))
  )

  // 3. Validate results
  const validated = results.filter(validateResult)

  // 4. Aggregate
  return aggregateResults(validated)
}
```

---

## Result Validation

### Orchestrator Checklist
After receiving sub-agent output:

1. **Syntax check** - Does code compile/parse?
2. **Pattern adherence** - Follows project conventions?
3. **Completeness** - All requirements met?
4. **Integration** - Works with existing code?

### Common Issues
- Missing imports
- Type mismatches
- Style inconsistencies
- Incomplete implementations

---

## Cost Efficiency

### Token Optimization
```markdown
Sub-agent receives:
- 1 focused skill (not all skills)
- Minimal context (only relevant parts)
- Specific task (not whole feature)

Result:
- Lower token usage per agent
- Faster execution
- Predictable output
```

### Parallel vs Sequential
```markdown
Parallel (when independent):
- 5 file migrations → 5 agents simultaneously
- ~5x faster than sequential

Sequential (when dependent):
- API endpoint → then tests → then docs
- Each step needs previous output
```

---

## Best Practices

### DO
- Give each sub-agent one clear task
- Provide complete context in prompt
- Specify exact output format
- Validate all results before using

### DON'T
- Pass entire codebase to sub-agent
- Chain dependent tasks without validation
- Skip result review
- Use for tasks requiring full context
