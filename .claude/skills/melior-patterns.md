---
name: melior-patterns
description: "Melior Plus project-specific patterns: API response format, error codes, Vue to React migration status"
---

# Melior Plus Patterns

> Project-specific patterns for Melior Plus MVP development.

---

## Project Overview

**Melior Plus** - Internal project management tool for electrical engineering company.

### Tech Stack
- **Frontend:** Vue.js (primary), React (migration in progress)
- **Backend:** Node.js + Express + Supabase
- **Database:** Supabase (PostgreSQL)
- **Language:** TypeScript throughout
- **State:** Pinia (Vue) / Zustand (React)

---

## API Response Format

### Success Response
```typescript
{
  "success": true,
  "data": { /* response data */ },
  "meta": {
    "timestamp": "2025-01-01T10:30:00Z",
    "requestId": "req_abc123"
  }
}
```

### Error Response
```typescript
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": [
      { "field": "email", "message": "Required field" }
    ]
  },
  "meta": {
    "timestamp": "2025-01-01T10:30:00Z",
    "requestId": "req_abc123"
  }
}
```

---

## Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `VALIDATION_ERROR` | 400 | Invalid input data |
| `UNAUTHORIZED` | 401 | Authentication required |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `CONFLICT` | 409 | Resource conflict |
| `INTERNAL_ERROR` | 500 | Server error |

---

## Database Patterns

### Table Naming
```sql
-- Plural, snake_case
projects
project_tasks
task_comments
```

### Column Conventions
```sql
id UUID PRIMARY KEY DEFAULT gen_random_uuid()
created_at TIMESTAMPTZ DEFAULT NOW()
updated_at TIMESTAMPTZ DEFAULT NOW()
deleted_at TIMESTAMPTZ  -- Soft delete
```

### RLS Pattern
```sql
-- Every table has RLS
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- Standard policies
CREATE POLICY "Users view own" ON projects
  FOR SELECT USING (owner_id = auth.uid());

CREATE POLICY "Users manage own" ON projects
  FOR ALL USING (owner_id = auth.uid());
```

---

## File Structure

```
apps/
├── web-frontend/           # Vue 3 SPA
│   ├── src/
│   │   ├── components/     # Feature + Shared
│   │   ├── composables/    # Vue composables
│   │   ├── services/       # Business logic
│   │   ├── stores/         # Pinia stores
│   │   ├── views/          # Page components
│   │   └── types/          # TypeScript types
│   └── tests/
└── api-server/             # Express API
    └── src/
        ├── routes/         # API routes
        ├── middleware/     # Auth, validation
        └── services/       # Business logic
```

---

## Component Patterns

### Vue Component
```vue
<script setup lang="ts">
import { ref, computed } from 'vue'
import { useProjectStore } from '@/stores/project'

const props = defineProps<{
  projectId: string
}>()

const store = useProjectStore()
const loading = ref(false)

const project = computed(() =>
  store.projects.find(p => p.id === props.projectId)
)
</script>

<template>
  <div class="project-card">
    <h3>{{ project?.name }}</h3>
  </div>
</template>

<style scoped>
.project-card {
  padding: var(--spacing-md);
  border-radius: var(--radius-md);
}
</style>
```

---

## Service Pattern

```typescript
// services/projectService.ts
import { supabase } from '@/lib/supabase'
import type { Project, ProjectCreate } from '@/types'

export const projectService = {
  async getAll(): Promise<Project[]> {
    const { data, error } = await supabase
      .from('projects')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) throw error
    return data
  },

  async create(project: ProjectCreate): Promise<Project> {
    const { data, error } = await supabase
      .from('projects')
      .insert(project)
      .select()
      .single()

    if (error) throw error
    return data
  }
}
```

---

## Testing Pattern

```typescript
import { describe, it, expect, vi } from 'vitest'
import { projectService } from '@/services/projectService'

vi.mock('@/lib/supabase', () => ({
  supabase: {
    from: vi.fn(() => ({
      select: vi.fn().mockResolvedValue({ data: [], error: null })
    }))
  }
}))

describe('projectService', () => {
  it('getAll returns projects', async () => {
    const projects = await projectService.getAll()
    expect(projects).toEqual([])
  })
})
```
