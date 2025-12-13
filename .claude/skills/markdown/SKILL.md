---
name: markdown
description: "Markdown patterns: README structure, documentation formatting, tables, code blocks, task lists"
---

# Markdown Patterns

> Documentation and README formatting.

---

## Basic Syntax

### Headers
```markdown
# H1 - Document Title
## H2 - Main Section
### H3 - Subsection
#### H4 - Sub-subsection
```

### Text Formatting
```markdown
**bold** or __bold__
*italic* or _italic_
***bold italic***
~~strikethrough~~
`inline code`
```

### Links & Images
```markdown
[Link text](https://example.com)
[Link with title](https://example.com "Title")

![Alt text](image.png)
![Alt text](image.png "Title")
```

### Lists
```markdown
- Unordered item
- Another item
  - Nested item

1. Ordered item
2. Another item
   1. Nested ordered

- [ ] Task item
- [x] Completed task
```

---

## Code Blocks

### Syntax Highlighting
````markdown
```typescript
function greet(name: string): string {
  return `Hello, ${name}!`
}
```

```bash
npm install package-name
```

```sql
SELECT * FROM users WHERE active = true;
```
````

### Inline Code
```markdown
Use `const` instead of `let` for constants.
```

---

## Tables

```markdown
| Header 1 | Header 2 | Header 3 |
|----------|----------|----------|
| Cell 1   | Cell 2   | Cell 3   |
| Cell 4   | Cell 5   | Cell 6   |

| Left | Center | Right |
|:-----|:------:|------:|
| L    |   C    |     R |
```

---

## README Structure

```markdown
# Project Name

> Short description of the project.

## Features

- Feature 1
- Feature 2
- Feature 3

## Getting Started

### Prerequisites

- Node.js 18+
- pnpm 8+

### Installation

```bash
git clone https://github.com/user/repo.git
cd repo
pnpm install
```

### Development

```bash
pnpm dev
```

## Usage

```typescript
import { something } from 'package'

something.do()
```

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `3000` |
| `DEBUG` | Enable debug | `false` |

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feat/amazing`)
3. Commit changes (`git commit -m 'feat: add amazing'`)
4. Push to branch (`git push origin feat/amazing`)
5. Open Pull Request

## License

MIT
```

---

## PROJECT.md Structure

```markdown
# Project Name

> Single source of truth for AI context.

## 🎯 Active Tasks

- [ ] Task 1 - Description
  - Acceptance: What defines done
  - Constraint: Technical limitations
- [ ] Task 2 - Description

## ✅ Completed

- [x] Completed task 1
- [x] Completed task 2

## 📋 Backlog

- Feature idea 1
- Feature idea 2

## 📌 Context

**Stack:** Next.js 14, TypeScript, Supabase
**Patterns:** Server Components, RLS
**Constraints:** Performance, Security

## 🔗 References

- [Architecture](docs/ARCHITECTURE.md)
- [API Docs](docs/API.md)
```

---

## Advanced Formatting

### Blockquotes
```markdown
> This is a blockquote
>
> With multiple paragraphs

> **Note:** Important information here.
```

### Horizontal Rule
```markdown
---
```

### Collapsible Section
```markdown
<details>
<summary>Click to expand</summary>

Hidden content here.

</details>
```

### Badges
```markdown
![Build Status](https://img.shields.io/github/actions/workflow/status/user/repo/ci.yml)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
```

---

## Best Practices

### DO
- Use consistent heading hierarchy
- Keep lines under 100 characters
- Use code blocks for all code
- Add alt text to images
- Use tables for structured data

### DON'T
- Skip heading levels (H1 → H3)
- Use HTML when Markdown works
- Leave trailing whitespace
- Use hard-coded URLs for internal links
