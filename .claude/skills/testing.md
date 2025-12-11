---
name: testing
description: "Testing patterns: Vitest unit tests, Playwright E2E, test-driven development, mocking strategies"
---

# Testing Patterns

> Test-Driven Development with Vitest and Playwright.

---

## Test Structure

```typescript
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'

describe('Feature: User Authentication', () => {
  beforeEach(() => {
    // Setup before each test
  })

  afterEach(() => {
    // Cleanup after each test
    vi.restoreAllMocks()
  })

  describe('login()', () => {
    it('should authenticate valid credentials', async () => {
      // Arrange
      const credentials = { email: 'test@example.com', password: 'password' }

      // Act
      const result = await login(credentials)

      // Assert
      expect(result.success).toBe(true)
      expect(result.user).toBeDefined()
    })

    it('should reject invalid credentials', async () => {
      const credentials = { email: 'test@example.com', password: 'wrong' }

      await expect(login(credentials)).rejects.toThrow('Invalid credentials')
    })
  })
})
```

---

## Vitest Configuration

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
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  }
})
```

---

## Mocking

### Mock Functions
```typescript
import { vi } from 'vitest'

const mockFn = vi.fn()
mockFn.mockReturnValue('value')
mockFn.mockResolvedValue('async value')
mockFn.mockImplementation((x) => x * 2)

expect(mockFn).toHaveBeenCalled()
expect(mockFn).toHaveBeenCalledWith('arg')
expect(mockFn).toHaveBeenCalledTimes(3)
```

### Mock Modules
```typescript
vi.mock('@/lib/supabase', () => ({
  supabase: {
    from: vi.fn(() => ({
      select: vi.fn().mockResolvedValue({ data: [], error: null }),
      insert: vi.fn().mockResolvedValue({ data: {}, error: null })
    }))
  }
}))
```

### Spy on Methods
```typescript
const spy = vi.spyOn(object, 'method')
spy.mockReturnValue('mocked')

// After test
spy.mockRestore()
```

---

## Testing React Components

```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { ProjectCard } from '@/components/ProjectCard'

describe('ProjectCard', () => {
  it('renders project name', () => {
    render(<ProjectCard project={{ id: '1', name: 'Test Project' }} />)

    expect(screen.getByText('Test Project')).toBeInTheDocument()
  })

  it('calls onDelete when delete button clicked', async () => {
    const onDelete = vi.fn()
    render(<ProjectCard project={{ id: '1', name: 'Test' }} onDelete={onDelete} />)

    fireEvent.click(screen.getByRole('button', { name: /delete/i }))

    await waitFor(() => {
      expect(onDelete).toHaveBeenCalledWith('1')
    })
  })
})
```

---

## Testing Vue Components

```typescript
import { mount } from '@vue/test-utils'
import ProjectCard from '@/components/ProjectCard.vue'

describe('ProjectCard', () => {
  it('renders project name', () => {
    const wrapper = mount(ProjectCard, {
      props: { project: { id: '1', name: 'Test Project' } }
    })

    expect(wrapper.text()).toContain('Test Project')
  })

  it('emits delete event', async () => {
    const wrapper = mount(ProjectCard, {
      props: { project: { id: '1', name: 'Test' } }
    })

    await wrapper.find('button.delete').trigger('click')

    expect(wrapper.emitted('delete')).toBeTruthy()
    expect(wrapper.emitted('delete')[0]).toEqual(['1'])
  })
})
```

---

## E2E with Playwright

```typescript
// tests/e2e/auth.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Authentication', () => {
  test('user can login', async ({ page }) => {
    await page.goto('/login')

    await page.fill('input[name="email"]', 'test@example.com')
    await page.fill('input[name="password"]', 'password')
    await page.click('button[type="submit"]')

    await expect(page).toHaveURL('/dashboard')
    await expect(page.locator('h1')).toContainText('Dashboard')
  })

  test('shows error for invalid credentials', async ({ page }) => {
    await page.goto('/login')

    await page.fill('input[name="email"]', 'test@example.com')
    await page.fill('input[name="password"]', 'wrong')
    await page.click('button[type="submit"]')

    await expect(page.locator('.error')).toContainText('Invalid credentials')
  })
})
```

---

## Test Organization

```
tests/
├── unit/                # Unit tests
│   ├── services/
│   └── utils/
├── integration/         # Integration tests
│   └── api/
├── e2e/                 # End-to-end tests
│   ├── auth.spec.ts
│   └── projects.spec.ts
├── fixtures/            # Test data
│   └── projects.json
└── setup.ts             # Global setup
```

---

## Running Tests

```bash
# All tests
pnpm test

# Watch mode
pnpm test:watch

# Coverage
pnpm test:coverage

# E2E
pnpm test:e2e

# E2E with UI
pnpm test:e2e --ui
```
