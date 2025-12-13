# Context7 MCP Integration

## Overview

Context7 provides up-to-date documentation for libraries directly within Claude's context. Use it to get current API references, code examples, and best practices.

## When to Use

- Learning a new library
- Checking current API syntax
- Finding code examples
- Verifying best practices
- Troubleshooting library issues

## Available Tools

### resolve-library-id
Finds the Context7-compatible library ID for a package.

**Usage:**
```
First, resolve the library name to get a valid ID
```

**Example:**
- Input: "next.js"
- Output: `/vercel/next.js`

### get-library-docs
Fetches documentation for a resolved library.

**Parameters:**
| Parameter | Required | Description |
|-----------|----------|-------------|
| context7CompatibleLibraryID | Yes | Library ID from resolve-library-id |
| topic | No | Focus area (e.g., "routing", "hooks") |
| mode | No | "code" for APIs, "info" for concepts |
| page | No | Pagination (1-10) |

## Integration Patterns

### Pattern 1: Learn New Library
```yaml
workflow:
  1. resolve-library-id: "library-name"
  2. get-library-docs:
       id: <resolved_id>
       mode: info
       topic: "getting started"
  3. get-library-docs:
       id: <resolved_id>
       mode: code
       topic: <specific feature>
```

### Pattern 2: Implementation Reference
```yaml
workflow:
  1. resolve-library-id: "library-name"
  2. get-library-docs:
       id: <resolved_id>
       mode: code
       topic: <feature to implement>
```

### Pattern 3: Troubleshooting
```yaml
workflow:
  1. resolve-library-id: "library-name"
  2. get-library-docs:
       id: <resolved_id>
       topic: <error-related topic>
       mode: code
```

## Auto-Trigger Keywords

Context7 should be used when encountering:
- "How do I use [library]?"
- "What's the syntax for [feature]?"
- "[library] documentation"
- "Current [library] best practices"
- Implementation questions about supported libraries

## Supported Libraries

Common libraries with good Context7 support:
- Next.js
- React
- TailwindCSS
- Prisma
- tRPC
- Zod
- React Query / TanStack Query
- And many more...

## Best Practices

1. **Always Resolve First**: Get the library ID before fetching docs
2. **Be Specific**: Use topic parameter for targeted results
3. **Right Mode**: Use "code" for implementation, "info" for understanding
4. **Paginate**: Use page parameter if initial results insufficient
5. **Cache Mentally**: Don't re-fetch same info repeatedly

## Error Handling

| Error | Solution |
|-------|----------|
| Library not found | Try alternative names (e.g., "nextjs" vs "next.js") |
| No results for topic | Broaden topic or check spelling |
| Outdated info | Check page parameter, try different topic |

---

*Part of DG-SuperVibe-Framework v2.4*
