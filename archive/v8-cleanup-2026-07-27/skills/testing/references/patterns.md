# Testing Patterns — Reference

> Level 3 reference loaded on demand from `skills/testing/SKILL.md`. Contains copy-paste patterns for Vitest and Playwright.

---

## Vitest — Unit Test Shape

```typescript
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'

describe('Feature: User Authentication', () => {
  beforeEach(() => { /* setup */ })
  afterEach(() => { vi.restoreAllMocks() })

  describe('login()', () => {
    it('authenticates valid credentials', async () => {
      const credentials = { email: 'test@example.com', password: 'password' }
      const result = await login(credentials)
      expect(result.success).toBe(true)
      expect(result.user).toBeDefined()
    })

    it('rejects invalid credentials', async () => {
      await expect(
        login({ email: 'test@example.com', password: 'wrong' })
      ).rejects.toThrow('Invalid credentials')
    })
  })
})
```

## Vitest Config

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import path from 'path'

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./tests/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['node_modules/', 'tests/']
    }
  },
  resolve: { alias: { '@': path.resolve(__dirname, './src') } }
})
```

## Mocking

```typescript
// Mock function
const mockFn = vi.fn().mockResolvedValue('async value')
expect(mockFn).toHaveBeenCalledWith('arg')

// Mock module
vi.mock('@/lib/supabase', () => ({
  supabase: {
    from: vi.fn(() => ({
      select: vi.fn().mockResolvedValue({ data: [], error: null })
    }))
  }
}))

// Spy on method
const spy = vi.spyOn(object, 'method').mockReturnValue('mocked')
// ...
spy.mockRestore()
```

## React Component

```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react'

it('calls onDelete when delete button clicked', async () => {
  const onDelete = vi.fn()
  render(<ProjectCard project={{ id: '1', name: 'Test' }} onDelete={onDelete} />)
  fireEvent.click(screen.getByRole('button', { name: /delete/i }))
  await waitFor(() => expect(onDelete).toHaveBeenCalledWith('1'))
})
```

## Vue Component

```typescript
import { mount } from '@vue/test-utils'

it('emits delete event', async () => {
  const wrapper = mount(ProjectCard, {
    props: { project: { id: '1', name: 'Test' } }
  })
  await wrapper.find('button.delete').trigger('click')
  expect(wrapper.emitted('delete')?.[0]).toEqual(['1'])
})
```

## Playwright E2E

```typescript
import { test, expect } from '@playwright/test'

test.describe('Authentication', () => {
  test('user can login', async ({ page }) => {
    await page.goto('/login')
    await page.fill('input[name="email"]', 'test@example.com')
    await page.fill('input[name="password"]', 'password')
    await page.click('button[type="submit"]')
    await expect(page).toHaveURL('/dashboard')
  })
})
```

## Test Organization

```
tests/
├── unit/              # Vitest — services, utils
├── integration/       # Vitest — API routes
├── e2e/               # Playwright — user flows
├── fixtures/          # Test data
└── setup.ts           # Global setup
```

## Running Tests

```bash
pnpm test                # All unit tests
pnpm test:watch          # Watch mode
pnpm test:coverage       # With coverage
pnpm test:e2e            # Playwright
pnpm test:e2e --ui       # Playwright with UI
```
