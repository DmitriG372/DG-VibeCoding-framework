---
name: cli
description: "CLI patterns: pnpm/npm commands, Makefile automation, environment variables"
---

# CLI Patterns

> Project-specific command line conventions.

---

## Package Managers

### pnpm (Recommended)
```bash
# Install dependencies
pnpm install
pnpm i

# Add package
pnpm add package-name
pnpm add -D package-name  # Dev dependency

# Remove package
pnpm remove package-name

# Run scripts
pnpm dev
pnpm build
pnpm test

# Update packages
pnpm update
pnpm update --interactive
```

### npm
```bash
npm install
npm install package-name
npm install -D package-name
npm uninstall package-name
npm run dev
npm run build
```

---

## Makefile Patterns

```makefile
# Makefile
.PHONY: dev build test clean

# Development
dev:
	pnpm dev

# Build
build:
	pnpm build

# Testing
test:
	pnpm test

test-watch:
	pnpm test:watch

test-coverage:
	pnpm test:coverage

# Linting
lint:
	pnpm lint

typecheck:
	pnpm typecheck

# Pre-commit
pre-commit: lint typecheck test

# Clean
clean:
	rm -rf dist node_modules/.cache

# Help
help:
	@echo "Available commands:"
	@echo "  make dev       - Start development server"
	@echo "  make build     - Production build"
	@echo "  make test      - Run tests"
	@echo "  make lint      - Run linter"
	@echo "  make clean     - Clean build artifacts"
```

---

## Environment Variables

```bash
# Set for single command
NODE_ENV=production npm run build

# .env file (dotenv)
# .env
DATABASE_URL=postgresql://localhost:5432/db
API_KEY=your-key-here

# Load in code
import 'dotenv/config'
// or
import { config } from 'dotenv'
config()
```

### .env Security
```bash
# .gitignore
.env
.env.local
.env.*.local

# Use .env.example for documentation
# .env.example
DATABASE_URL=postgresql://localhost:5432/db
API_KEY=
```
