---
description: Review code quality and provide feedback
---

# /review

Review code for quality, security, and best practices.

## Instructions

1. **Load reviewer agent definition:**
   ```
   Read: agents/reviewer.md
   ```

2. **Read project standards:**
   ```
   Read: PROJECT.md
   ```

3. **Identify what to review:**
   - Specific file(s) if provided
   - Recent changes (git diff)
   - Entire feature if in sprint mode

4. **Run through checklist:**

### Code Quality
- [ ] Follows PROJECT.md patterns
- [ ] No code duplication
- [ ] Clear naming conventions
- [ ] Appropriate complexity level
- [ ] Comments where needed (not obvious code)

### Functionality
- [ ] Meets requirements
- [ ] Edge cases handled
- [ ] Error handling in place
- [ ] Graceful degradation

### Security
- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] No SQL injection risks
- [ ] No XSS vulnerabilities
- [ ] Auth/authz properly checked

### Performance
- [ ] No obvious N+1 queries
- [ ] Efficient algorithms
- [ ] Appropriate caching
- [ ] No memory leaks

### Testing
- [ ] Tests exist for new code
- [ ] Tests are meaningful (not just coverage)
- [ ] Edge cases tested

5. **Output review** in this format:

```yaml
## Code Review

### Summary
[Overall assessment: APPROVE / NEEDS CHANGES / REJECT]

### Files Reviewed
- `path/to/file.ts` - [brief note]

### Issues Found
1. **[Severity: HIGH/MEDIUM/LOW]** - [Issue title]
   - Location: `file:line`
   - Problem: What's wrong
   - Suggestion: How to fix

### Good Practices Noted
- [What was done well]

### Recommendations (Optional)
- [Nice-to-have improvements]

### Verdict
✅ APPROVE | ⚠️ NEEDS CHANGES | ❌ REJECT
```

## Example

Input: `/review src/components/LoginForm.tsx`

Output:
```yaml
## Code Review

### Summary
Code is functional but has security concerns that need addressing.

### Files Reviewed
- `src/components/LoginForm.tsx` - Login form component

### Issues Found
1. **[HIGH]** - Password visible in console
   - Location: `LoginForm.tsx:45`
   - Problem: `console.log(password)` left in code
   - Suggestion: Remove debug logging

2. **[MEDIUM]** - No rate limiting mentioned
   - Location: Form submit handler
   - Problem: Could allow brute force
   - Suggestion: Add rate limiting on API side

3. **[LOW]** - Magic number
   - Location: `LoginForm.tsx:23`
   - Problem: `setTimeout(..., 3000)` - unclear why 3s
   - Suggestion: Extract to named constant

### Good Practices Noted
- Form uses react-hook-form with proper validation
- Error messages are user-friendly
- Loading state properly managed

### Recommendations
- Consider adding "remember me" checkbox
- Add password strength indicator

### Verdict
⚠️ NEEDS CHANGES - Fix HIGH severity issue before merge
```

---

*Part of DG-SuperVibe-Framework v2.4*
