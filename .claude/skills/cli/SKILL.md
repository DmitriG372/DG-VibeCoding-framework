---
name: cli
description: "Command line patterns: shell basics, pnpm/npm, file operations, scripting, Makefile automation"
---

# CLI Patterns

> Command line tools and automation.

---

## Shell Basics

### Navigation
```bash
pwd                    # Print working directory
cd /path/to/dir        # Change directory
cd ~                   # Home directory
cd -                   # Previous directory

ls                     # List files
ls -la                 # Detailed with hidden
ls -lh                 # Human-readable sizes
```

### File Operations
```bash
# Create
touch file.txt         # Create empty file
mkdir dirname          # Create directory
mkdir -p a/b/c         # Create nested directories

# Copy
cp file.txt backup.txt
cp -r dir/ backup/     # Copy directory recursively

# Move/Rename
mv old.txt new.txt
mv file.txt ../        # Move to parent

# Delete
rm file.txt
rm -r directory/       # Delete directory
rm -rf directory/      # Force delete

# View
cat file.txt           # Print file
head -20 file.txt      # First 20 lines
tail -20 file.txt      # Last 20 lines
tail -f file.log       # Follow file (live)
less file.txt          # Paginated view
```

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

## Search & Filter

### Find Files
```bash
find . -name "*.ts"           # Find by name
find . -type f -mtime -7      # Modified in last 7 days
find . -type d -name "node_*" # Directories matching pattern
```

### Search Content
```bash
grep "pattern" file.txt        # Search in file
grep -r "pattern" ./           # Recursive search
grep -i "pattern" file.txt     # Case insensitive
grep -n "pattern" file.txt     # Show line numbers
grep -l "pattern" *.ts         # List files with matches
```

### Combine with Pipe
```bash
cat file.txt | grep "error"
ls -la | grep ".ts"
find . -name "*.ts" | head -10
```

---

## Process Management

```bash
# View processes
ps aux                 # All processes
ps aux | grep node     # Filter

# Kill process
kill PID
kill -9 PID            # Force kill
killall node           # Kill by name

# Background/foreground
command &              # Run in background
jobs                   # List background jobs
fg %1                  # Bring to foreground
bg %1                  # Continue in background
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
# Set for current session
export NODE_ENV=development

# Set for single command
NODE_ENV=production npm run build

# View
echo $NODE_ENV
printenv

# .env file loading
source .env
# Or use dotenv in Node.js
```

---

## Useful One-liners

```bash
# Find and replace in files
find . -name "*.ts" -exec sed -i '' 's/old/new/g' {} +

# Count lines of code
find . -name "*.ts" | xargs wc -l

# Disk usage
du -sh *              # Size of each item
du -sh .              # Total size
df -h                 # Disk space

# Port usage
lsof -i :3000         # What's using port 3000
kill $(lsof -t -i:3000)  # Kill process on port

# Watch file changes
watch -n 1 'ls -la'   # Run every 1 second
```

---

## SSH & Remote

```bash
# Connect
ssh user@hostname

# Copy files
scp file.txt user@host:/path/
scp -r dir/ user@host:/path/

# SSH key
ssh-keygen -t ed25519 -C "email@example.com"
cat ~/.ssh/id_ed25519.pub  # Copy to GitHub/server
```
