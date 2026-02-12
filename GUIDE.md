# DG-VibeCoding-Framework v4.0.0 — Kasutusjuhend

> Equal Partnership Model — CC + CX kui võrdsed partnerid

---

## 1. Lühikirjeldus

DG-VibeCoding-Framework on universaalne raamistik AI-assisteeritud arenduseks, kus **Claude Code (CC)** ja **Codex (CX)** töötavad **võrdsete partneritena**. Kumbki ei ole teisele alluv.

```
CC (Claude Code)                    CX (Codex)
┌──────────────────┐              ┌──────────────────┐
│ Interaktiivne    │  PROJECT.md  │ Headless          │
│ Disain, UX       │◄───────────►│ Masstöö           │
│ Arhitektuur      │  .tasks/     │ Autonoomne        │
│ Kasutajadialoog  │  board.md    │ Paralleelne       │
└──────────────────┘              └──────────────────┘
```

**Koosseisus:**

| Komponent | Arv | Kirjeldus |
|-----------|-----|-----------|
| Skills | 6 | sub-agent, debugging, testing, git, vibecoding, partnership |
| Commands | 9 | /feature, /done, /review, /fix, /orchestrate, /peer-review, /handoff, /sync-tasks, /framework-update |
| Agents | 5 | orchestrator, implementer, reviewer, tester, debugger |
| Hooks | 3 | git-context, block-env, type-check |
| Scripts | 5 | worktree-setup, worktree-cleanup, headless-review, init-project, migrate-skills |

**Kolm võtmefaili igas projektis:**

| Fail | Roll |
|------|------|
| `PROJECT.md` | Single source of truth — stack, mustrid, reeglid |
| `CLAUDE.md` | CC (Claude Code) sisenemispunkt ja reeglid |
| `AGENTS.md` | CX (Codex) sisenemispunkt ja reeglid |

---

## 2. Parimad praktikad ja töövood

### 2.1 Millal kasutada CC-d, millal CX-i?

| Ülesanne | Partner | Miks | Reaalne näide |
|----------|---------|------|---------------|
| Interaktiivne disain | **CC** | Vajab kasutajadialoogi | melior-plus-mvp: Vue 3 komponentide prototüüpimine kasutajaga |
| Suur refaktoreerimine (10+ faili) | **CX** | Maht, autonoomne täitmine | lightning-wizard: NestJS moodulite migreerimine |
| Vea uurimine | **CC** | Arutlus, uurimine, tööriistade kasutus | project-aiks: miks skoorimismootor andis vale tulemuse |
| Massiline implementeerimine | **CX** | Headless, paralleelne worktree's | melior-plus-mvp: CRUD endpointide genereerimine |
| Arhitektuuriotsused | **CC** | Mitmeti tõlgendatav, vajab kaalutlust | project-aiks: "LLM as Extractor" vs "LLM as Judge" otsus |
| Testide genereerimine | **CX** | Korduv, mustripõhine | tktk-asistant: Pandoc integratsioonitestide kirjutamine |
| Koodi review | **Mõlemad** | /peer-review töötab mõlemat pidi | CC reviewb CX tööd ja vastupidi |

### 2.2 Töövoog: Solo (ainult CC)

Kõige tavalisem töövoog — CC teeb kõik ise.

```
Sessiooni algus
    ↓
CC loeb PROJECT.md
    ↓
/feature F001              ← alusta feature'i
    ↓
[Implementeeri kood]
    ↓
/review src/components/    ← kontrolli kvaliteeti
    ↓
/done                      ← testid + commit
    ↓
/feature F002              ← järgmine feature
```

**Reaalne näide (melior-plus-mvp):**
```
/feature F012              ← "Lisa RLS policy tabelile projects"
CC loeb PROJECT.md → leiab Vue 3 + Supabase stack
CC loeb olemasoleva skeemi
CC implementeerib RLS policy
/review supabase/migrations/
/done                      ← Vitest testid jooksevad, commit tehakse
```

### 2.3 Töövoog: Partnership (CC + CX)

Kui ülesanne on suur ja jagatav.

