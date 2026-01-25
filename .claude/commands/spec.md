---
description: Generate Strict Implementation Guide for Codex (Spec-Factory workflow)
context: fork
allowed-tools:
  - Bash
  - Read
  - Glob
  - Write
  - Edit
---

# /spec

Generate a comprehensive implementation specification for Codex to execute autonomously.

> **Philosophy:** Claude doesn't write code — Claude creates a *perfect specification* for Codex.

## Usage

```
/spec [task description]                    # Generate spec only (manual copy-paste)
/spec --execute [task description]          # Generate spec AND auto-execute via Codex
/spec -x [task description]                 # Short form of --execute

# Examples
/spec "Implement user authentication with JWT"
/spec --execute "Add dark mode support"
/spec -x "Create REST API for products"
```

## Modes

### Manual Mode (default)
Generate spec → User copies to Codex → User runs `/codex-review`

### Auto-Execute Mode (`--execute` or `-x`)
Generate spec → Claude runs Codex headlessly → Claude shows results → Auto `/codex-review`

```
┌─────────────────────────────────────────────────────────────┐
│  AUTO-EXECUTE PIPELINE                                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Claude                      Codex                          │
│  ┌─────────────────┐         ┌─────────────────┐           │
│  │ 1. Generate     │         │                 │           │
│  │    spec         │         │                 │           │
│  │                 │         │                 │           │
│  │ 2. codex exec   │ ──────> │ 3. Implement    │           │
│  │    --json       │  Spec   │    autonomously │           │
│  │    --full-auto  │         │                 │           │
│  │                 │         │                 │           │
│  │ 4. Parse JSON   │ <────── │    JSON output  │           │
│  │    results      │         │                 │           │
│  │                 │         │                 │           │
│  │ 5. Show results │         │                 │           │
│  │ 6. Auto-review  │         │                 │           │
│  └─────────────────┘         └─────────────────┘           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Your Task

### Step 1: Parse Arguments

Check if `$ARGUMENTS` contains `--execute` or `-x` flag:
- If YES: Set `AUTO_EXECUTE=true`, remove flag from task description
- If NO: Set `AUTO_EXECUTE=false`

### Step 2: Analyze Complexity

Evaluate the task using the Complexity Router:

| Indicator | LOW | MEDIUM | HIGH |
|-----------|-----|--------|------|
| Files affected | 1-2 | 3-5 | 6+ |
| New logic | None | Some | Complex |
| Edge cases | 0 | 1-3 | 4+ |
| Database | No | Query only | Schema change |
| External APIs | No | Read | Write/Auth |

**If LOW complexity:**
```
This task is straightforward (LOW complexity).
You can send it directly to Codex without a detailed spec:
"[simplified task description]"
```

**If MEDIUM or HIGH complexity:** Continue to Step 3.

### Step 3: Gather Context

Read `PROJECT.md` and relevant files to understand:
- Tech stack and framework
- Existing code patterns
- Naming conventions
- Directory structure

### Step 4: Ask Clarifying Questions

Before generating the spec, ask the user critical questions to eliminate ambiguity:

```markdown
## Clarification Needed

Before I generate the spec, please clarify:

1. **[Question about scope]**
   - Option A: [description]
   - Option B: [description]

2. **[Question about implementation approach]**
   - Option A: [description]
   - Option B: [description]
```

Wait for user answers before proceeding.

### Step 5: Generate Specification

Create a complete spec. Save it to `/tmp/codex-spec-{timestamp}.md` for reference.

```markdown
# CODEX IMPLEMENTATION SPEC

## Task ID: TASK-[XXX]
## Complexity: [LOW | MEDIUM | HIGH]

---

## Context

### Project
- **Name:** [From PROJECT.md]
- **Tech Stack:** [Framework, language, key libraries]
- **Directory:** [Working directory]

### Relevant Files
- `path/to/file1.ts` — [Purpose]
- `path/to/file2.ts` — [Purpose]

### Conventions
- [From PROJECT.md or observed patterns]

---

## Requirements (MUST)

