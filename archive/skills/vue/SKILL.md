---
name: vue
description: "Vue 3 Composition API patterns: script setup, composables, TypeScript props/emits, Pinia state"
---

# Vue 3 Patterns

> Vue 3 Composition API with TypeScript.

---

## Component Structure

```vue
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'
import type { Project } from '@/types'

// Props
interface Props {
  projectId: string
  editable?: boolean
}
const props = defineProps<Props>()

// Emits
const emit = defineEmits<{
  save: [data: Project]
  cancel: []
}>()

// State
const loading = ref(false)
const data = ref<Project | null>(null)

// Computed
const isValid = computed(() => !!data.value?.name)

// Methods
const save = async () => {
  if (!isValid.value) return
  loading.value = true
  try {
    emit('save', data.value!)
  } finally {
    loading.value = false
  }
}

// Lifecycle
onMounted(() => {
  // Initialize
})
</script>

<template>
  <div class="component-name">
    <slot name="header" />
    <button @click="save" :disabled="loading">
      Save
    </button>
  </div>
</template>

<style scoped>
.component-name {
  padding: 16px;
}
</style>
```

---

## Composables

### Basic Composable
```typescript
// composables/useProjects.ts
import { ref, computed } from 'vue'
import { supabase } from '@/lib/supabase'
import type { Project } from '@/types'

export function useProjects() {
  const projects = ref<Project[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  const activeProjects = computed(() =>
    projects.value.filter(p => p.status === 'active')
  )

  async function fetchProjects() {
    loading.value = true
    error.value = null
    try {
      const { data, error: err } = await supabase
        .from('projects')
        .select('*')
      if (err) throw err
      projects.value = data
    } catch (e) {
      error.value = (e as Error).message
    } finally {
      loading.value = false
    }
  }

  return {
    projects,
    activeProjects,
    loading,
    error,
    fetchProjects
  }
}
```

---

## Props & Emits

### Props with Defaults
```typescript
interface Props {
  title: string
  count?: number
  items?: string[]
}

const props = withDefaults(defineProps<Props>(), {
  count: 0,
  items: () => []
})
```

### Typed Emits
```typescript
const emit = defineEmits<{
  'update:modelValue': [value: string]
  'submit': [data: FormData]
  'delete': [id: string]
}>()

// Usage
emit('update:modelValue', newValue)
emit('submit', formData)
```

---

## Pinia Store

```typescript
// stores/user.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User } from '@/types'

export const useUserStore = defineStore('user', () => {
  // State
  const user = ref<User | null>(null)
  const loading = ref(false)

  // Getters
  const isAuthenticated = computed(() => !!user.value)
  const displayName = computed(() =>
    user.value?.name ?? 'Guest'
  )

  // Actions
  async function login(email: string, password: string) {
    loading.value = true
    // ... login logic
    loading.value = false
  }

  function logout() {
    user.value = null
  }

  return {
    user,
    loading,
    isAuthenticated,
    displayName,
    login,
    logout
  }
})
```

---

## Template Patterns

### Conditional Rendering
```vue
<template>
  <!-- v-if for expensive/rare -->
  <Modal v-if="showModal" @close="showModal = false" />

  <!-- v-show for frequent toggle -->
  <Sidebar v-show="sidebarOpen" />

  <!-- List rendering -->
  <ul>
    <li v-for="item in items" :key="item.id">
      {{ item.name }}
    </li>
  </ul>
</template>
```

### Event Handling
```vue
<template>
  <button @click="onClick">Click</button>
  <input @keyup.enter="onSubmit" />
  <form @submit.prevent="onSubmit">
</template>
```
