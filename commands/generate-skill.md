# Command: /generate-skill

## Purpose

Creates a new reusable skill from a successful implementation pattern. Part of the meta-programming system.

**Skills location:** `.claude/skills/` (Anthropic v2.0+ format)

## Usage

```
/generate-skill <skill-name> [options]
```

## When to Use

- After implementing a pattern 3+ times
- When a solution should be reusable
- To document complex implementations
- To share knowledge across projects

## Options

| Option | Description | Default |
|--------|-------------|---------|
| --from <file> | Base skill on specific file | - |
| --category <cat> | Skill category | component |
| --complexity <c> | low\|medium\|high | medium |
| --tags <list> | Comma-separated tags | - |

## Skill Categories

| Category | For |
|----------|-----|
| component | UI components |
| hook | Custom React hooks |
| api | API patterns |
| pattern | Design patterns |
| workflow | Dev workflows |
| integration | External services |
| utility | Helper functions |

## Workflow

```
/generate-skill modal-dialog --category component
                ↓
      Analyze Implementation
                ↓
      Extract Key Steps
                ↓
      Identify Variations
                ↓
      Document Pitfalls
                ↓
      Generate Skill File
                ↓
      Save to .claude/skills/
```

## Output

Creates a file at `.claude/skills/<skill-name>.md` with:

```markdown
---
name: <skill-name>
description: "<Brief description for auto-activation>"
---

# <Skill Name>

> <Brief description>

---

## When to Use

<Detected trigger conditions>

---

## Implementation

<Step-by-step guide from analyzed code>

---

## Examples

<Extracted from source>

---

## Variations

<Detected variations>

---

## Common Pitfalls

<From error patterns>
```

## Examples

### Example 1: Component Skill

```
/generate-skill form-with-validation --from src/components/ContactForm.tsx --category component

✓ Analyzed: src/components/ContactForm.tsx
✓ Detected patterns:
  - React Hook Form usage
  - Zod schema validation
  - Error message display
  - Submit handling

✓ Generated: .claude/skills/form-with-validation.md

Skill includes:
- 5 implementation steps
- 2 variations (simple/complex)
- 3 common pitfalls documented
```

### Example 2: API Skill

```
/generate-skill crud-endpoint --category api --complexity medium

✓ Scanned: 8 API routes
✓ Common pattern detected:
  - Input validation
  - Error handling
  - Response formatting

✓ Generated: .claude/skills/crud-endpoint.md
```

### Example 3: Hook Skill

```
/generate-skill use-debounced-search --from src/hooks/useSearch.ts --category hook

✓ Analyzed hook structure
✓ Detected:
  - Debounce logic
  - State management
  - Cleanup handling

✓ Generated: .claude/skills/use-debounced-search.md
```

## Quality Checks

Generated skills are validated for:
- [ ] Clear, actionable steps
- [ ] Working code examples
- [ ] Documented edge cases
- [ ] Proper error handling
- [ ] Reusability across projects

## Post-Generation

After generation:
1. Review generated skill
2. Adjust examples if needed
3. Test with a new implementation
4. Skill auto-activates based on description keywords

---

*Part of DG-SuperVibe-Framework v2.3 Meta-Programming System*
