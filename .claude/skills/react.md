---
name: react
description: "React 18+ patterns: hooks, TypeScript components, state management with Zustand, TanStack Query"
---

# React 18+ Patterns

> Modern React with TypeScript and hooks.

---

## Component Structure

```tsx
import { useState, useMemo, useCallback } from 'react'
import type { Project } from '@/types'

interface Props {
  projectId: string
  editable?: boolean
  onSave?: (data: Project) => void
  onCancel?: () => void
}

export function ProjectCard({
  projectId,
  editable = false,
  onSave,
  onCancel
}: Props) {
  const [loading, setLoading] = useState(false)
  const [data, setData] = useState<Project | null>(null)

  const isValid = useMemo(() => !!data?.name, [data])

  const handleSave = useCallback(async () => {
    if (!isValid || !data) return
    setLoading(true)
    try {
      onSave?.(data)
    } finally {
      setLoading(false)
    }
  }, [isValid, data, onSave])

  return (
    <div className="card">
      <button onClick={handleSave} disabled={loading}>
        Save
      </button>
    </div>
  )
}
```

---

## Hooks

### useState
```tsx
const [count, setCount] = useState(0)
const [user, setUser] = useState<User | null>(null)

// Functional update
setCount(prev => prev + 1)

// Object update
setUser(prev => prev ? { ...prev, name: 'New' } : null)
```

### useEffect
```tsx
// Mount only
useEffect(() => {
  fetchData()
}, [])

// Dependency change
useEffect(() => {
  fetchUser(userId)
}, [userId])

// Cleanup
useEffect(() => {
  const sub = subscribe()
  return () => sub.unsubscribe()
}, [])
```

### useMemo & useCallback
```tsx
// Expensive computation
const sorted = useMemo(() =>
  items.sort((a, b) => a.name.localeCompare(b.name)),
  [items]
)

// Stable function reference
const handleClick = useCallback((id: string) => {
  setSelected(id)
}, [])
```

---

## Custom Hooks

```tsx
// hooks/useProjects.ts
import { useState, useEffect, useCallback } from 'react'
import { supabase } from '@/lib/supabase'
import type { Project } from '@/types'

export function useProjects() {
  const [projects, setProjects] = useState<Project[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const fetchProjects = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const { data, error: err } = await supabase
        .from('projects')
        .select('*')
      if (err) throw err
      setProjects(data ?? [])
    } catch (e) {
      setError((e as Error).message)
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchProjects()
  }, [fetchProjects])

  return { projects, loading, error, refetch: fetchProjects }
}
```

---

## Zustand Store

```tsx
// stores/user.ts
import { create } from 'zustand'
import type { User } from '@/types'

interface UserState {
  user: User | null
  loading: boolean
  login: (email: string, password: string) => Promise<void>
  logout: () => void
}

export const useUserStore = create<UserState>((set) => ({
  user: null,
  loading: false,

  login: async (email, password) => {
    set({ loading: true })
    // ... login logic
    set({ user: userData, loading: false })
  },

  logout: () => {
    set({ user: null })
  },
}))

// Usage
const { user, login, logout } = useUserStore()
const isAuth = useUserStore((state) => !!state.user)
```

---

## TanStack Query

```tsx
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'

// Query
const { data, isLoading, error } = useQuery({
  queryKey: ['projects', userId],
  queryFn: () => fetchProjects(userId),
})

// Mutation
const queryClient = useQueryClient()

const mutation = useMutation({
  mutationFn: createProject,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['projects'] })
  },
})

// Usage
mutation.mutate({ name: 'New Project' })
```

---

## Patterns

### Conditional Rendering
```tsx
return (
  <>
    {isLoading && <Spinner />}
    {error && <Error message={error} />}
    {data && <ProjectList projects={data} />}
  </>
)
```

### List Rendering
```tsx
return (
  <ul>
    {items.map((item) => (
      <li key={item.id}>{item.name}</li>
    ))}
  </ul>
)
```

### Event Handling
```tsx
<button onClick={() => handleClick(id)}>Click</button>
<input onChange={(e) => setValue(e.target.value)} />
<form onSubmit={(e) => { e.preventDefault(); handleSubmit() }}>
```
