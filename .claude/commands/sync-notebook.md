---
description: "Sync project codebase to NotebookLM as a source"
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - AskUserQuestion
  - mcp__notebooklm__notebook_create
  - mcp__notebooklm__notebook_get
  - mcp__notebooklm__notebook_list
  - mcp__notebooklm__source_add
  - mcp__notebooklm__source_delete
---

# /sync-notebook

Sync project codebase snapshot to NotebookLM via repomix/gitingest + MCP.

## Usage

```
/sync-notebook
```

## Your Task

Execute all steps in order.

### Step 0: Detect Ingest Tool

Determine which tool is available (prefer repomix, fallback to gitingest):

```bash
command -v repomix && echo "TOOL=repomix" || (command -v gitingest && echo "TOOL=gitingest" || echo "TOOL=none")
```

- **repomix found** → use repomix (preferred)
- **gitingest found** → use gitingest (fallback)
- **neither found** → show error:
  ```
  No ingest tool found. Install one:
    npm install -g repomix     (Node.js)
    pipx install gitingest     (Python)
  ```

Store the detected tool for Step 2.

### Step 1: Read Configuration

```
Read: .claude/notebook.json
```

**If file does not exist:**

Ask the user:
- "Create a new NotebookLM notebook for this project?" → use `notebook_create` with project name as title
- "Or enter an existing notebook ID" → use provided ID

After getting a notebook_id, create `.claude/notebook.json` with initial structure (source_id will be null).

**If file exists:**
- Read `notebook_id` and `source_id`
- Validate notebook still exists: `notebook_get(notebook_id)`
- If notebook not found → ask user to create new or provide ID

### Step 2: Generate Snapshot

The output file is always: `/tmp/ingest-<project>.txt`

**If TOOL=repomix:**
```bash
repomix --output /tmp/ingest-$(basename "$PWD").txt --quiet
```

**If TOOL=gitingest:**
```bash
gitingest . --output /tmp/ingest-$(basename "$PWD").txt
```

Check output file size:
```bash
wc -c /tmp/ingest-$(basename "$PWD").txt
```

### Step 3: Update NotebookLM Source

**If `source_id` exists in config (previous sync):**

1. Delete old source:
   ```
   source_delete(source_id=<source_id>, confirm=true)
   ```

2. Add new source:
   ```
   source_add(
     notebook_id=<notebook_id>,
     source_type="file",
     file_path="/tmp/ingest-<project>.txt",
     wait=true
   )
   ```

**If `source_id` is null (first sync):**

1. Add source directly:
   ```
   source_add(
     notebook_id=<notebook_id>,
     source_type="file",
     file_path="/tmp/ingest-<project>.txt",
     wait=true
   )
   ```

3. Extract new `source_id` from the response.

### Step 4: Update Configuration

Get current git info:
```bash
git rev-parse --short HEAD 2>/dev/null || echo "no-git"
```

Write updated `.claude/notebook.json`:
```json
{
  "notebook_id": "<notebook_id>",
  "source_id": "<new_source_id>",
  "title": "<project name>",
  "last_sync": "<ISO 8601 timestamp>",
  "last_sync_commit": "<short git hash>"
}
```

### Step 5: Report

```text
╔══════════════════════════════════════════╗
║  NotebookLM Synced                       ║
╚══════════════════════════════════════════╝

Notebook: <title>
Tool:     <repomix or gitingest>
Source:   ingest-<project>.txt (<size>)
Link:     https://notebooklm.google.com/notebook/<notebook_id>
Commits since last sync: <N or "first sync">
```

### Step 6: Cleanup

```bash
rm /tmp/ingest-$(basename "$PWD").txt
```

## Error Handling

- **Ingest tool fails:** Show error, suggest trying the other tool
- **source_add fails:** Retry once. If still fails, keep old source_id in config and report error
- **source_delete fails:** Log warning, proceed with add (old source remains as extra)
- **notebook not found:** Ask user to create new or provide different ID

## Notes

- `.claude/notebook.json` is user-specific (Google account). Add to `.gitignore`.
- **repomix** respects `.repomixignore` and `.gitignore` for file filtering.
- **gitingest** respects `.gitingest` ignore file and `.gitignore`.
- Source file is cleaned up after successful upload.
- Tool preference: repomix > gitingest. Both produce LLM-friendly text output.

---

*DG-VibeCoding-Framework v4.1.0 — NotebookLM Integration*
