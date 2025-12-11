---
name: techstack
description: "Framework selection criteria: Vue vs React vs Next.js, stack recommendations by project size"
---

# Tech Stack Selection

> Optimized stack for AI-driven development with Supabase + OpenRouter.

---

## Quick Decision Guide

| Project Type | Size | Recommended Stack |
|--------------|------|-------------------|
| Simple CRUD app | Small (<10 views) | Vue 3 + Express + Supabase |
| Team web app | Medium (10-30 views) | React + Vite + Express + Supabase |
| Complex SaaS | Large (30+ views) | Next.js 14 + Supabase |
| AI-powered app | Any | Next.js 14 + OpenRouter + Supabase |
| Static + islands | Small | Astro + React/Vue islands |

---

## Selection Factors

**Choose Vue 3 when:**
- Small-medium project (<30 views)
- Team prefers Vue / has Vue experience
- Rapid prototyping needed
- Single-page application without SSR

**Choose React + Vite when:**
- Medium-large project
- Need large component ecosystem
- Team knows React
- Better AI tooling support

**Choose Next.js 14 when:**
- Need SSR/SEO
- AI features with streaming
- Full-stack TypeScript
- Production-ready from day 1

---

## Recommended Stack

```yaml
Frontend:
  Framework: Next.js 14 (App Router)
  Language: TypeScript
  UI: Shadcn/ui + Tailwind CSS
  State: Zustand or TanStack Query

Backend:
  Database: Supabase (PostgreSQL)
  Auth: Supabase Auth
  Storage: Supabase Storage
  API: Next.js API Routes or Express

AI:
  Provider: OpenRouter
  Models: Claude 3.5 Sonnet (primary)
  Streaming: Yes

DevOps:
  Hosting: Vercel
  CI/CD: GitHub Actions
  Monitoring: Sentry
```

---

## Package Recommendations

### UI Components
```bash
# Shadcn/ui (recommended)
npx shadcn-ui@latest init

# Alternative: Radix + Tailwind
npm install @radix-ui/react-dialog @radix-ui/react-dropdown-menu
```

### State Management
```bash
# Simple: Zustand
npm install zustand

# Server state: TanStack Query
npm install @tanstack/react-query
```

### Forms
```bash
# React Hook Form + Zod
npm install react-hook-form @hookform/resolvers zod
```

### Database
```bash
# Supabase
npm install @supabase/supabase-js @supabase/ssr
```
