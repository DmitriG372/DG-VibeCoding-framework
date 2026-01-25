---
name: security
description: "Web security patterns: RLS policies, XSS prevention, CSRF protection, input validation, auth best practices"
---

# Security Patterns

> Web application security best practices.

---

## Authentication

### JWT Best Practices
```typescript
// Store tokens securely
// ❌ localStorage (XSS vulnerable)
// ✅ HttpOnly cookies (CSRF protected)

// Token structure
interface TokenPayload {
  sub: string      // User ID
  iat: number      // Issued at
  exp: number      // Expiration
  role?: string    // User role
}

// Token validation
function validateToken(token: string): TokenPayload {
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET!)
    return payload as TokenPayload
  } catch {
    throw new UnauthorizedError('Invalid token')
  }
}
```

### Session Management
```typescript
// Secure cookie options
const cookieOptions = {
  httpOnly: true,     // No JS access
  secure: true,       // HTTPS only
  sameSite: 'strict', // CSRF protection
  maxAge: 60 * 60 * 24 * 7, // 7 days
  path: '/'
}
```

---

## Row Level Security (RLS)

### Enable RLS
```sql
-- ALWAYS enable RLS on tables with user data
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- Force RLS even for table owners
ALTER TABLE projects FORCE ROW LEVEL SECURITY;
```

### Common Policies
```sql
-- User can only access own data
CREATE POLICY "Users own data"
  ON projects
  USING (auth.uid() = owner_id);

-- Role-based access
CREATE POLICY "Admins full access"
  ON projects
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid()
      AND role = 'admin'
    )
  );

-- Team access
CREATE POLICY "Team members view"
  ON projects FOR SELECT
  USING (
    owner_id = auth.uid()
    OR
    id IN (
      SELECT project_id FROM project_members
      WHERE user_id = auth.uid()
    )
  );
```

---

## Input Validation

### Zod Schema Validation
```typescript
import { z } from 'zod'

const userSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(100),
  name: z.string().min(1).max(100).trim()
})

// Validate input
function validateUser(data: unknown) {
  return userSchema.parse(data)
}

// Safe parse (no throw)
const result = userSchema.safeParse(data)
if (!result.success) {
  return { errors: result.error.flatten() }
}
```

### SQL Injection Prevention
```typescript
// ❌ Never interpolate user input
const query = `SELECT * FROM users WHERE id = '${userId}'`

// ✅ Use parameterized queries
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('id', userId)

// ✅ Prepared statements
const result = await db.query(
  'SELECT * FROM users WHERE id = $1',
  [userId]
)
```

---

## XSS Prevention

### React (Safe by Default)
```tsx
// ✅ React escapes by default
<div>{userInput}</div>

// ❌ Avoid dangerouslySetInnerHTML
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// If needed, sanitize first
import DOMPurify from 'dompurify'
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(content) }} />
```

### Content Security Policy
```typescript
// next.config.js
const securityHeaders = [
  {
    key: 'Content-Security-Policy',
    value: `
      default-src 'self';
      script-src 'self' 'unsafe-eval';
      style-src 'self' 'unsafe-inline';
      img-src 'self' data: https:;
      connect-src 'self' https://*.supabase.co;
    `.replace(/\n/g, '')
  }
]
```

---

## CSRF Protection

### SameSite Cookies
```typescript
// Strict: Cookies only sent for same-site requests
res.cookie('session', token, { sameSite: 'strict' })

// Lax: Cookies sent for top-level navigations
res.cookie('session', token, { sameSite: 'lax' })
```

### CSRF Tokens
```typescript
// Generate token
import crypto from 'crypto'
const csrfToken = crypto.randomBytes(32).toString('hex')

// Verify on form submission
function validateCsrf(req: Request) {
  const token = req.headers['x-csrf-token']
  const sessionToken = req.session.csrfToken

  if (!token || token !== sessionToken) {
    throw new ForbiddenError('Invalid CSRF token')
  }
}
```

---

## Secrets Management

### Environment Variables
```bash
# .env.example (commit this)
DATABASE_URL=
JWT_SECRET=
SUPABASE_SERVICE_ROLE_KEY=

# .env.local (never commit)
DATABASE_URL=postgresql://...
JWT_SECRET=super-secret-key
SUPABASE_SERVICE_ROLE_KEY=eyJ...
```

### Access Control
```typescript
// Server-only secrets
if (typeof window !== 'undefined') {
  throw new Error('This code must run on server only')
}

// Public vs private env vars
// NEXT_PUBLIC_* - exposed to browser
// Others - server only
```

---

## Security Checklist

- [ ] RLS enabled on all user-data tables
- [ ] Input validation on all endpoints
- [ ] Parameterized queries (no SQL injection)
- [ ] HttpOnly cookies for tokens
- [ ] CSP headers configured
- [ ] HTTPS enforced
- [ ] Secrets in environment variables
- [ ] Rate limiting on auth endpoints
- [ ] Error messages don't leak info
