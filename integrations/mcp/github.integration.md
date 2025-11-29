# GitHub MCP Integration

## Overview

GitHub MCP provides direct access to repositories, issues, pull requests, and code search. Use it for repository management and code exploration.

## When to Use

- Searching code across repositories
- Managing issues and PRs
- Reading repository files
- Checking repository status
- Exploring open source code

## Available Operations

### Repository Operations
| Operation | Description |
|-----------|-------------|
| Get repo info | Repository metadata and stats |
| List files | Directory contents |
| Read file | File contents at path |
| Search code | Find code patterns |

### Issue Operations
| Operation | Description |
|-----------|-------------|
| List issues | Repository issues |
| Get issue | Issue details and comments |
| Create issue | New issue |
| Update issue | Modify existing |

### Pull Request Operations
| Operation | Description |
|-----------|-------------|
| List PRs | Repository pull requests |
| Get PR | PR details and diff |
| Create PR | New pull request |
| Review PR | Add review comments |

## Integration Patterns

### Pattern 1: Explore Repository
```yaml
workflow:
  1. Get repository info
  2. List root directory
  3. Read key files (README, package.json)
  4. Explore specific directories
```

### Pattern 2: Code Research
```yaml
workflow:
  1. Search code for pattern
  2. Read matching files
  3. Analyze implementation
  4. Document findings
```

### Pattern 3: Issue Management
```yaml
workflow:
  1. List open issues
  2. Get issue details
  3. Analyze requirements
  4. Create implementation plan
```

## Auto-Trigger Keywords

GitHub should be used when:
- "Check the [repo] repository"
- "How is [feature] implemented in [project]?"
- "Find examples of [pattern] in open source"
- "Create an issue for [topic]"
- "Review PR #[number]"

## Best Practices

1. **Rate Limiting**: Be mindful of API limits
2. **Specific Queries**: Use precise search terms
3. **Branch Awareness**: Specify branch when needed
4. **Context Building**: Read related files together
5. **Attribution**: Note sources when using found code

## Security Considerations

- Never expose tokens in code
- Respect repository licenses
- Don't commit sensitive data
- Use appropriate access levels

## Common Workflows

### Research Implementation
```
1. Search: "feature-name language:typescript"
2. Filter: Stars > 100 for quality
3. Read: Implementation files
4. Adapt: To project patterns
```

### Bug Investigation
```
1. Search: Error message in issues
2. Read: Related discussions
3. Check: Linked PRs
4. Apply: Relevant fixes
```

---

*Part of DG-SuperVibe-Framework v2.0*
