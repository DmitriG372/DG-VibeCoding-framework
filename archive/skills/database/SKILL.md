---
name: database
description: "Supabase PostgreSQL patterns: RLS policies, direct queries, triggers, functions, type generation"
context: fork
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - mcp__plugin_supabase_supabase__*
---

# Database Patterns

> Supabase PostgreSQL with Row Level Security.

---

## Supabase Client Setup

```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js'
import type { Database } from '@/types/database.types'

export const supabase = createClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)
```

---

## Basic CRUD

### Select
```typescript
// All rows
const { data, error } = await supabase
  .from('projects')
  .select('*')

// With filter
const { data } = await supabase
  .from('projects')
  .select('*')
  .eq('status', 'active')
  .order('created_at', { ascending: false })
  .limit(10)

// Single row
const { data } = await supabase
  .from('projects')
  .select('*')
  .eq('id', projectId)
  .single()

// With relations
const { data } = await supabase
  .from('projects')
  .select(`
    *,
    tasks (id, title, status),
    owner:profiles!owner_id (id, name, email)
  `)
```

### Insert
```typescript
// Single
const { data, error } = await supabase
  .from('projects')
  .insert({ name: 'New Project', owner_id: userId })
  .select()
  .single()

// Multiple
const { data } = await supabase
  .from('tasks')
  .insert([
    { title: 'Task 1', project_id },
    { title: 'Task 2', project_id }
  ])
  .select()
```

### Update
```typescript
const { data, error } = await supabase
  .from('projects')
  .update({ name: 'Updated Name', status: 'active' })
  .eq('id', projectId)
  .select()
  .single()
```

### Delete
```typescript
const { error } = await supabase
  .from('projects')
  .delete()
  .eq('id', projectId)
```

---

## Row Level Security (RLS)

### Enable RLS
```sql
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
```

### Common Policies

```sql
-- Users can only see their own projects
CREATE POLICY "Users view own projects"
  ON projects FOR SELECT
  USING (auth.uid() = owner_id);

-- Users can only insert their own projects
CREATE POLICY "Users insert own projects"
  ON projects FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

-- Users can only update their own projects
CREATE POLICY "Users update own projects"
  ON projects FOR UPDATE
  USING (auth.uid() = owner_id);

-- Users can only delete their own projects
CREATE POLICY "Users delete own projects"
  ON projects FOR DELETE
  USING (auth.uid() = owner_id);
```

### Team Access
```sql
-- Team members can view shared projects
CREATE POLICY "Team members view projects"
  ON projects FOR SELECT
  USING (
    auth.uid() = owner_id
    OR
    EXISTS (
      SELECT 1 FROM project_members
      WHERE project_id = projects.id
      AND user_id = auth.uid()
    )
  );
```

---

## Database Functions

```sql
-- Custom function for ID generation
CREATE OR REPLACE FUNCTION generate_project_code()
RETURNS TEXT AS $$
DECLARE
  new_code TEXT;
  counter INT;
BEGIN
  SELECT COALESCE(MAX(CAST(SUBSTRING(code FROM 4) AS INT)), 0) + 1
  INTO counter
  FROM projects
  WHERE code LIKE 'PRJ%';

  new_code := 'PRJ' || LPAD(counter::TEXT, 4, '0');
  RETURN new_code;
END;
$$ LANGUAGE plpgsql;

-- Call from Supabase
const { data } = await supabase.rpc('generate_project_code')
```

---

## Triggers

```sql
-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_projects_modified
  BEFORE UPDATE ON projects
  FOR EACH ROW
  EXECUTE FUNCTION update_modified_column();
```

---

## Type Generation

```bash
# Generate TypeScript types from schema
npx supabase gen types typescript \
  --project-id YOUR_PROJECT_ID \
  > src/types/database.types.ts
```

```typescript
// Usage
import type { Database } from '@/types/database.types'

type Project = Database['public']['Tables']['projects']['Row']
type ProjectInsert = Database['public']['Tables']['projects']['Insert']
type ProjectUpdate = Database['public']['Tables']['projects']['Update']
```

---

## Real-time Subscriptions

```typescript
// Subscribe to changes
const channel = supabase
  .channel('projects')
  .on(
    'postgres_changes',
    { event: '*', schema: 'public', table: 'projects' },
    (payload) => {
      console.log('Change:', payload)
    }
  )
  .subscribe()

// Cleanup
channel.unsubscribe()
```
