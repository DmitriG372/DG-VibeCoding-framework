# Integrations Index

> External tools and protocols that extend Claude Code capabilities.

---

## MCP Integrations

Model Context Protocol servers that provide additional functionality.

| Integration | Purpose | Status |
|-------------|---------|--------|
| [Context7](mcp/context7.integration.md) | Up-to-date library documentation | Active |
| [Memory](mcp/memory.integration.md) | Persistent knowledge graph | Active |
| [Playwright](mcp/playwright.integration.md) | Browser automation & testing | Active |

---

## Native Integrations

Built-in Claude Code features that don't require MCP.

| Integration | Purpose | Status |
|-------------|---------|--------|
| [LSP](native/lsp.integration.md) | Code intelligence (go to definition, find references) | Active |

---

## Integration Categories

### Code Intelligence
- **LSP** - Semantic code understanding, refactoring support

### Documentation
- **Context7** - Always up-to-date library docs

### Memory & State
- **Memory MCP** - Cross-session knowledge persistence

### Testing & Automation
- **Playwright** - Browser control, E2E testing, screenshots

---

## Adding New Integrations

1. Create file: `integrations/<category>/<name>.integration.md`
2. Follow existing format:
   - Overview
   - Installation (if needed)
   - When to Use
   - Available Tools/Operations
   - Examples
   - Troubleshooting

3. Update this index

---

*Part of DG-VibeCoding-Framework v2.6*
