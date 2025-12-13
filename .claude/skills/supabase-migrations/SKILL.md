---
name: supabase-migrations
description: "Supabase migration workflows: naming conventions, rollback patterns, production deployment, CLI commands"
---

# Supabase Migrations

> Migration patterns for Supabase database changes.

---

## Directory Structure

```
supabase/
├── migrations/           # Versioned schema changes
│   ├── 20240101000000_initial_schema.sql
│   ├── 20240102000000_add_projects.sql
│   └── 20240103000000_add_rls_policies.sql
├── seed.sql              # Development seed data
└── config.toml           # Supabase configuration
```

---

## Migration File Format

### Naming Convention
```
{timestamp}_{description}.sql

Examples:
20240101000000_initial_schema.sql
20240102000000_add_projects_table.sql
20240103000000_add_user_roles.sql
```

### File Template
```sql
-- Migration: 20240102000000_add_projects_table
-- Description: Create projects table with RLS

-- ============================================
-- UP Migration
-- ============================================

CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  owner_id UUID NOT NULL REFERENCES auth.users(id),
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users view own projects"
  ON projects FOR SELECT
  USING (auth.uid() = owner_id);

CREATE POLICY "Users create own projects"
  ON projects FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

-- Indexes
CREATE INDEX idx_projects_owner ON projects(owner_id);
CREATE INDEX idx_projects_status ON projects(status);

-- ============================================
-- DOWN Migration (for reference)
-- ============================================
-- DROP TABLE projects;
```

---

## CLI Commands

```bash
# Create new migration
npx supabase migration new add_projects_table

# Apply migrations to local
npx supabase db reset

# Push migrations to remote
npx supabase db push

# Pull remote schema changes
npx supabase db pull

# Check migration status
npx supabase migration list

# Generate types after migration
npx supabase gen types typescript --project-id PROJECT_ID > src/types/database.types.ts
```

---

## Migration Workflow

### Development
```bash
# 1. Create migration file
npx supabase migration new my_change

# 2. Write SQL in migrations/timestamp_my_change.sql

# 3. Test locally
npx supabase db reset

# 4. Verify with app
npm run dev
```

### Production
```bash
# 1. Review migration
cat supabase/migrations/timestamp_my_change.sql

# 2. Push to production
npx supabase db push --linked

# 3. Regenerate types
npx supabase gen types typescript --linked > src/types/database.types.ts

# 4. Verify
```

---

## Safe Migration Patterns

### Adding Column
```sql
-- Safe: Add nullable column
ALTER TABLE projects ADD COLUMN description TEXT;

-- Safe: Add column with default
ALTER TABLE projects ADD COLUMN status TEXT DEFAULT 'active';
```

### Renaming Column
```sql
-- Step 1: Add new column
ALTER TABLE projects ADD COLUMN project_name TEXT;

-- Step 2: Copy data
UPDATE projects SET project_name = name;

-- Step 3: Make NOT NULL if needed
ALTER TABLE projects ALTER COLUMN project_name SET NOT NULL;

-- Step 4: Drop old column (in separate migration after app updated)
ALTER TABLE projects DROP COLUMN name;
```

### Adding Index
```sql
-- Use CONCURRENTLY for production (no table lock)
CREATE INDEX CONCURRENTLY idx_projects_name ON projects(name);
```

---

## Rollback Strategy

```sql
-- Keep DOWN migration as comment
-- If rollback needed, run manually

-- DOWN:
-- DROP INDEX idx_projects_name;
-- ALTER TABLE projects DROP COLUMN description;
```

---

## Common Patterns

### Soft Delete
```sql
ALTER TABLE projects ADD COLUMN deleted_at TIMESTAMPTZ;

-- Update RLS to exclude deleted
DROP POLICY "Users view own projects" ON projects;
CREATE POLICY "Users view own active projects"
  ON projects FOR SELECT
  USING (auth.uid() = owner_id AND deleted_at IS NULL);
```

### Audit Columns
```sql
ALTER TABLE projects
  ADD COLUMN created_by UUID REFERENCES auth.users(id),
  ADD COLUMN updated_by UUID REFERENCES auth.users(id);

-- Trigger to auto-update
CREATE TRIGGER set_updated_by
  BEFORE UPDATE ON projects
  FOR EACH ROW
  EXECUTE FUNCTION set_current_user_id();
```
