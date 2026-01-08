# Playwright MCP Integration

## Overview

Playwright MCP enables Claude to control browsers for web automation, UI testing, screenshot capture, and visual feedback loops. Use it for frontend development, testing, and visual debugging.

## Installation

```bash
claude mcp add playwright -- npx @anthropic-ai/mcp-playwright
```

Or add to `.mcp.json`:
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@anthropic-ai/mcp-playwright"]
    }
  }
}
```

## When to Use

- Visual UI debugging
- Frontend component development
- Screenshot-based feedback
- Form filling and testing
- Web scraping and automation
- Cross-browser testing
- Visual regression detection

## Available Tools

### Navigation
| Tool | Description |
|------|-------------|
| `browser_navigate` | Go to URL |
| `browser_navigate_back` | Go back |
| `browser_tabs` | List, create, close, select tabs |

### Page Interaction
| Tool | Description |
|------|-------------|
| `browser_click` | Click element |
| `browser_type` | Type text into element |
| `browser_hover` | Hover over element |
| `browser_drag` | Drag and drop |
| `browser_press_key` | Press keyboard key |
| `browser_select_option` | Select dropdown option |
| `browser_fill_form` | Fill multiple form fields |
| `browser_file_upload` | Upload files |

### Page Analysis
| Tool | Description |
|------|-------------|
| `browser_snapshot` | Get accessibility tree (RECOMMENDED) |
| `browser_take_screenshot` | Capture visual screenshot |
| `browser_console_messages` | Get console logs |
| `browser_network_requests` | Get network activity |
| `browser_evaluate` | Execute JavaScript |

### Dialog & Control
| Tool | Description |
|------|-------------|
| `browser_handle_dialog` | Accept/dismiss dialogs |
| `browser_wait_for` | Wait for text/element/time |
| `browser_resize` | Resize browser window |
| `browser_close` | Close browser |

## Key Concept: Snapshots vs Screenshots

**`browser_snapshot`** (PREFERRED):
- Returns accessibility tree structure
- Machine-readable element references (`ref` attributes)
- Better for automation and interaction
- Lower token cost

**`browser_take_screenshot`**:
- Visual image of page
- Good for visual inspection
- Cannot perform actions based on it
- Higher token cost

## Element References

After `browser_snapshot`, elements have `ref` attributes:

```
- button "Submit" [ref=btn-1]
- textbox "Email" [ref=input-2]
- link "Home" [ref=link-3]
```

Use `ref` in subsequent actions:
```
browser_click(element="Submit button", ref="btn-1")
browser_type(element="Email input", ref="input-2", text="user@example.com")
```

---

## Integration Patterns

### Pattern 1: Visual Development Workflow

```yaml
workflow:
  name: "UI Component Development"
  steps:
    1. browser_navigate:
         url: "http://localhost:3000"
    2. browser_snapshot:
         # Get current state
    3. # Implement changes to code
    4. browser_navigate:
         url: "http://localhost:3000"  # Refresh
    5. browser_snapshot:
         # Verify changes
    6. # Iterate until satisfied
```

### Pattern 2: Form Testing

```yaml
workflow:
  name: "Form Submission Test"
  steps:
    1. browser_navigate:
         url: "http://localhost:3000/signup"
    2. browser_snapshot:
         # Get form structure
    3. browser_fill_form:
         fields:
           - name: "Email"
             type: "textbox"
             ref: "email-input"
             value: "test@example.com"
           - name: "Password"
             type: "textbox"
             ref: "password-input"
             value: "SecurePass123"
    4. browser_click:
         element: "Submit button"
         ref: "submit-btn"
    5. browser_wait_for:
         text: "Success"
    6. browser_snapshot:
         # Verify result
```

### Pattern 3: Visual Regression Check

```yaml
workflow:
  name: "Visual Regression"
  steps:
    1. browser_navigate:
         url: "http://localhost:3000/component"
    2. browser_take_screenshot:
         filename: "before.png"
    3. # Make code changes
    4. browser_navigate:
         url: "http://localhost:3000/component"
    5. browser_take_screenshot:
         filename: "after.png"
    6. # Compare screenshots