```
CC: /handoff "Implementeeri 8 API endpointi"
    ↓
CX saab worktree + branch cx/add-api-endpoints
    ↓
CC: [töötab paralleelselt teisel ülesandel]
CX: [autonoomne implementeerimine worktree's]
    ↓
CX: liigutab taski "In Review"
    ↓
CC: /peer-review cx/add-api-endpoints
    ↓
CC: merge või tagasiside
```

**Reaalne näide (project-aiks):**
```
CC: /handoff "Genereeri unit testid kõigile src/scoring/ failidele"

→ Luuakse: cx/add-scoring-tests branch
→ Luuakse: ../project-aiks-wt-cx-add-scoring-tests/ worktree
→ board.md uuendatakse

CX käivitatakse:
  cd ../project-aiks-wt-cx-add-scoring-tests/
  codex --full-auto

CX kirjutab 109 testi, liigutab taski "In Review"

CC: /peer-review cx/add-scoring-tests
→ Skoor: 16/17 (PASS)
→ Merge main'i
```

### 2.4 Töövoog: Headless Review

Kiire automaatne review ilma eraldi terminaalita.

```
CC: /peer-review --headless                 ← uncommitted muudatused
CC: /peer-review --headless feat/auth       ← branch
CC: /peer-review --headless --full src/     ← täisaudit
CC: /peer-review --headless --tool codex    ← Codex'iga
```

**Reaalne näide (melior-plus-mvp):**
```
CC: /peer-review --headless --full src/composables/

→ headless-review.sh käivitub claude -p'ga
→ JSON raport:
  { "score": 31, "max_score": 35, "verdict": "PASS",
    "issues": [{ "severity": "MINOR", "file": "useAuth.ts", ... }] }
→ CC näitab tulemusi
→ "Kas fixida MINOR issue? [Y/n]"
```

### 2.5 Töövoog: Orkestratsioon

Keeruline ülesanne, mis vajab mitut agenti.

```
CC: /orchestrate "Lisa kasutaja autentimine JWT-ga"

Orchestrator analüüsib:
  Keerukus: HIGH
  Meeskond: architect → backend-specialist → security-specialist → tester

Faasid:
  1. architect: disainib auth flow
  2. implementer: implementeerib endpointid
  3. security-specialist: turvaaudit
  4. tester: testid
  5. reviewer: lõppülevaatus
```

### 2.6 Töövoog: Vigade parandamine

```
CC: /fix "Login nupp ei tööta iOS Safari's"

Debugger agent:
  1. Reprodutseerib → touch event blokeerib click'i
  2. Minimaalne fix → e.stopPropagation()
  3. Verifitseerib → iOS Safari, Android Chrome, desktop
  4. Juurpõhjuse analüüs + preventsioon
```

---

## 3. Step-by-step juhised

### 3a. Kuidas alustada uut projekti

**Eeltingimused:**
- Framework kloonitud: `git clone https://github.com/DmitriG372/DG-VibeCoding-framework.git`
- Claude Code installitud
- (Valikuline) Codex installitud

**Sammud:**

#### Samm 1: Initsialiseeri projekt

```bash
# Loo projekti kaust
mkdir ~/my-new-project && cd ~/my-new-project
git init

# Kopeeri framework struktuur
/path/to/DG-VibeCoding-framework/scripts/init-project.sh .
```

See loob:
```
my-new-project/
├── PROJECT.md          ← Täida oma projekti infoga!
├── CLAUDE.md           ← CC reeglid (kohanda)
├── AGENTS.md           ← CX reeglid (kohanda)
└── .claude/
    ├── skills/         ← Lisa projekti-spetsiifilised skillid
    ├── commands/       ← Lisa projekti-spetsiifilised käsud
    └── agents/         ← Lisa projekti-spetsiifilised agendid
```

#### Samm 2: Täida PROJECT.md

See on **kõige olulisem samm**. PROJECT.md on single source of truth.

```markdown
# My New Project

## Tech Stack
- **Frontend:** React 18 + TypeScript + Tailwind
- **Backend:** Node.js + Express + PostgreSQL
- **Tests:** Vitest + Playwright

## Structure
- src/components/ — React komponendid
- src/services/ — API kliendid
- src/types/ — TypeScript tüübid

## Patterns
- Functional components only
- Service layer pattern for API calls
- Zod for input validation

## Rules
### Always
- TypeScript strict mode
- Test coverage >= 70%
### Never
- No `any` types
- No inline styles

## Commands
- `pnpm dev` — arendusserver
- `pnpm test` — testid
- `pnpm build` — produktsioon
```

