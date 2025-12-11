---
name: typescript
description: "TypeScript patterns: utility types, generics, discriminated unions, type guards, strict mode best practices"
---

# TypeScript Patterns

> Advanced TypeScript patterns and best practices.

---

## Type Fundamentals

### Basic Types
```typescript
// Primitives
const name: string = "John"
const age: number = 30
const active: boolean = true

// Arrays
const numbers: number[] = [1, 2, 3]
const names: Array<string> = ["a", "b"]

// Tuples
const pair: [string, number] = ["age", 30]

// Objects
const user: { name: string; age: number } = { name: "John", age: 30 }
```

### Union & Intersection
```typescript
// Union - one of
type Status = "draft" | "active" | "archived"
type ID = string | number

// Intersection - all of
type Employee = Person & { employeeId: string }

// Discriminated Union
type Result<T> =
  | { success: true; data: T }
  | { success: false; error: string }
```

---

## Utility Types

```typescript
// Partial - all properties optional
type PartialUser = Partial<User>

// Required - all properties required
type RequiredUser = Required<User>

// Pick - select properties
type UserName = Pick<User, 'name' | 'email'>

// Omit - exclude properties
type UserWithoutId = Omit<User, 'id'>

// Record - object with typed keys
type StatusMap = Record<Status, number>

// ReturnType - function return type
type GetUserReturn = ReturnType<typeof getUser>

// Parameters - function parameter types
type GetUserParams = Parameters<typeof getUser>

// Awaited - unwrap Promise
type User = Awaited<ReturnType<typeof fetchUser>>
```

---

## Generics

### Basic Generic
```typescript
function identity<T>(value: T): T {
  return value
}

// With constraint
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key]
}

// Generic interface
interface Response<T> {
  data: T
  status: number
  error?: string
}

// Generic type
type AsyncResult<T> = Promise<Response<T>>
```

### Generic Components
```typescript
// React
interface ListProps<T> {
  items: T[]
  renderItem: (item: T) => React.ReactNode
}

function List<T>({ items, renderItem }: ListProps<T>) {
  return <ul>{items.map(renderItem)}</ul>
}

// Usage
<List items={users} renderItem={(user) => <li>{user.name}</li>} />
```

---

## Type Guards

```typescript
// typeof guard
function process(value: string | number) {
  if (typeof value === "string") {
    return value.toUpperCase()
  }
  return value * 2
}

// instanceof guard
function handleError(error: Error | string) {
  if (error instanceof Error) {
    return error.message
  }
  return error
}

// Custom type guard
function isUser(value: unknown): value is User {
  return (
    typeof value === "object" &&
    value !== null &&
    "id" in value &&
    "email" in value
  )
}

// Discriminated union guard
type Action =
  | { type: "add"; payload: string }
  | { type: "remove"; id: number }

function handleAction(action: Action) {
  switch (action.type) {
    case "add":
      return action.payload // string
    case "remove":
      return action.id // number
  }
}
```

---

## Strict Mode Patterns

### Non-null Assertion
```typescript
// Use sparingly!
const element = document.getElementById("app")!

// Better: type guard
const element = document.getElementById("app")
if (!element) throw new Error("Element not found")
```

### Optional Chaining
```typescript
const name = user?.profile?.name ?? "Unknown"
const result = callback?.()
```

### Satisfies Operator
```typescript
const config = {
  port: 3000,
  host: "localhost"
} satisfies Record<string, string | number>

// Type is inferred but validated
config.port // number (not string | number)
```

---

## Declaration Files

```typescript
// types/global.d.ts
declare global {
  interface Window {
    $toast: ToastAPI
  }
}

// types/env.d.ts
declare namespace NodeJS {
  interface ProcessEnv {
    NODE_ENV: 'development' | 'production'
    DATABASE_URL: string
  }
}

export {}
```

---

## Best Practices

### DO
```typescript
// Explicit return types for public functions
function getUser(id: string): Promise<User | null> {}

// Use `unknown` instead of `any`
function parse(json: string): unknown {}

// Const assertions for literals
const STATUSES = ["draft", "active"] as const
type Status = typeof STATUSES[number]
```

### DON'T
```typescript
// Avoid any
function bad(value: any) {} // ❌

// Avoid non-null assertion abuse
const x = maybeNull!.property // ❌

// Avoid type assertions when guards work
const user = value as User // ❌ (use type guard)
```