```

### Pattern 4: Debug UI Issue

```yaml
workflow:
  name: "Debug UI Problem"
  steps:
    1. browser_navigate:
         url: "http://localhost:3000/broken-page"
    2. browser_console_messages:
         level: "error"
    3. browser_network_requests:
         # Check for failed requests
    4. browser_snapshot:
         # Analyze DOM structure
    5. # Identify and fix issue
```

### Pattern 5: E2E User Flow

```yaml
workflow:
  name: "User Registration Flow"
  steps:
    1. browser_navigate:
         url: "http://localhost:3000"
    2. browser_click:
         element: "Sign Up link"
         ref: "signup-link"
    3. browser_fill_form:
         fields:
           - name: "Name"
             type: "textbox"
             ref: "name-input"
             value: "Test User"
           # ... more fields
    4. browser_click:
         element: "Create Account"
         ref: "create-btn"
    5. browser_wait_for:
         text: "Welcome"
    6. browser_snapshot:
         # Verify dashboard loaded
```

---

## Auto-Trigger Keywords

Playwright should be used when:
- "Check how [page] looks"
- "Test the [form/button/component]"
- "Take a screenshot of [page]"
- "Fill out the [form]"
- "Click on [element]"
- "Debug the UI issue on [page]"
- "Navigate to [URL]"
- "What does [page] show?"

---

## Common Use Cases

### 1. Frontend Development Loop

```
Developer: "Style the login button to be blue with rounded corners"

Claude:
1. browser_navigate → localhost:3000/login
2. browser_snapshot → see current state
3. Edit CSS/component code
4. browser_navigate → refresh
5. browser_snapshot → verify changes
6. Iterate until correct
```

### 2. Bug Reproduction

```
Developer: "The submit button doesn't work"

Claude:
1. browser_navigate → affected page
2. browser_snapshot → get element refs
3. browser_click → try submit button
4. browser_console_messages → check errors
5. browser_network_requests → check API calls
6. Diagnose and fix
```

### 3. Responsive Testing

```
Developer: "Check mobile layout"

Claude:
1. browser_resize → width: 375, height: 812
2. browser_navigate → page URL
3. browser_snapshot → analyze mobile layout
4. Report issues or confirm OK
```

---

## Best Practices

1. **Use Snapshots First**: Always `browser_snapshot` before interacting
2. **Precise Refs**: Use exact `ref` values from snapshots
3. **Descriptive Elements**: Always provide `element` description for permissions
4. **Wait Appropriately**: Use `browser_wait_for` after actions that trigger loading
5. **Check Console**: Use `browser_console_messages` when debugging
6. **Local Development**: Start with `http://localhost:*` URLs for dev work

## Error Handling

| Error | Solution |
|-------|----------|
| Element not found | Re-run `browser_snapshot` to get current refs |
| Navigation timeout | Check if server is running |
| Click not working | Verify element is visible and enabled |
| Form submission fails | Check `browser_network_requests` for API errors |

## Permission Setup

Add to `.claude/settings.local.json` for auto-approval:

```json
{
  "permissions": {
    "allow": [
      "mcp__playwright__browser_navigate",
      "mcp__playwright__browser_snapshot",
      "mcp__playwright__browser_click",
      "mcp__playwright__browser_type",
      "mcp__playwright__browser_take_screenshot"
    ]
  }
}
```

Or use pattern matching:
```json
{
  "permissions": {
    "allow": [
      "mcp__playwright__*"
    ]
  }
}
```

---

## Example: Complete UI Development Session

```
1. Start dev server: npm run dev

2. "Open localhost:3000 and show me the homepage"
   → browser_navigate + browser_snapshot

3. "The header is too small, make it bigger"
   → Edit CSS
   → browser_navigate (refresh)
   → browser_snapshot (verify)

4. "Add a login button to the header"
   → Edit component
   → browser_navigate (refresh)
   → browser_snapshot (verify)

5. "Test the login button works"
   → browser_click (login button)
   → browser_wait_for (login form)
   → browser_snapshot (verify modal/page)

6. "Take a screenshot for documentation"
   → browser_take_screenshot(filename: "homepage-final.png")
```

---

*Part of DG-VibeCoding-Framework v2.6*
