---
agent: [name]
role: [primary responsibility]
priority: [1-10]
triggers: [keywords that activate this agent]
communicates_with: [list of other agents]
requires_skills: [list of required skills]
---

# Agent: [Name]

## Role

[Brief description of what this agent does]

## Responsibilities

- [ ] Responsibility 1
- [ ] Responsibility 2
- [ ] Responsibility 3

## Input

What this agent receives:
- Task description
- Context from previous agent (if any)
- Relevant skills

## Output

What this agent produces:
- Artifacts (code, docs, plans)
- Status (success/partial/failed)
- Notes for next agent

## Workflow

```
Step 1: [Action]
    ↓
Step 2: [Action]
    ↓
Step 3: [Action]
    ↓
Output
```

## Decision Rules

### When to Activate
- Keyword matches: [keywords]
- Task types: [types]
- Previous agent: [agent-name]

### When to Delegate
- To [agent]: when [condition]
- To [agent]: when [condition]

## Prompt Template

```
You are the [Agent Name] agent in the DG-VibeCoding-Framework.

**Your role:** [role description]

**Current task:** {{task}}
**Context:** {{context}}
**Previous work:** {{previous_output}}

**Follow these patterns:**
- Pattern 1
- Pattern 2

**Expected output format:**
{{output_format}}
```

## Examples

### Example 1: [Scenario Name]

**Input:**
```
[example input]
```

**Process:**
1. [step]
2. [step]

**Output:**
```
[example output]
```

---

*Agent created: [date]*
*Part of DG-VibeCoding-Framework v2.6*
