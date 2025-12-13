---
name: debugging
description: "Debugging techniques: console methods, browser DevTools, network inspection, error tracking, logging strategies"
---

# Debugging Techniques

> Systematic debugging for web development.

---

## Console Methods

### Beyond console.log
```typescript
// Styled output
console.log("%cImportant!", "color: red; font-size: 20px")

// Table for arrays/objects
console.table([{ id: 1, name: "A" }, { id: 2, name: "B" }])

// Grouped logs
console.group("User Flow")
console.log("Step 1: Login")
console.log("Step 2: Dashboard")
console.groupEnd()

// Collapsed group
console.groupCollapsed("Details")
console.log("Hidden by default")
console.groupEnd()

// Timing
console.time("fetch")
await fetchData()
console.timeEnd("fetch") // fetch: 234.56ms

// Count calls
function onClick() {
  console.count("click") // click: 1, click: 2, ...
}

// Assertions
console.assert(user !== null, "User should exist")

// Stack trace
console.trace("How did we get here?")
```

---

## Structured Logging

```typescript
// Debug levels
const logger = {
  debug: (msg: string, data?: object) => {
    if (process.env.NODE_ENV === 'development') {
      console.log(`[DEBUG] ${msg}`, data)
    }
  },
  info: (msg: string, data?: object) => {
    console.log(`[INFO] ${msg}`, data)
  },
  warn: (msg: string, data?: object) => {
    console.warn(`[WARN] ${msg}`, data)
  },
  error: (msg: string, error?: Error) => {
    console.error(`[ERROR] ${msg}`, error)
  }
}

// Usage
logger.debug('Fetching user', { userId })
logger.error('Failed to fetch', error)
```

---

## Browser DevTools

### Network Tab
```typescript
// Filter requests
// - XHR: fetch/XMLHttpRequest
// - WS: WebSocket
// - Doc: Document requests

// Copy as cURL for debugging
// Right-click → Copy → Copy as cURL

// Throttle network
// - Fast 3G, Slow 3G for mobile testing
```

### Application Tab
```typescript
// LocalStorage inspection
localStorage.setItem('debug', JSON.stringify({ enabled: true }))

// Clear storage
localStorage.clear()
sessionStorage.clear()

// Cookie inspection
document.cookie
```

### Performance Tab
```typescript
// Profile rendering
// 1. Click Record
// 2. Interact with page
// 3. Stop recording
// 4. Analyze flame chart

// React DevTools
// Components tab → Highlight updates
// Profiler → Record → Identify slow renders
```

---

## Debugging React

### React DevTools
```typescript
// Component props/state inspection
// - Components tab
// - Click component
// - View/edit props and state

// useDebugValue for custom hooks
function useAuth() {
  const [user, setUser] = useState(null)
  useDebugValue(user ? 'Logged in' : 'Logged out')
  return { user }
}
```

### Error Boundaries
```typescript
class ErrorBoundary extends React.Component {
  state = { hasError: false, error: null }

  static getDerivedStateFromError(error) {
    return { hasError: true, error }
  }

  componentDidCatch(error, errorInfo) {
    console.error('Error caught:', error, errorInfo)
    // Log to error tracking service
  }

  render() {
    if (this.state.hasError) {
      return <div>Something went wrong</div>
    }
    return this.props.children
  }
}
```

---

## Debugging Vue

### Vue DevTools
```typescript
// Component inspection
// - Components tab
// - Select component
// - View data, props, computed

// Vuex/Pinia state
// - State tab
// - Time-travel debugging
```

### Debug Composables
```typescript
// Add debug watchers
const { user } = useAuth()

watch(user, (newVal, oldVal) => {
  console.log('User changed:', { oldVal, newVal })
}, { immediate: true })
```

---

## Network Debugging

### Fetch Interceptor
```typescript
const originalFetch = window.fetch
window.fetch = async (...args) => {
  console.log('Fetch:', args[0])
  const start = performance.now()
  const response = await originalFetch(...args)
  const duration = performance.now() - start
  console.log(`Response: ${response.status} (${duration.toFixed(2)}ms)`)
  return response
}
```

### API Error Handling
```typescript
async function fetchWithLogging(url: string) {
  try {
    const response = await fetch(url)
    if (!response.ok) {
      console.error('API Error:', {
        url,
        status: response.status,
        statusText: response.statusText
      })
    }
    return response
  } catch (error) {
    console.error('Network Error:', { url, error })
    throw error
  }
}
```

---

## Common Issues

### "undefined is not a function"
```typescript
// Check optional chaining
user?.getProfile?.()

// Verify imports
import { getUser } from './userService' // Named export
import getUser from './userService'      // Default export
```

### "Cannot read property of null"
```typescript
// Use optional chaining
const name = user?.profile?.name

// Or guard clause
if (!user) return null
```

### State Not Updating
```typescript
// React: Ensure new reference
setItems([...items, newItem]) // ✅
items.push(newItem); setItems(items) // ❌

// Vue: Check reactivity
const obj = reactive({ count: 0 })
obj.count++ // ✅ Reactive
```
