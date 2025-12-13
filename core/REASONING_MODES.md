# Claude Code Reasoning & Control Modes (v2.4)

> Optimize Claude's reasoning depth and control conversation flow

---

## Thinking Modes (Extended Reasoning)

Use these phrases to unlock deeper reasoning for complex tasks:

| Phrase | Reasoning Level | Token Budget | Use Case |
|--------|-----------------|--------------|----------|
| `"Think"` | Basic | ~500 | Simple logic, quick decisions |
| `"Think more"` | Extended | ~1500 | Multi-step problems |
| `"Think a lot"` | Comprehensive | ~3000 | Complex architecture |
| `"Think longer"` | Extended time | ~5000 | Deep debugging |
| `"Ultrathink"` | Maximum | ~10000+ | Critical decisions, complex algorithms |

### Usage Examples

```
"Ultrathink about the best way to implement real-time sync"
"Think a lot before refactoring this authentication flow"
"Think longer about this race condition"
```

### When to Use

| Task Type | Recommended Mode |
|-----------|------------------|
| Quick bug fix | No thinking mode needed |
| Standard implementation | "Think" |
| Multi-file refactoring | "Think more" |
| Architecture decisions | "Think a lot" |
| Complex debugging | "Think longer" |
| Security review, critical systems | "Ultrathink" |

### Integration with Framework

Combine with agents:
```
/orchestrate "Ultrathink: Design OAuth2 implementation with PKCE"
```

Combine with Plan Mode:
```
Shift+Tab twice → "Think a lot about implementation approach"
```

---

## Plan Mode vs Thinking Mode

| Mode | Purpose | Activation | Focus |
|------|---------|------------|-------|
| **Plan Mode** | Breadth | `Shift+Tab` (twice) | Research more files, detailed plan |
| **Thinking Mode** | Depth | Phrase in prompt | Complex logic, reasoning |

### Comparison

```
Plan Mode:
- Reads more files
- Creates implementation plan
- Good for multi-step tasks
- Good for understanding codebase

Thinking Mode:
- More reasoning tokens
- Deep logical analysis
- Good for tricky bugs
- Good for complex algorithms
```

### Combined Usage

For maximum effect on complex tasks:

1. Activate Plan Mode (`Shift+Tab` twice)
2. Add thinking phrase: "Ultrathink about this implementation"
3. Claude researches breadth (Plan) AND depth (Thinking)

**Warning:** Both modes consume extra tokens (cost consideration).

---

## Context Control (Keyboard Shortcuts)

### Escape (Stop)

Press `Escape` once to stop Claude mid-response.

**Use when:**
- Claude is going wrong direction
- Need to redirect conversation
- Want to add clarification

**Tip:** Escape + Memory command is powerful:
```
[Escape] → # "Don't modify test files without asking"
```

### Double Escape (Rewind)

Press `Escape` twice to show conversation history.

**Use when:**
- Need to jump back to earlier point
- Want to skip failed debugging attempts
- Need to redo from specific message

**Flow:**
```
[Escape][Escape] → Select earlier message → Continue from there
```

### /compact (Summarize)

Summarize conversation while preserving Claude's learned knowledge.

**Use when:**
- Long conversation accumulated clutter
- Claude has gained expertise but context is noisy
- Want to continue with cleaner context

```
/compact
```

### /clear (Fresh Start)

Delete entire conversation history.

**Use when:**
- Switching to completely unrelated task
- Context is polluted beyond recovery
- Starting fresh session

```
/clear
```

---

## Context Control Strategy

### Decision Tree

```
Is Claude stuck or going wrong?
├── Yes → Press Escape
│   └── Was Claude making repeated mistakes?
│       ├── Yes → Add memory: # "rule to prevent this"
│       └── No → Redirect with new prompt
└── No → Continue

Is conversation getting too long?
├── Yes → /compact (preserve knowledge)
└── No → Continue

Switching to unrelated task?
├── Yes → /clear
└── No → Continue current context
```

---

## Framework Integration

### CLAUDE.md Addition

Add to your project's CLAUDE.md:

```markdown
## Reasoning Modes

For complex tasks, use thinking phrases:
- Standard tasks: No special phrase needed
- Complex implementation: "Think more"
- Architecture decisions: "Think a lot"
- Critical/security: "Ultrathink"

See: core/REASONING_MODES.md for full reference.
```

### Recommended Workflow

1. **Start session:** `/start-session`
2. **Complex task:** Use appropriate thinking mode
3. **Mid-session cleanup:** `/compact` if needed
4. **End session:** `/end-session`

### Agent Integration

| Agent | Recommended Mode |
|-------|------------------|
| `planner` | "Think more" |
| `architect` | "Think a lot" |
| `debugger` | "Think longer" |
| `security-specialist` | "Ultrathink" |
| `implementer` | Default or "Think" |
| `reviewer` | "Think more" |

---

## Screenshot Integration

Paste screenshots with `Control+V` (not Command+V on macOS).

**Use when:**
- Showing specific UI element to modify
- Demonstrating bug visually
- Providing design reference

**Workflow:**
```
1. Take screenshot
2. Control+V to paste
3. "Ultrathink about fixing this layout issue"
4. Claude analyzes visual + uses reasoning
```

---

## Cost Considerations

| Mode | Approximate Token Cost |
|------|----------------------|
| Default | ~100-500 tokens/response |
| "Think" | ~500-1000 tokens |
| "Think more" | ~1500-2500 tokens |
| "Think a lot" | ~3000-4000 tokens |
| "Think longer" | ~5000-7000 tokens |
| "Ultrathink" | ~10000+ tokens |
| Plan Mode | +500-2000 tokens |

**Rule:** Use minimum reasoning level needed for the task.

---

## References

- `core/CONTEXT_HIERARCHY.md` — Token optimization levels
- `core/CLAUDE.md` — Main Claude rules
- `/hooks` command — Configure automated feedback
