---
description: Orchestrate complex multi-step tasks with agent coordination
---

# /orchestrate

Coordinate complex tasks that require multiple specialist agents.

## Instructions

1. **Load orchestrator agent definition:**
   ```
   Read: agents/orchestrator.md
   ```

2. **Analyze task complexity:**
   - LOW: Single file, simple change → route directly to implementer
   - MEDIUM: Multiple files, needs review → primary agent + reviewer
   - HIGH: Cross-domain, architecture needed → full orchestration

3. **Select agent team based on task type:**

   | Task Type | Primary | Support |
   |-----------|---------|---------|
   | New feature | planner | architect, implementer, tester |
   | Bug fix | debugger | implementer, tester |
   | Refactor | refactorer | reviewer, tester |
   | Performance | performance-specialist | implementer |
   | Security | security-specialist | reviewer |
   | UI work | frontend-specialist | implementer |
   | API work | backend-specialist | database-specialist |

4. **Create execution plan:**
   - List phases in order
   - Identify parallel opportunities
   - Note dependencies between phases

5. **Check for sprint mode:**
   ```
   If exists: sprint/sprint.json
   Then: Enforce one-feature-at-a-time rule
   ```

6. **Output orchestration plan** in this format:

```yaml
## Orchestration Plan

**Task:** <user's task description>
**Complexity:** LOW | MEDIUM | HIGH

### Agent Team
- Primary: <agent name>
- Support: [<agent>, <agent>]

### Execution Phases
1. **<Phase name>**
   - Agent: <agent>
   - Action: <what to do>
   - Output: <expected result>

2. **<Phase name>**
   - Agent: <agent>
   - Depends on: Phase 1
   - Action: <what to do>

### Next Step
<What Claude should do immediately>
```

## Example

Input: `/orchestrate Add user authentication with JWT`

Output:
```yaml
## Orchestration Plan

**Task:** Add user authentication with JWT
**Complexity:** HIGH

### Agent Team
- Primary: architect
- Support: [backend-specialist, security-specialist, tester]

### Execution Phases
1. **Design** - architect designs auth flow
2. **Database** - database-specialist creates user schema
3. **API** - backend-specialist implements endpoints
4. **Security** - security-specialist reviews
5. **Testing** - tester writes auth tests

### Next Step
Reading agents/architect.md to begin design phase...
```

---

## Parallel Execution (NEW v2.5)

Teatud ülesandeid saab täita paralleelselt, kiirendades töövoogu.

### Paralleelsuse Võimalused

| Faas | Paralleelne? | Näide |
|------|--------------|-------|
| Planeerimine | EI | Üks plaan korraga |
| Uurimine | JAH | Mitu faili korraga |
| Implementeerimine | OSALISELT | Sõltumatud komponendid |
| Testimine | JAH | Erinevad test suite'id |
| Review | EI | Järjestikku |

### Paralleelse Täitmise Juhis

1. **Identifitseeri sõltumatud ülesanded:**
   ```yaml
   Independent:
     - Component A tests
     - Component B tests
     - Documentation update

   Dependent (must be sequential):
     - Database migration → API update → Frontend update
   ```

2. **Kasuta Task tool'i paralleelseks:**
   ```
   # Käivita mitu agenti korraga
   Task: "Run unit tests" (background)
   Task: "Run integration tests" (background)
   Task: "Check linting" (background)

   # Oota tulemusi
   TaskOutput: all
   ```

3. **Jälgi ressursse:**
   - Max 3-4 paralleelset ülesannet korraga
   - Ära ülekoorma süsteemi
   - CPU-intensiivsed ülesanded järjestikku

### Parallel Orchestration Example

```yaml
## Orchestration Plan (Parallel)

**Task:** Add user dashboard with charts
**Complexity:** HIGH

### Agent Team
- Primary: architect
- Support: [frontend-specialist, backend-specialist, tester]

### Execution Phases

1. **Design** (sequential)
   - Agent: architect
   - Action: Design dashboard architecture

2. **Implementation** (PARALLEL)
   - 2a. Agent: frontend-specialist
     - Action: Create chart components
   - 2b. Agent: backend-specialist
     - Action: Create data endpoints
   - 2c. Agent: documenter (background)
     - Action: Update API docs

3. **Integration** (sequential, depends on 2a+2b)
   - Agent: implementer
   - Action: Connect frontend to backend

4. **Testing** (PARALLEL)
   - 4a. Agent: tester - Unit tests
   - 4b. Agent: tester - Integration tests
   - 4c. Agent: tester - E2E tests

5. **Review** (sequential)
   - Agent: reviewer
   - Action: Final code review
```

### Paralleelsuse Piirangud

| Piirang | Põhjus |
|---------|--------|
| Max 4 paralleelset agenti | Claude rate limiting |
| Ära paralleliseeri git operatsioone | Konfliktid |
| Database migrations järjestikku | Andmete terviklikkus |
| Review alati lõpus | Vajab täielikku pilti |

---

## Background Execution (CC 2.1.0)

Kasuta `Ctrl+B` agentide ja käskude taustal käivitamiseks.

### Kuidas Kasutada

1. **Käivita käsk tavaliselt:**
   ```
   /orchestrate "Generate tests for all components"
   ```

2. **Vajuta `Ctrl+B`** ajal kui käsk töötab:
   - Käsk jätkab taustal
   - Saad koheselt uue sisendi võimaluse
   - Tulemused ilmuvad automaatselt kui valmis

3. **Jätka teiste ülesannetega:**
   ```
   /review src/components/Button.tsx
   ```

### Backgrounding Use Cases

| Stsenaarium | Käsk | Miks Backgroundida |
|-------------|------|-------------------|
| Testide genereerimine | `/orchestrate "Generate tests"` | Võtab kaua, saab vahepeal tegeleda |
| Koodi migratsioon | `/orchestrate "Migrate Vue to React"` | Token-intensiivne |
| Dokumentatsiooni genereerimine | `/orchestrate "Document API"` | Ei vaja kohest tulemust |
| Turvaaudit | `/codex-review --full src/` | Codex töötab paralleelselt |

### Backgrounding + Parallel

Kombineeri background ja parallel execution:

```yaml
1. Käivita: /orchestrate "Add auth" [Ctrl+B] → background
2. Käivita: /codex-review src/ [Ctrl+B] → background
3. Tee manuaalselt väiksemaid muudatusi
4. Tulemused saabuvad järjest
```

### Tulemuste Vaatamine

```bash
# Vaata taustaülesandeid
/tasks

# Loe konkreetse ülesande tulemust
TaskOutput: <task_id>
```

---

*Part of DG-VibeCoding-Framework v2.6*
*Parallel execution + Ctrl+B backgrounding from CC 2.1.0*