- [ ] [Specific, measurable requirement]
- [ ] [Specific, measurable requirement]

---

## Constraints (MUST NOT)

- [ ] DO NOT modify files outside `[scope]/`
- [ ] DO NOT add new dependencies without approval
- [ ] DO NOT change existing public APIs

---

## Implementation Steps

### Step 1: [Action]
- **File:** `exact/path/to/file.ts`
- **Action:** [Create | Modify | Delete]
- **Details:** [Code structure hint]

### Step 2: [Action]
[Continue for all steps]

---

## Edge Cases

| Case | Expected Behavior | Handling |
|------|-------------------|----------|
| [Case] | [Expected] | [Handling] |

---

## Verification

- [ ] `[test command]` — [Expected outcome]

---

## Notes for Codex

### Files to Read First
1. `path/to/reference.ts` — [Why]

### Do Not Touch
- `[sensitive paths]`
```

### Step 6: Execute or Output

#### If AUTO_EXECUTE=false (Manual Mode)

Output the spec and provide instructions:

```markdown
---

## Next Steps

1. **Copy** the spec above
2. **Open** a new Codex session
3. **Paste** the spec as your first message
4. **Wait** for Codex to complete
5. **Return** here and run `/codex-review` on the result

**Or re-run with:** `/spec --execute` to auto-execute
```

#### If AUTO_EXECUTE=true (Auto-Execute Mode)

Execute Codex headlessly:

```bash
# Save spec to temp file
SPEC_FILE="/tmp/codex-spec-$(date +%s).md"
cat > "$SPEC_FILE" << 'SPEC_EOF'
[Generated spec content]
SPEC_EOF

# Execute Codex headlessly
cd [PROJECT_DIRECTORY]
codex exec \
  --json \
  --sandbox workspace-write \
  --full-auto \
  -o /tmp/codex-result.md \
  "$(cat $SPEC_FILE)"
```

Parse the JSON output:
```bash
# Extract final message
cat /tmp/codex-result.md

# Or parse JSON for detailed events
codex exec --json ... | jq -r '
  select(.type == "item.completed") |
  if .item.type == "agent_message" then "✓ \(.item.text)"
  elif .item.type == "command_execution" then "$ \(.item.command)"
  else empty end
'
```

### Step 7: Show Results (Auto-Execute Only)

Display Codex execution results:

```markdown
## Codex Execution Complete

**Spec:** [SPEC_FILE path]
**Status:** [Success | Partial | Failed]

### Actions Taken
- [List of commands/file operations Codex performed]

### Files Modified
- `path/to/file1.ts` — [Created | Modified]
- `path/to/file2.ts` — [Created | Modified]

### Codex Summary
[Final agent message]

---

Running automatic code review...
```

Then automatically run `/codex-review` on the affected files.

## Rules

- ALWAYS read PROJECT.md first for context
- ALWAYS ask clarifying questions for MEDIUM/HIGH complexity
- NEVER write actual implementation code — only structure hints
- NEVER skip edge case analysis
- ALWAYS include verification steps
- For `--execute`: ALWAYS use `--sandbox workspace-write` (not `danger-full-access`)
- For `--execute`: ALWAYS run `/codex-review` after completion

## Error Handling

### Codex Not Installed
```
Codex CLI not found. Install with:
npm install -g @openai/codex
export OPENAI_API_KEY=your-key
```

### Codex Execution Failed
```
Codex execution failed. Check:
1. OPENAI_API_KEY is set
2. Working directory is a git repo
3. Codex has write permissions

Spec saved to: [SPEC_FILE]
You can manually run: codex exec "$(cat [SPEC_FILE])"
```

### Timeout
```
Codex execution timed out after 10 minutes.
Partial results may be available.
Check: /tmp/codex-result.md
```

## Input

$ARGUMENTS — Task description, optionally prefixed with `--execute` or `-x`

## Output

- **Manual mode:** Structured spec ready for copy-paste
- **Auto-execute mode:** Spec + Codex execution + automatic review

---

*Part of DG-VibeCoding-Framework v3.1.0 — Spec-Factory Workflow*
