# Context Hierarchy System

## Overview

The context hierarchy system optimizes token usage by loading only the necessary context for each task. This ensures efficient use of Claude's context window while providing relevant information.

## Context Levels

### Level 0: Minimal (100-200 tokens)
**Use for:** Quick reference, simple queries, single-file fixes

**Loads:**
- Current file only
- Immediate imports

**Example tasks:**
- Fix a typo
- Add a console.log
- Simple syntax fix

### Level 1: Core (500-800 tokens)
**Use for:** Standard development tasks, single feature work

**Loads:**
- CLAUDE.md (core rules)
- Current file + direct dependencies
- Relevant skill file

**Example tasks:**
- Implement a simple function
- Add a new component
- Write unit tests for a function

### Level 2: Extended (1500-2500 tokens)
**Use for:** Complex features, multi-file changes

**Loads:**
- Level 1 content
- Relevant agent definitions
- Related components/modules
- Project patterns

**Example tasks:**
- Implement a feature with multiple components
- Refactor a module
- Add API endpoint with frontend

### Level 3: Comprehensive (3500-5000 tokens)
**Use for:** Large system changes, architectural work

**Loads:**
- Level 2 content
- Full agent protocol
- Architecture documentation
- Integration specifications

**Example tasks:**
- Design new subsystem
- Major refactoring
- Cross-cutting feature implementation

### Level 4: Maximum (Unlimited)
**Use for:** Full project analysis, audits

**Loads:**
- Everything available
- All documentation
- Full codebase analysis

**Example tasks:**
- Security audit
- Full code review
- Architecture documentation

## Automatic Level Detection

The system automatically selects context level based on task keywords:

| Keywords | Level |
|----------|-------|
| typo, fix, simple, quick | 0 |
| add, create, implement, test | 1 |
| feature, refactor, integrate | 2 |
| architecture, design, system | 3 |
| audit, review all, analyze | 4 |

## Context Loading Order

```
1. CLAUDE.md (always)
      ↓
2. Detect task complexity
      ↓
3. Load appropriate level
      ↓
4. Load relevant agents (if Level 2+)
      ↓
5. Load skills on-demand
```

## File Priority

When loading context, files are prioritized:

1. **Critical** (always loaded):
   - `core/CLAUDE.md`
   - Current working file

2. **High** (Level 1+):
   - Direct imports/dependencies
   - Relevant skill files
   - Project config files

3. **Medium** (Level 2+):
   - Agent definitions
   - Related components
   - Test files

4. **Low** (Level 3+):
   - Documentation
   - Architecture docs
   - Integration specs

5. **Reference** (Level 4):
   - All project files
   - Historical context

## Token Budget Management

### Budget Allocation
| Component | Max Budget % |
|-----------|--------------|
| Core instructions | 20% |
| Current context | 40% |
| Agent context | 20% |
| Skills/tools | 10% |
| Buffer | 10% |

### Overflow Handling
When context exceeds budget:
1. Summarize older context
2. Remove low-priority items
3. Keep only essential references
4. Use lazy loading for details

## Context Refresh Triggers

Context should be refreshed when:
- Switching to a different file
- Task type changes significantly
- User requests broader scope
- Error requires more context
- Agent delegation occurs

## Scale-Based Context

Context needs vary by project scale:

### SOLO Scale
- Minimal context needed
- Focus on current file
- Light documentation

### TEAM Scale
- Include conventions
- Load shared patterns
- Consider multiple perspectives

### SCALE Scale
- Full context often needed
- Architecture documentation important
- Integration points matter

## Implementation

### Context Request Format
```yaml
context_request:
  task: <task description>
  current_file: <file path>
  keywords: [<keyword1>, <keyword2>]
  explicit_level: <optional override>
```

### Context Response Format
```yaml
context_response:
  level: <0-4>
  loaded:
    core:
      - <file1>
    agents:
      - <agent1>
    skills:
      - <skill1>
    files:
      - <file1>
  token_estimate: <number>
  can_expand: <true/false>
```

## Best Practices

1. **Start Small**: Begin with Level 1, expand if needed
2. **Explicit When Unsure**: Use explicit level for complex tasks
3. **Monitor Usage**: Track token consumption
4. **Refresh Often**: Don't let stale context accumulate
5. **Trust the System**: Automatic detection works for most cases

---

*Part of DG-SuperVibe-Framework v2.0*
