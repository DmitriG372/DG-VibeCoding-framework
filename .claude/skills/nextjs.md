---
name: nextjs
description: "Next.js 14+ App Router patterns: Server Components, route handlers, middleware, Supabase SSR"
---

# Next.js 14+ Patterns

> Next.js 14+ with App Router, Server Components, and TypeScript.

---

## Project Structure

```
src/
├── app/                      # App Router
│   ├── (auth)/               # Auth route group
│   │   ├── login/
│   │   └── register/
│   ├── (dashboard)/          # Protected routes
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── projects/
│   ├── api/                  # API routes
│   │   └── projects/
│   │       └── route.ts
│   ├── layout.tsx            # Root layout
│   ├── page.tsx              # Home page
│   └── globals.css
├── components/
│   ├── ui/                   # Shadcn components
│   └── features/             # Feature components
├── lib/
│   ├── supabase/
│   │   ├── client.ts         # Browser client
│   │   └── server.ts         # Server client
│   └── utils.ts
└── types/
```

---

## Server Components (Default)

```tsx
// app/projects/page.tsx
import { createServerClient } from '@/lib/supabase/server'

export default async function ProjectsPage() {
  const supabase = createServerClient()

  const { data: projects } = await supabase
    .from('projects')
    .select('*')
    .order('created_at', { ascending: false })

  return (
    <div>
      <h1>Projects</h1>
      <ul>
        {projects?.map(project => (
          <li key={project.id}>{project.name}</li>
        ))}
      </ul>
    </div>
  )
}
```

---

## Client Components

```tsx
'use client'

import { useState } from 'react'
import { createBrowserClient } from '@/lib/supabase/client'

export function CreateProjectButton() {
  const [loading, setLoading] = useState(false)
  const supabase = createBrowserClient()

  const handleCreate = async () => {
    setLoading(true)
    await supabase.from('projects').insert({ name: 'New' })
    setLoading(false)
  }

  return (
    <button onClick={handleCreate} disabled={loading}>
      {loading ? 'Creating...' : 'Create Project'}
    </button>
  )
}
```

---

## API Routes

```tsx
// app/api/projects/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { createServerClient } from '@/lib/supabase/server'

export async function GET() {
  const supabase = createServerClient()
  const { data, error } = await supabase.from('projects').select('*')

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json(data)
}

export async function POST(request: NextRequest) {
  const supabase = createServerClient()
  const body = await request.json()

  const { data, error } = await supabase
    .from('projects')
    .insert(body)
    .select()
    .single()

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }

  return NextResponse.json(data, { status: 201 })
}
```

---

## Middleware

```tsx
// middleware.ts
import { NextResponse, type NextRequest } from 'next/server'
import { createMiddlewareClient } from '@supabase/ssr'

export async function middleware(request: NextRequest) {
  const response = NextResponse.next()

  const supabase = createMiddlewareClient({
    request,
    response
  })

  const { data: { session } } = await supabase.auth.getSession()

  // Protected routes
  if (request.nextUrl.pathname.startsWith('/dashboard') && !session) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  return response
}

export const config = {
  matcher: ['/dashboard/:path*']
}
```

---

## Supabase Setup

```tsx
// lib/supabase/server.ts
import { createServerClient as createClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export function createServerClient() {
  const cookieStore = cookies()

  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name) {
          return cookieStore.get(name)?.value
        },
        set(name, value, options) {
          cookieStore.set(name, value, options)
        },
        remove(name, options) {
          cookieStore.set(name, '', options)
        },
      },
    }
  )
}
```

---

## Loading & Error States

```tsx
// app/projects/loading.tsx
export default function Loading() {
  return <div>Loading projects...</div>
}

// app/projects/error.tsx
'use client'

export default function Error({
  error,
  reset,
}: {
  error: Error
  reset: () => void
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={reset}>Try again</button>
    </div>
  )
}
```
