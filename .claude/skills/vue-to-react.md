---
name: vue-to-react
description: "Vue 3 to React 18 migration patterns: refs to useState, computed to useMemo, watchers to useEffect"
---

# Vue to React Migration

> Patterns for migrating Vue 3 (Composition API) to React 18+ with TypeScript.

---

## Component Structure Mapping

### Vue SFC to React FC

```vue
<!-- Vue 3 -->
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

const props = defineProps<{ title: string }>()
const emit = defineEmits<{ update: [value: string] }>()

const count = ref(0)
const doubled = computed(() => count.value * 2)

onMounted(() => console.log('mounted'))
</script>

<template>
  <div>{{ title }}: {{ doubled }}</div>
</template>
```

```tsx
// React 18
import { useState, useMemo, useEffect } from 'react'

interface Props {
  title: string
  onUpdate?: (value: string) => void
}

export function MyComponent({ title, onUpdate }: Props) {
  const [count, setCount] = useState(0)
  const doubled = useMemo(() => count * 2, [count])

  useEffect(() => {
    console.log('mounted')
  }, [])

  return <div>{title}: {doubled}</div>
}
```

---

## State Mapping

| Vue 3 | React 18 |
|-------|----------|
| `ref(0)` | `useState(0)` |
| `reactive({})` | `useState({})` |
| `computed(() => )` | `useMemo(() => , [deps])` |
| `watch(source, cb)` | `useEffect(() => cb(), [source])` |
| `watchEffect(() => )` | `useEffect(() => , [deps])` |

---

## Lifecycle Mapping

| Vue 3 | React 18 |
|-------|----------|
| `onMounted` | `useEffect(() => {}, [])` |
| `onUnmounted` | `useEffect(() => () => cleanup, [])` |
| `onUpdated` | `useEffect(() => {})` (no deps) |
| `onBeforeMount` | N/A (use early in component) |

---

## Props & Events

### Vue Props to React Props
```vue
<!-- Vue -->
<script setup>
const props = defineProps<{
  title: string
  count?: number
}>()
</script>
```

```tsx
// React
interface Props {
  title: string
  count?: number
}

function Component({ title, count = 0 }: Props) {}
```

### Vue Emit to React Callbacks
```vue
<!-- Vue -->
<script setup>
const emit = defineEmits<{
  'update': [value: string]
  'delete': []
}>()

emit('update', 'new value')
</script>
```

```tsx
// React
interface Props {
  onUpdate?: (value: string) => void
  onDelete?: () => void
}

function Component({ onUpdate, onDelete }: Props) {
  onUpdate?.('new value')
}
```

---

## v-model to Controlled Input

```vue
<!-- Vue -->
<template>
  <input v-model="text" />
</template>

<script setup>
const text = ref('')
</script>
```

```tsx
// React
function Component() {
  const [text, setText] = useState('')

  return (
    <input
      value={text}
      onChange={(e) => setText(e.target.value)}
    />
  )
}
```

---

## Pinia to Zustand

### Vue Pinia
```typescript
export const useUserStore = defineStore('user', () => {
  const user = ref<User | null>(null)
  const isAuth = computed(() => !!user.value)

  function login(data: User) {
    user.value = data
  }

  return { user, isAuth, login }
})
```

### React Zustand
```typescript
export const useUserStore = create<UserState>((set) => ({
  user: null,
  isAuth: false,

  login: (data) => set({ user: data, isAuth: true }),
}))

// Or with computed
const isAuth = useUserStore((state) => !!state.user)
```

---

## Template Directives

| Vue | React |
|-----|-------|
| `v-if` | `{condition && <Component />}` |
| `v-show` | `style={{ display: show ? 'block' : 'none' }}` |
| `v-for` | `{items.map(item => <Item key={item.id} />)}` |
| `v-bind:class` | `className={cn('base', condition && 'active')}` |
| `@click` | `onClick={() => }` |
| `@click.prevent` | `onClick={(e) => { e.preventDefault(); }}` |
