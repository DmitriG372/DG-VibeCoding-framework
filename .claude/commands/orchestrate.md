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

   | Task Type | Primary | Support | Notes |
   |-----------|---------|---------|-------|
   | New feature | implementer | reviewer, tester | Max 5 steps |
   | Bug fix | debugger | reviewer, tester | |
   | Code review | reviewer | tester | |
   | Testing | tester | debugger | |
   | Complex/multi-domain | implementer | reviewer, tester, debugger | Max 5 steps per phase |
   | Large volume | Either | assign via /feature or /handoff | |

4. **Create execution plan:**
   - List phases in order
   - Identify parallel opportunities
   - Note dependencies between phases

5. **Enforce step limits and evidence requirements:**
   - Kui plaanil on rohkem kui 5 sammu: jaota Phase 1 (sammud 1-5) ja Phase 2+ (ülejäänud)
   - Esita AINULT Phase 1 täitmiseks
   - Phase 2 luuakse PÄRAST Phase 1 lõpetamist verifitseeritud tulemustega
   - Igal sammul PEAB olema kontrollitav väljund "Expected output" väljal
   - Ebamäärased väljundid nagu "architecture designed" ei ole aktsepteeritavad
   - Aktsepteeritav: "Fail `src/auth/schema.ts` loodud User interface definitsiooniga"

6. **Check for sprint mode:**
   ```
   If exists: sprint/sprint.json
   Then: Enforce one-feature-at-a-time rule
   ```

7. **Output orchestration plan** in this format:

```yaml
## Orchestration Plan

**Task:** <ülesande kirjeldus>
**Complexity:** LOW | MEDIUM | HIGH
**Phase:** 1/N (ainult esimene faas nähtav)

### Execution Steps (max 5)
1. **<Sammu nimi>**
   - Agent: <agent>
   - Action: <konkreetne tegevus>
   - Expected output: <kontrollitav tulemus>
   - Evidence: <kuidas tõestada lõpetamist>
   - Status: PENDING

### Checkpoint
Pärast iga sammu näita:
- Tegelik vs oodatud väljund
- Lõpetamise tõend
- Uuendatud staatus (DONE/FAILED)
```

## Example

Input: `/orchestrate Add user authentication with JWT`

Output:
```yaml
## Orchestration Plan

**Task:** Add user authentication with JWT
**Complexity:** HIGH

**Phase:** 1/1

### Execution Steps (max 5)
1. **Design + Schema** - implementer designs auth flow and creates user schema
   - Evidence: schema file created
2. **API + UI** - implementer implements auth endpoints and login UI
   - Evidence: endpoint responds correctly
3. **Review** - reviewer checks security and code quality
   - Evidence: review checklist completed
4. **Testing** - tester writes and runs auth tests
   - Evidence: test output shown

### Next Step
Starting step 1: Design + Schema...
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

**Phase:** 1/1

### Execution Steps (max 5)

1. **Design** (sequential)
   - Agent: implementer
   - Action: Design dashboard architecture
   - Evidence: architecture documented

2. **Implementation** (PARALLEL)
   - 2a. Agent: implementer
     - Action: Create chart components + data endpoints
   - Evidence: components render, endpoints respond

3. **Integration** (sequential, depends on 2)
   - Agent: implementer
   - Action: Connect frontend to backend
   - Evidence: dashboard loads with real data

4. **Testing** (PARALLEL)
   - Agent: tester - Unit + Integration + E2E tests
   - Evidence: test output shown

5. **Review** (sequential)
   - Agent: reviewer
   - Action: Final code review
   - Evidence: review checklist completed
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

*Part of DG-VibeCoding-Framework v5.0.0*
*Parallel execution + Ctrl+B backgrounding from CC 2.1.0*