#### Samm 3: Kohanda CLAUDE.md

Lisa projekti-spetsiifilised reeglid CC jaoks. Näiteks:

```markdown
# CC Rules — My New Project

## Session Start
1. Read PROJECT.md
2. Run `pnpm typecheck` to verify state
3. Check .tasks/board.md for active tasks

## Project Rules
- Use Zod schemas for ALL user input
- Never commit .env files
```

#### Samm 4: Kohanda AGENTS.md

AGENTS.md on juba v4.0.0 formaadis (init-project kopeerib template'i). Lisa ainult projekti-spetsiifilised reeglid.

#### Samm 5: Seadista hookid (valikuline)

Kopeeri soovitud hookid frameworkist:

```bash
mkdir -p hooks
cp /path/to/framework/hooks/git-context.js hooks/
cp /path/to/framework/hooks/block-env.js hooks/
```

Lisa `.claude/settings.json`:
```json
{
  "hooks": {
    "SessionStart": [{ "hooks": [{ "type": "command", "command": "node ./hooks/git-context.js", "once": true }] }],
    "PreToolUse": [{ "matcher": "Read|Grep", "hooks": [{ "type": "command", "command": "node ./hooks/block-env.js" }] }]
  }
}
```

#### Samm 6: Loo task board

```bash
mkdir -p .tasks
```

`.tasks/board.md`:
```markdown
# Task Board

## Backlog
- [ ] [TASK-001] Seadista projekt ja CI pipeline
- [ ] [TASK-002] Implementeeri autentimine

## Assigned to: CC
## Assigned to: CX
## In Review
## Completed
```

#### Samm 7: Esimene commit

```bash
git add .
git commit -m "feat: initialize project with DG-VibeCoding-Framework v4.0.0"
```

**Valmis!** Ava Claude Code ja alusta tööd: `claude`

---

### 3b. Kuidas migreerida olemasolev projekt

**Näide: melior-plus-mvp v2.5 → v4.0.0 migratsioon**

#### Samm 1: Varunda

```bash
cd ~/project
git stash  # või commit uncommitted muudatused
```

#### Samm 2: Uuenda AGENTS.md

Asenda vana fail v4.0.0 struktuuriga. Põhimõte:

**Vana (v2.5 — CX kui alluv):**
```markdown
# Codex Code Review Agent
> Roll: Range Code Auditor - kontrolli enne merge'i!
```

**Uus (v4.0.0 — CX kui partner):**
```markdown
# Codex Rules — My Project (v4.0.0)
> Project details → PROJECT.md | Task board → .tasks/board.md

## Context Loading
1. Read PROJECT.md first
2. Read .tasks/board.md for tasks
3. Work only on tasks assigned to CX

## Workflow (Before → During → After)
## Task Board Protocol
## Git Conventions (cx/ branch prefix)
## Project-Specific Rules (SÄILITA VANA SISU!)
## Rules (Always / Never)
```

**Oluline:** Säilita kõik projekti-spetsiifilised reeglid (RLS, Composition API, jne). Muuda ainult struktuur ja rollimudel.

#### Samm 3: Loo/uuenda .tasks/board.md

Kui puudub, loo:
```bash
mkdir -p .tasks
```

#### Samm 4: Kontrolli CLAUDE.md

Lisa SESSION START sektsioon mis loeb PROJECT.md.

#### Samm 5: Uuenda framework.json (kui on)

Lisa `review` blokk:
```json
{
  "review": {
    "tool": "claude",
    "mode": "quick"
  }
}
```

#### Samm 6: Kopeeri worktree skriptid (valikuline)

```bash
mkdir -p scripts
cp /path/to/framework/scripts/worktree-setup.sh scripts/
cp /path/to/framework/scripts/worktree-cleanup.sh scripts/
cp /path/to/framework/scripts/headless-review.sh scripts/
chmod +x scripts/*.sh
```

#### Samm 7: Commit

```bash
git add AGENTS.md .tasks/ scripts/
git commit -m "chore(agents): upgrade to DG-VibeCoding-Framework v4.0.0 Equal Partnership"
```

**Reaalne migratsioon tehti 2026-02-12:**
- melior-plus-mvp: v2.5 → v4.0.0 (170 → 106 rida)
- project-aiks: auto-generated → v4.0.0 (45 → 147 rida)
- tktk-asistant: vana mall → v4.0.0 (529 → 165 rida)
- lightning-wizard: generic → v4.0.0 (363 → 147 rida)

---

### 3c. Kuidas alustada sessiooni / sprinti

#### Sessiooni algus (iga kord)

```bash
# 1. Ava terminal projekti kaustas
cd ~/my-project

# 2. Käivita Claude Code
claude
```

CC teeb automaatselt:
1. `hooks/git-context.js` laeb viimased 20 commit'i ja muudetud failid
2. `hooks/block-env.js` aktiveerub .env failide kaitseks
3. CC loeb `PROJECT.md` (skills aktiveeruvad automaatselt)

```
# Esimene asi mida CC sessioonist ütleb:
> Read PROJECT.md for context...
> Skills activated: testing, git, partnership
> Last 3 commits: abc123, def456, ghi789
```

#### Sprindi algus

```bash
# 1. Kontrolli task board'i seisu
/sync-tasks

# 2. Vali feature
/feature F001              # konkreetne feature
/feature                   # esimene pending feature

# 3. CC näitab:
#    - Feature kirjeldus
#    - Aktsepteerimiskriteeriumid
#    - Soovitatud agentide voog
```

#### Partnership sessiooni algus

```bash
# 1. CC alustab oma tööd
/feature F001

# 2. Samal ajal anna CX-ile töö
/handoff "Implementeeri testid kõigile service failidele"

# 3. CX käivitamine eraldi terminalis
cd ../my-project-wt-cx-add-service-tests/
codex --full-auto

# 4. Kontrolli mõlema progressi
/sync-tasks
```

---

### 3d. Kuidas lõpetada sessiooni / sprinti

#### Feature'i lõpetamine

```bash
# 1. Kontrolli koodi kvaliteeti
/review src/features/auth/

# 2. Lõpeta feature (TESTID ON KOHUSTUSLIKUD!)
/done

# CC teeb automaatselt:
#   ✓ Jooksutab testid
#   ✓ Loob commit'i feature ID-ga
#   ✓ Uuendab sprint.json
#   ✓ Uuendab progress.md
#   ✓ Jooksutab /sync
```

Kui testid ebaõnnestuvad:
```
/done
→ ❌ Tests failed: 3 failures
→ CC peatub, näitab vigu
→ Paranda vead
→ /done (uuesti)
```

#### CX töö lõpetamine

```bash
# 1. CX liigutas taski "In Review" → CC saab teada

# 2. CC reviewb
/peer-review cx/add-service-tests

# 3a. Kui PASS:
git merge cx/add-service-tests
scripts/worktree-cleanup.sh cx/add-service-tests

# 3b. Kui NEEDS_CHANGES:
# CC annab tagasiside → CX parandab → uus review
```

#### Sessiooni lõpetamine

Enne sessiooni sulgemist:

```bash
# 1. Kontrolli, et kõik on commititud
git status

# 2. Kontrolli task board'i
/sync-tasks

# 3. Kui on pooleliolevaid CX töid:
#    Ära sulge worktree'd — CX saab jätkata järgmises sessioonis

# 4. Push muudatused (kui soovid)
git push
```

#### Sprindi lõpetamine

```bash
# 1. Kontrolli, et kõik feature'd on "Completed"
/sync-tasks

# 2. Viimane review
/peer-review --headless --full .

# 3. Merge kõik CX branchid
git merge cx/branch-1
git merge cx/branch-2
scripts/worktree-cleanup.sh cx/branch-1
scripts/worktree-cleanup.sh cx/branch-2

# 4. Uuenda board.md
# Liiguta kõik completed taskid arhiivi või kustuta

# 5. Lõpp-commit
git add .
git commit -m "chore: close sprint X — all features complete"
git push
```

---

## 4. Tips and Tricks

### Kiirviited

| Olukord | Käsk | Tulemus |
|---------|------|---------|
| "Mis toimub?" | `/sync-tasks` | Näed kõiki taskid, branche, worktree'sid |
| "Kiire review" | `/peer-review --headless` | Automaatne JSON raport 30 sekundiga |
| "Suur töö CX-ile" | `/handoff "kirjeldus"` | Branch + worktree + task automaatselt |
| "Viga!" | `/fix "kirjeldus"` | Debugger agent uurib süsteemselt |
| "Kuidas edasi?" | `/feature` | Võtab järgmise pending feature |

### Review tööriista valimine

Vali `framework.json` → `review.tool`:

```json
{ "review": { "tool": "claude", "mode": "quick" } }
```

- **claude** — parem koodianalüüs, ei vaja lisavõtit
- **codex** — alternatiivne vaatenurk, vajab OPENAI_API_KEY

Saab ka ad-hoc üle kirjutada:
```
/peer-review --headless --tool codex src/
```

### Worktree nipid

```bash
# Vaata kõiki aktiivseid worktree'sid
git worktree list

# Puhasta katkised viited
git worktree prune

# Kui CX jättis worktree räpaseks
git worktree remove ../project-wt-cx-old-branch --force
```

### Hookide keelamine ajutiselt

Kui hook segab (nt type-check ebaõnnestub draft'i ajal):

```bash
# Ära muuda settings.json!
# Kasuta hoopis --no-verify git commitil:
# (aga ainult ajutiselt!)
```

Parem lahendus — paranda tüübiviga enne commiti.

### Konteksti kaotuse taastamine

Kui CC kaotab konteksti (session compaction):

1. `/sync-tasks` — taastab task board'i seisu
2. `/feature` — taastab aktiivse feature sprint.json'ist
3. `git log --oneline -10` — viimased commitid
4. Hookid laevad git konteksti automaatselt

### Agentide otse kasutamine

Pole alati vaja käsku — saad agenti otse kutsuda:

```
"Kasuta security-specialist agenti et auditeerida src/auth/"
→ CC loeb .claude/agents/security-specialist.md (archive'ist)
→ Võtab turvaeksperdi rolli
→ Teeb põhjaliku turvaauditi
```

### Skill'ide debug

Kui skill ei aktiveeru:
1. Kontrolli kas fail on `SKILL.md` (mitte skill.md)
2. Kontrolli kas kausta struktuur on `.claude/skills/nimi/SKILL.md`
3. Kontrolli YAML frontmatter'i (peab olema `---` vahel)
4. Jooksuta: `scripts/migrate-skills.sh`

### Efektiivne PROJECT.md

Hea PROJECT.md = hea arenduskogemus. Nõuanded:

- **Ole konkreetne** — "Use Zod for validation" > "Validate inputs"
- **Lisa näiteid** — koodiplokid mustrite jaoks
- **Hoia lühike** — ~100-200 rida on ideaal
- **Uuenda regulaarselt** — peale igat arhitektuurimuudatust

### Mitme projekti vahel liikumine

```bash
# Projekt 1
cd ~/melior-plus-mvp
claude
# CC laeb automaatselt melior-plus-mvp PROJECT.md + CLAUDE.md

# Projekt 2 (uues terminalis)
cd ~/project-aiks
claude
# CC laeb automaatselt project-aiks PROJECT.md + CLAUDE.md
```

Iga projekt on iseseisev — oma CLAUDE.md, AGENTS.md, PROJECT.md.

### Headless review CI/CD pipeline'is

```bash
# GitHub Actions / CI skript:
./scripts/headless-review.sh \
  --tool claude \
  --mode full \
  --branch $GITHUB_HEAD_REF \
  --output review-report.json

# Kontrolli verdikti
VERDICT=$(python3 -c "import json; print(json.load(open('review-report.json'))['verdict'])")
if [ "$VERDICT" = "FAIL" ]; then
  echo "Review FAILED — blocking merge"
  exit 1
fi
```

### Kasulikud git aliased

```bash
# Lisa .gitconfig'i:
[alias]
  wt-list = worktree list
  wt-prune = worktree prune
  cx-branches = branch --list 'cx/*'
  cx-log = "!f() { git log main..cx/$1 --oneline; }; f"
```

---

*DG-VibeCoding-Framework v4.0.0 — Equal Partnership Model*
*Kasutusjuhend v1.0 — 2026-02-12*
