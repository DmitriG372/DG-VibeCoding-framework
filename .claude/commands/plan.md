---
description: Create implementation plan for a task
---

# /plan

Create a detailed implementation plan before coding.

## Instructions

1. **Load planner agent definition:**
   ```
   Read: agents/planner.md
   ```

2. **Read project context:**
   ```
   Read: PROJECT.md
   ```

3. **Analyze the task:**
   - What is the goal?
   - What exists currently?
   - What constraints apply?

4. **Break down into steps:**
   - Each step should be atomic
   - Include acceptance criteria
   - Identify dependencies

5. **Identify skills needed:**
   - Which framework skills are relevant?
   - Load them: `Skill: <skill-name>`

6. **Output the plan** (do NOT implement yet):

```yaml
## Implementation Plan

### Goal
[What we're trying to achieve]

### Current State
[What exists now - from reading codebase]

### Implementation Steps
1. [ ] **Step name**
   - Action: What to do
   - Acceptance: How to verify done
   - Files: Which files affected

2. [ ] **Step name**
   - Action: What to do
   - Depends on: Step 1
   - Acceptance: How to verify

### Risks & Considerations
- [Potential issue] → [Mitigation]

### Skills to Load
- `skill-name` - why needed

### Estimated Complexity
LOW | MEDIUM | HIGH

---
⏸️ **Waiting for approval before implementing.**
```

## Example

Input: `/plan Add email validation to signup form`

Output:
```yaml
## Implementation Plan

### Goal
Add client and server-side email validation to the signup form.

### Current State
- Signup form exists at src/components/SignupForm.tsx
- No validation currently
- API endpoint at /api/auth/signup

### Implementation Steps
1. [ ] **Add Zod schema**
   - Action: Create validation schema with email regex
   - Files: src/lib/validations/auth.ts
   - Acceptance: Schema validates email format

2. [ ] **Update form component**
   - Action: Integrate react-hook-form with Zod
   - Depends on: Step 1
   - Files: src/components/SignupForm.tsx
   - Acceptance: Shows error on invalid email

3. [ ] **Add server validation**
   - Action: Validate in API route
   - Files: src/app/api/auth/signup/route.ts
   - Acceptance: Returns 400 on invalid email

4. [ ] **Write tests**
   - Action: Unit tests for validation
   - Files: tests/auth.test.ts
   - Acceptance: Tests pass

### Skills to Load
- `typescript` - for Zod types
- `react` - for form handling
- `testing` - for test patterns

### Estimated Complexity
MEDIUM

---
⏸️ **Waiting for approval before implementing.**
```

---

*Part of DG-SuperVibe-Framework v2.4*
