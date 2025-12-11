---
name: api
description: "API patterns: service layer, controllers, error handling, REST conventions, Express/Next.js routes"
---

# API Patterns

> Service layer architecture and REST API conventions.

---

## Service Layer Pattern

### Structure
```
src/
├── services/           # Business logic
│   ├── userService.ts
│   ├── projectService.ts
│   └── taskService.ts
├── controllers/        # HTTP handling only
│   ├── userController.ts
│   └── projectController.ts
├── routes/             # Route definitions
│   ├── users.ts
│   └── projects.ts
└── middleware/         # Cross-cutting concerns
    ├── auth.ts
    └── validate.ts
```

### Service Pattern
```typescript
// services/projectService.ts
import { supabase } from '@/lib/supabase'
import type { Project, ProjectCreate } from '@/types'

export const projectService = {
  async getAll(userId: string): Promise<Project[]> {
    const { data, error } = await supabase
      .from('projects')
      .select('*')
      .eq('owner_id', userId)
      .order('created_at', { ascending: false })

    if (error) throw error
    return data
  },

  async getById(id: string): Promise<Project | null> {
    const { data, error } = await supabase
      .from('projects')
      .select('*')
      .eq('id', id)
      .single()

    if (error && error.code !== 'PGRST116') throw error
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
  },

  async update(id: string, updates: Partial<Project>): Promise<Project> {
    const { data, error } = await supabase
      .from('projects')
      .update(updates)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  },

  async delete(id: string): Promise<void> {
    const { error } = await supabase
      .from('projects')
      .delete()
      .eq('id', id)

    if (error) throw error
  }
}
```

---

## Controller Pattern

```typescript
// controllers/projectController.ts
import { Request, Response } from 'express'
import { projectService } from '@/services/projectService'

export const projectController = {
  async getAll(req: Request, res: Response) {
    try {
      const projects = await projectService.getAll(req.user!.id)
      res.json({ success: true, data: projects })
    } catch (error) {
      res.status(500).json({
        success: false,
        error: { message: 'Failed to fetch projects' }
      })
    }
  },

  async create(req: Request, res: Response) {
    try {
      const project = await projectService.create({
        ...req.body,
        owner_id: req.user!.id
      })
      res.status(201).json({ success: true, data: project })
    } catch (error) {
      res.status(400).json({
        success: false,
        error: { message: 'Failed to create project' }
      })
    }
  }
}
```

---

## Response Format

### Success
```typescript
{
  success: true,
  data: { /* response data */ },
  meta: {
    timestamp: "2025-01-01T10:00:00Z",
    requestId: "req_abc123"
  }
}
```

### Error
```typescript
{
  success: false,
  error: {
    code: "VALIDATION_ERROR",
    message: "Email is required",
    details: [
      { field: "email", message: "Required field" }
    ]
  }
}
```

---

## Error Handling

```typescript
// Custom error class
class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string
  ) {
    super(message)
  }
}

// Error handler middleware
function errorHandler(err: Error, req: Request, res: Response, next: NextFunction) {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      success: false,
      error: {
        code: err.code,
        message: err.message
      }
    })
  }

  console.error(err)
  res.status(500).json({
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred'
    }
  })
}
```

---

## REST Conventions

| Method | Path | Action |
|--------|------|--------|
| GET | /projects | List all |
| GET | /projects/:id | Get one |
| POST | /projects | Create |
| PUT | /projects/:id | Full update |
| PATCH | /projects/:id | Partial update |
| DELETE | /projects/:id | Delete |

### Nested Resources
```
GET    /projects/:projectId/tasks
POST   /projects/:projectId/tasks
GET    /projects/:projectId/tasks/:taskId
```

### Query Parameters
```
GET /projects?status=active&sort=created_at&order=desc&limit=10&offset=0
```
