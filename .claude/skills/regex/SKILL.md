---
name: regex
description: "Regular expression patterns: validation, search, text processing, common recipes for email/URL/phone"
---

# Regex Patterns

> Regular expressions for validation and text processing.

---

## Syntax Reference

### Basic Patterns
| Pattern | Matches |
|---------|---------|
| `.` | Any character (except newline) |
| `\d` | Digit [0-9] |
| `\D` | Non-digit |
| `\w` | Word character [a-zA-Z0-9_] |
| `\W` | Non-word character |
| `\s` | Whitespace (space, tab, newline) |
| `\S` | Non-whitespace |
| `\b` | Word boundary |

### Quantifiers
| Pattern | Matches |
|---------|---------|
| `*` | 0 or more |
| `+` | 1 or more |
| `?` | 0 or 1 |
| `{n}` | Exactly n |
| `{n,}` | n or more |
| `{n,m}` | Between n and m |
| `*?` | 0 or more (lazy) |
| `+?` | 1 or more (lazy) |

### Anchors
| Pattern | Matches |
|---------|---------|
| `^` | Start of string/line |
| `$` | End of string/line |

### Groups & Lookaround
| Pattern | Description |
|---------|-------------|
| `(...)` | Capturing group |
| `(?:...)` | Non-capturing group |
| `(?<name>...)` | Named group |
| `(?=...)` | Positive lookahead |
| `(?!...)` | Negative lookahead |
| `(?<=...)` | Positive lookbehind |
| `(?<!...)` | Negative lookbehind |

---

## Common Patterns

### Email
```typescript
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

// More strict
const strictEmailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/

emailRegex.test('user@example.com') // true
```

### URL
```typescript
const urlRegex = /^https?:\/\/[^\s/$.?#].[^\s]*$/

// With named groups
const urlParts = /^(?<protocol>https?):\/\/(?<domain>[^/]+)(?<path>\/.*)?$/

const match = 'https://example.com/path'.match(urlParts)
// match.groups = { protocol: 'https', domain: 'example.com', path: '/path' }
```

### Phone Number
```typescript
// US format
const usPhoneRegex = /^\(?(\d{3})\)?[-.\s]?(\d{3})[-.\s]?(\d{4})$/

// International
const intlPhoneRegex = /^\+?[1-9]\d{1,14}$/

usPhoneRegex.test('(123) 456-7890') // true
```

### Password Strength
```typescript
// At least 8 chars, 1 upper, 1 lower, 1 digit
const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/

// With special character
const strongPassword = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$/
```

### UUID
```typescript
const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
```

### Date (YYYY-MM-DD)
```typescript
const dateRegex = /^\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12]\d|3[01])$/
```

---

## JavaScript Methods

### Test (Boolean)
```typescript
const regex = /hello/i
regex.test('Hello World') // true
```

### Match (Array)
```typescript
const text = 'The year 2024'
text.match(/\d+/) // ['2024']
text.match(/\d+/g) // ['2024'] (all matches)
```

### Replace
```typescript
// Simple replace
'hello world'.replace(/world/, 'there') // 'hello there'

// Global replace
'a-b-c'.replace(/-/g, '_') // 'a_b_c'

// With callback
'hello'.replace(/./g, (char) => char.toUpperCase()) // 'HELLO'

// With groups
'John Smith'.replace(/(\w+) (\w+)/, '$2, $1') // 'Smith, John'
```

### Split
```typescript
'a,b;c'.split(/[,;]/) // ['a', 'b', 'c']
```

### matchAll (Iterator)
```typescript
const text = 'test1 test2 test3'
const matches = [...text.matchAll(/test(\d)/g)]
// [['test1', '1'], ['test2', '2'], ['test3', '3']]
```

---

## TypeScript Patterns

### Validation Helper
```typescript
const patterns = {
  email: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  phone: /^\+?[1-9]\d{1,14}$/,
  uuid: /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i,
} as const

function validate(value: string, pattern: keyof typeof patterns): boolean {
  return patterns[pattern].test(value)
}

validate('user@example.com', 'email') // true
```

### Extract Matches
```typescript
function extractEmails(text: string): string[] {
  const regex = /[^\s@]+@[^\s@]+\.[^\s@]+/g
  return text.match(regex) || []
}
```

---

## Tips

### Escaping Special Characters
```typescript
// These need escaping: . * + ? ^ $ { } [ ] \ | ( )
const literal = /\.\*\+\?/  // matches .*+?

// Or use constructor with escaping
const escaped = new RegExp(userInput.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'))
```

### Performance
```typescript
// Compile once, use many
const regex = /pattern/  // Outside function

// Avoid catastrophic backtracking
// Bad: /^(a+)+$/
// Good: /^a+$/
```
