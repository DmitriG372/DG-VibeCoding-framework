# Skill Generator

## Overview

The Skill Generator creates new skills based on patterns detected in successful implementations. It enables the framework to learn and expand its capabilities.

## Purpose

- Codify successful patterns into reusable skills
- Reduce repetitive explanations
- Maintain consistent quality
- Build project-specific knowledge

## Skill Structure (Anthropic v2.0+ Format)

Skills are stored in `.claude/skills/*.md` with YAML frontmatter:

```yaml
---
name: <skill-name>
description: "<Brief description for auto-activation>"
---

# <Skill Name>

> <Brief description>

---

## When to Use

<Trigger conditions>

---

## Implementation

<Step-by-step guide>

---

## Examples

<Code examples>

---

## Common Pitfalls

<What to avoid>
```

## Generation Process

### 1. Pattern Detection
```
Observe repeated implementations
         ↓
Identify common structure
         ↓
Extract key steps
         ↓
Document variations
```

### 2. Skill Drafting
```yaml
input:
  - successful_implementations: [<examples>]
  - context: <project context>
  - category: <skill category>

output:
  - skill_file: <generated .md file in .claude/skills/>
  - validation_checklist: <quality checks>
```

### 3. Validation
- [ ] Skill is reusable across projects
- [ ] Steps are clear and complete
- [ ] Examples compile/work
- [ ] Edge cases documented
- [ ] Dependencies listed

## Skill Categories

| Category | Description | Examples |
|----------|-------------|----------|
| component | UI component patterns | Modal, Form, Table |
| hook | Custom React hooks | useForm, useAPI |
| api | API patterns | CRUD endpoint, Auth |
| pattern | Design patterns | Repository, Factory |
| workflow | Development workflows | PR process, Deploy |
| integration | External integrations | Stripe, Auth0 |

## Generation Triggers

Generate new skill when:
- Same pattern implemented 3+ times
- User explicitly requests skill creation
- Complex implementation succeeds
- New pattern proves valuable

## Template

```markdown
---
skill: {{skill_name}}
category: {{category}}
complexity: {{complexity}}
requires: []
tags: []
---

# Skill: {{Skill Name}}

## Description

{{Brief description of what this skill enables}}

## When to Use

- {{Trigger condition 1}}
- {{Trigger condition 2}}

## Prerequisites

- {{Prerequisite 1}}
- {{Prerequisite 2}}

## Implementation

### Step 1: {{First Step}}
{{Description}}

\`\`\`typescript
{{Code example}}
\`\`\`

### Step 2: {{Second Step}}
{{Description}}

\`\`\`typescript
{{Code example}}
\`\`\`

## Complete Example

\`\`\`typescript
{{Full working example}}
\`\`\`

## Variations

### {{Variation 1}}
{{Description and code}}

### {{Variation 2}}
{{Description and code}}

## Common Pitfalls

1. **{{Pitfall 1}}**: {{How to avoid}}
2. **{{Pitfall 2}}**: {{How to avoid}}

## Related Skills

- [[skill-1]]
- [[skill-2]]
```

## Quality Criteria

### Good Skill
- ✅ Solves a real, recurring problem
- ✅ Clear, step-by-step instructions
- ✅ Working code examples
- ✅ Covers edge cases
- ✅ Links to related skills

### Bad Skill
- ❌ Too specific to one project
- ❌ Vague instructions
- ❌ Incomplete examples
- ❌ Missing error handling
- ❌ No context on when to use

## Usage

### Command: /generate-skill
```
/generate-skill <pattern-name>

Options:
  --from <file>     Base on specific implementation
  --category <cat>  Skill category
  --complexity <c>  low|medium|high
```

### Example
```
/generate-skill modal-component --category component --complexity medium
```

---

Part of DG-SuperVibe-Framework v2.3 Meta-Programming System
