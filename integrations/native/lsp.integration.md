# LSP (Language Server Protocol) Integration

## Overview

LSP is a protocol that enables Claude Code to understand code semantically, not just as text. It provides IDE-like intelligence: go to definition, find references, hover documentation, and call hierarchy analysis.

**Key difference from text search:**
- `Grep "myFunction"` → finds text matches (may include comments, strings)
- `LSP findReferences` → finds actual code references (semantically correct)

## How LSP Works

```
┌──────────────┐     JSON-RPC      ┌────────────────────┐
│  Claude Code │◄─────────────────►│  Language Server   │
│  (LSP Client)│                   │  (pylsp, tsserver) │
└──────────────┘                   └────────────────────┘
        │                                   │
        │  1. "Where is X defined?"         │
        │  ─────────────────────────────►   │
        │                                   │
        │  2. "File Y, line 42"             │
        │  ◄─────────────────────────────   │
        │                                   │
```

## Available Operations

### Navigation

| Operation | Description | Use Case |
|-----------|-------------|----------|
| `goToDefinition` | Find where symbol is defined | "Where is this function?" |
| `goToImplementation` | Find interface implementations | "Who implements this?" |
| `findReferences` | Find all usages of symbol | "Who uses this?" |

### Analysis

| Operation | Description | Use Case |
|-----------|-------------|----------|
| `hover` | Get documentation/type info | "What type is this?" |
| `documentSymbol` | List all symbols in file | "What's in this file?" |
| `workspaceSymbol` | Search symbols across project | "Find class X" |

### Call Hierarchy

| Operation | Description | Use Case |
|-----------|-------------|----------|
| `prepareCallHierarchy` | Get call hierarchy item | Setup for call analysis |
| `incomingCalls` | Who calls this function? | Impact analysis |
| `outgoingCalls` | What does this function call? | Dependency analysis |

## Usage in Claude Code

### Basic Syntax

```
LSP <operation> <file>:<line>:<character>
```

### Examples

#### Find Definition
```typescript
// In file: src/auth/login.ts, line 15
import { validateToken } from '../utils/jwt';
//       ↑ cursor here (line 15, character 10)

LSP goToDefinition src/auth/login.ts:15:10
→ Result: src/utils/jwt.ts:42
```

#### Find All References
```typescript
// Find everywhere validateToken is used
LSP findReferences src/utils/jwt.ts:42:17
→ Results:
  - src/auth/login.ts:15
  - src/auth/refresh.ts:28
  - src/middleware/auth.ts:55
  - tests/jwt.test.ts:12
```

#### Get Hover Info
```typescript
// Get type information for a variable
LSP hover src/api/users.ts:30:5
→ Result:
  const user: {
    id: string;
    email: string;
    createdAt: Date;
  }
```

#### List All Symbols in File
```typescript
LSP documentSymbol src/services/UserService.ts:1:1
→ Results:
  - class UserService (line 5)
    - method findById (line 12)
    - method create (line 25)
    - method update (line 45)
    - method delete (line 62)
```

#### Call Hierarchy Analysis
```typescript
// Who calls the authenticate() function?
LSP incomingCalls src/auth/auth.ts:20:10
→ Results:
  - loginHandler (src/routes/auth.ts:15)
  - refreshHandler (src/routes/auth.ts:42)
  - protectedMiddleware (src/middleware/auth.ts:8)

// What does authenticate() call?
LSP outgoingCalls src/auth/auth.ts:20:10
→ Results:
  - validateToken (src/utils/jwt.ts:42)
  - findUserById (src/services/user.ts:15)
  - logAccess (src/utils/audit.ts:28)
```

## Language Server Setup

LSP requires a language server to be installed and configured for each language.

### Popular Language Servers

| Language | Server | Installation |
|----------|--------|--------------|
| Python | `pylsp` | `pip install python-lsp-server` |
| Python | `pyright` | `npm i -g pyright` |
| TypeScript/JS | `typescript-language-server` | `npm i -g typescript-language-server typescript` |
| Rust | `rust-analyzer` | `rustup component add rust-analyzer` |
| Go | `gopls` | `go install golang.org/x/tools/gopls@latest` |
| C/C++ | `clangd` | System package manager |
| Java | `jdtls` | Eclipse JDT Language Server |
| PHP | `intelephense` | `npm i -g intelephense` |

### Checking LSP Availability

If LSP returns "No LSP server available for file type", the server isn't configured.

## When to Use LSP vs Other Tools

| Task | Best Tool | Why |
|------|-----------|-----|
| Find function definition | **LSP goToDefinition** | Semantic, handles imports |
| Find text pattern | Grep | Faster for simple patterns |
| Find all usages | **LSP findReferences** | Semantic, no false positives |
| Understand file structure | **LSP documentSymbol** | Structured output |
| Quick file search | Glob | Faster for file patterns |
| Impact analysis | **LSP incomingCalls** | Shows call chain |
| Refactoring prep | **LSP findReferences** | All actual usages |

## Integration with Framework Agents

### Refactorer Agent
```markdown
Before renaming a function:
1. LSP findReferences → find all usages
2. LSP incomingCalls → understand impact
3. Make changes
4. LSP findReferences → verify all updated
```

### Debugger Agent
```markdown
When investigating a bug:
1. LSP goToDefinition → trace to source
2. LSP outgoingCalls → see dependencies
3. LSP hover → check types
```

### Reviewer Agent
```markdown
During code review:
1. LSP documentSymbol → understand file structure
2. LSP findReferences → check if new code is used
3. LSP incomingCalls → verify integration points
```

## Common Patterns

### Pattern 1: Safe Refactoring

```
Goal: Rename function `getUserData` to `fetchUserProfile`

1. Find all references:
   LSP findReferences src/api/user.ts:25:17
   → 12 usages found

2. Check call hierarchy:
   LSP incomingCalls src/api/user.ts:25:17
   → Called from 3 modules

3. Update function name

4. Verify all references updated:
   LSP findReferences src/api/user.ts:25:17
   → 12 usages still point correctly
```

### Pattern 2: Understanding Unknown Codebase

```
Goal: Understand authentication flow

1. Find auth entry point:
   LSP workspaceSymbol "authenticate"
   → src/auth/auth.ts:20

2. See what it calls:
   LSP outgoingCalls src/auth/auth.ts:20:10
   → validateToken, findUser, createSession

3. For each, get documentation:
   LSP hover src/utils/jwt.ts:42:10
   → Type info and JSDoc

4. Build mental model of flow
```

### Pattern 3: Impact Analysis

```
Goal: Assess impact of changing validateToken()

1. Find all callers:
   LSP incomingCalls src/utils/jwt.ts:42:17
   → 8 functions call this

2. Find callers of those callers:
   LSP incomingCalls src/auth/auth.ts:20:10
   → 3 route handlers

3. Document affected areas before change
```

## Limitations

1. **Requires configured LSP server** - Won't work without proper setup
2. **Startup time** - Language servers may take time to initialize
3. **Memory usage** - Large projects may consume significant memory
4. **Not all features everywhere** - Some servers don't implement all operations

## Troubleshooting

### "No LSP server available"
- Check if language server is installed
- Verify Claude Code configuration
- Try restarting Claude Code

### Slow responses
- Large projects need time to index
- Consider limiting workspace scope
- Check if language server process is running

### Incorrect results
- Ensure project is properly configured (tsconfig.json, pyproject.toml, etc.)
- Check for syntax errors that prevent parsing
- Verify imports resolve correctly

---

*Part of DG-VibeCoding-Framework v2.6*
*Created: 2025-12-28*
