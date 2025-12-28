---
description: "Initialize sprint tracking from PROJECT.md tasks."
---

# Command: /sprint-init

Initialize sprint tracking from PROJECT.md tasks.

## Usage

```
/sprint-init [sprint-name]
```

## Instructions

1. **Read PROJECT.md#Current Sprint section**
   - Parse all tasks with `- [ ]` format
   - Extract acceptance criteria (text after `—` or in sub-bullets)

2. **Create sprint/ directory** (if not exists)

3. **Generate sprint/sprint.json**
   ```json
   {
     "version": "2.1",
     "project": "<from PROJECT.md>",
     "sprint": {
       "name": "<sprint-name or 'Sprint 1'>",
       "started": "<today's date>",
       "goal": "<from PROJECT.md or ask user>"
     },
     "features": [
       {
         "id": "F001",
         "name": "<task name>",
         "description": "<task description>",
         "status": "pending",
         "tested": false,
         "commits": [],
         "acceptance": ["<criteria>"]
       }
     ],
     "current_feature": null,
     "stats": {
       "total": <count>,
       "completed": 0,
       "in_progress": 0,
       "pending": <count>
     }
   }
   ```

4. **Generate sprint/progress.md**
   - Copy from template
   - Fill in sprint info
   - List all pending features

5. **Report initialization**

## Output Format

```
╔══════════════════════════════════════════════════╗
║  Sprint Initialized                              ║
╚══════════════════════════════════════════════════╝

Sprint: <name>
Goal: <goal>
Features: <count>

Pending:
  F001: <feature 1>
  F002: <feature 2>
  ...

Use /feature to start working on the first feature.
Use /sprint-status to see progress at any time.
```

## Example

**PROJECT.md contains:**
```markdown
## Current Sprint

### Active Tasks
- [ ] User authentication — users can register and login
- [ ] Product catalog — display products with filtering
- [ ] Shopping cart — add/remove items, persist state
```

**After /sprint-init:**
```
Sprint Initialized

Sprint: Sprint 1
Goal: MVP ready
Features: 3

Pending:
  F001: User authentication
  F002: Product catalog
  F003: Shopping cart

Use /feature to start working on F001.
```

## Notes

- Run once per sprint
- Re-running will ask for confirmation before overwriting
- Preserves completed features if re-initializing
- Works with existing PROJECT.md task format

---

*Part of DG-VibeCoding-Framework v2.1*
