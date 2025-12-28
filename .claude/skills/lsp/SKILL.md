---
name: lsp
description: "Code intelligence with LSP: go to definition, find references, call hierarchy analysis"
---

# LSP Code Intelligence

> Semantic code understanding using Language Server Protocol.

---

## When to Use

- Finding where a function/class is defined
- Finding all usages before refactoring
- Understanding call hierarchy (who calls what)
- Analyzing impact of changes
- Getting type information and documentation

---

## Quick Reference

| Need | Operation | Example |
|------|-----------|---------|
| Where is X defined? | `goToDefinition` | `LSP goToDefinition file.ts:15:10` |
| Who uses X? | `findReferences` | `LSP findReferences file.ts:15:10` |
| What type is X? | `hover` | `LSP hover file.ts:15:10` |
| What's in this file? | `documentSymbol` | `LSP documentSymbol file.ts:1:1` |
| Who calls this? | `incomingCalls` | `LSP incomingCalls file.ts:15:10` |
| What does this call? | `outgoingCalls` | `LSP outgoingCalls file.ts:15:10` |

---

## Implementation Patterns

### Safe Refactoring

```
1. Find all references BEFORE change:
   LSP findReferences → document count

2. Check impact with call hierarchy:
   LSP incomingCalls → who depends on this?

3. Make change

4. Verify with findReferences again:
   → Same count? All updated?
```

### Unknown Codebase Exploration

```
1. Find entry point:
   LSP workspaceSymbol "main" or "App"

2. Trace outgoing calls:
   LSP outgoingCalls → what does it use?

3. For each dependency:
   LSP hover → get type/docs
   LSP goToDefinition → see implementation
```

### Impact Analysis

```
Question: "What breaks if I change function X?"

1. LSP incomingCalls on X
   → Direct callers

2. For each caller, LSP incomingCalls again
   → Indirect callers

3. Document affected modules
```

---

## LSP vs Text Search

| Scenario | Use LSP | Use Grep |
|----------|---------|----------|
| Find function definition | Yes | No |
| Find string in comments | No | Yes |
| Find all actual usages | Yes | No |
| Find text pattern | No | Yes |
| Refactoring prep | Yes | No |
| Log message search | No | Yes |

**Rule:** Semantic understanding → LSP. Text pattern → Grep.

---

## Common Pitfalls

1. **No LSP server configured**
   - Error: "No LSP server available"
   - Fix: Install language server (pylsp, tsserver, etc.)

2. **Wrong line/character position**
   - LSP uses 1-based positions
   - Put cursor ON the symbol, not before/after

3. **Project not indexed**
   - Large projects need time to index
   - Wait for language server to initialize

4. **Missing config files**
   - TypeScript needs tsconfig.json
   - Python needs pyproject.toml or setup.py

---

## Examples by Language

### TypeScript/JavaScript
```
# Find where React component is defined
LSP goToDefinition src/App.tsx:5:10

# Find all useState usages
LSP findReferences node_modules/@types/react/index.d.ts:850:1
```

### Python
```
# Find class definition
LSP goToDefinition src/services/user.py:15:5

# Get function signature
LSP hover src/api/routes.py:42:8
```

### Go
```
# Find interface implementations
LSP goToImplementation pkg/service/interface.go:12:6

# Find all callers
LSP incomingCalls cmd/server/main.go:25:2
```

---

*Part of DG-VibeCoding-Framework v2.5*
