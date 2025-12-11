---
name: ui
description: "Frontend UI patterns: CSS variables, design tokens, component styling, distinctive non-AI-looking design"
---

# Frontend UI Design

> Create unique UI that doesn't look like typical AI-generated design.

---

## CSS Decomposition Strategy

### File Structure
```
styles/
├── globals.css         # Reset, typography, CSS variables
├── utilities.css       # Utility classes (.flex, .grid, .mt-4)
└── variables.css       # Design tokens

components/
├── Button/
│   ├── Button.tsx
│   └── Button.module.css   # Scoped styles
└── Card/
    ├── Card.tsx
    └── Card.module.css
```

### What Goes Where

| Global (styles/) | Scoped (component) |
|------------------|---------------------|
| CSS reset | Component-specific layout |
| Typography scale | Component variations |
| Color tokens | Hover/focus states |
| Spacing scale | Animations |
| Breakpoints | Internal structure |
| Utility classes | - |

---

## CSS Variables (Design Tokens)

```css
/* styles/variables.css */
:root {
  /* Colors */
  --color-primary: #2563eb;
  --color-secondary: #64748b;
  --color-background: #ffffff;
  --color-surface: #f8fafc;
  --color-text: #0f172a;
  --color-text-muted: #64748b;
  --color-border: #e2e8f0;
  --color-error: #ef4444;
  --color-success: #22c55e;

  /* Spacing */
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;

  /* Typography */
  --font-sans: system-ui, -apple-system, sans-serif;
  --font-mono: ui-monospace, monospace;
  --text-xs: 0.75rem;
  --text-sm: 0.875rem;
  --text-base: 1rem;
  --text-lg: 1.125rem;
  --text-xl: 1.25rem;

  /* Border Radius */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
  --shadow-md: 0 4px 6px rgba(0,0,0,0.1);
  --shadow-lg: 0 10px 15px rgba(0,0,0,0.1);
}
```

---

## Dark Mode

```css
:root {
  --color-background: #ffffff;
  --color-text: #0f172a;
}

[data-theme="dark"] {
  --color-background: #0f172a;
  --color-text: #f8fafc;
}
```

```tsx
// Toggle
function ThemeToggle() {
  const toggleTheme = () => {
    const current = document.documentElement.dataset.theme
    document.documentElement.dataset.theme =
      current === 'dark' ? 'light' : 'dark'
  }
}
```

---

## Component Patterns

### Button Variants
```css
.button {
  padding: var(--spacing-sm) var(--spacing-md);
  border-radius: var(--radius-md);
  font-weight: 500;
  transition: all 0.2s;
}

.button--primary {
  background: var(--color-primary);
  color: white;
}

.button--secondary {
  background: transparent;
  border: 1px solid var(--color-border);
}

.button--ghost {
  background: transparent;
}

.button:hover {
  opacity: 0.9;
}

.button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
```

### Card Component
```css
.card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: var(--spacing-lg);
  box-shadow: var(--shadow-sm);
}

.card--elevated {
  box-shadow: var(--shadow-md);
}
```

---

## Responsive Design

```css
/* Mobile first */
.container {
  padding: var(--spacing-md);
}

@media (min-width: 640px) {
  .container {
    padding: var(--spacing-lg);
  }
}

@media (min-width: 1024px) {
  .container {
    max-width: 1200px;
    margin: 0 auto;
  }
}
```

---

## Anti-Patterns to Avoid

### DON'T (AI-typical design)
- Generic gradient backgrounds
- Excessive shadows everywhere
- Perfect rounded corners on everything
- Over-animated UI
- Generic stock icons

### DO (Distinctive design)
- Subtle, purposeful color choices
- Minimal shadows, strategic placement
- Mix of sharp and rounded elements
- Meaningful animations only
- Custom or carefully chosen icons
