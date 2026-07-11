# DG-VibeCoding-Framework v7.2.0 Plan

> **Eesmärk:** Sulgeda gap'id "Production Ready" raamatu (Mart Parve, 2026) vs framework v7.1.0 vahel.
> **Filosoofia:** Lisa puuduvad kihid (security, spec-conformance, prod safety) säilitades v7.x lihtsuse.
> **Sihtkuupäev:** 2026-05-31 (4 nädalat)
> **Allikas:** [Production Ready NLM notebook](https://notebooklm.google.com/notebook/b1e603ea-726b-47b5-b006-de494e3afdda)

---

## Sisukord

1. [Skoop ja eesmärgid](#skoop)
2. [5 puuduolevat tükki](#gaps)
3. [Konkreetsed failimuudatused](#changes)
4. [Migratsiooni-strateegia](#migration)
5. [Testimine](#testing)
6. [Out of scope (v8.0)](#future)

---

## Skoop {#skoop}

**v7.2 = additive release** — ei murra v7.1 projekte. Kõik uued komponendid on opt-in läbi `framework.json` flag'ide.

**Versiooni reegel:** v7.2 = uued skill'id/commandid + hookid. Kui breaking → v8.0.

**Mõõdik:** uued projektid genereeritud `setup-project.sh` abil sisaldavad kõik 5 uut komponenti vaikimisi.

---

## 5 puuduolevat tükki {#gaps}

### Gap 1: EARS-formaadis spec'id (raamat ptk 6)
**Probleem:** PROJECT.md on freeform → agent võib spec'i tõlgendada erinevalt.
**Lahendus:** `.claude/specs/<feature>.md` EARS-syntax acceptance criteria'tega.

### Gap 2: Security validation kiht (raamat ptk 11, 15)
**Probleem:** Hookid katavad types/format/tests, aga mitte security.
**Lahendus:** `hooks/security-scan.js` Semgrep integratsiooniga.

### Gap 3: Spec-conformance check (raamat ptk 11)
**Probleem:** Tester agent kontrollib testide läbimist, mitte spetsile vastavust.
**Lahendus:** `spec-validator` agent + `.claude/skills/spec-validation/` skill.

### Gap 4: Production safety net (raamat ptk 13, 15)
**Probleem:** `/done` annab koodi valmis, edasine prod-deploy on käsitsi.
**Lahendus:** `production-safety` skill + `prod-deploy-checklist.md` rules.

### Gap 5: Cost tracking täpsem (raamat ptk 16)
**Probleem:** `usage-tracker.js` registreerib, aga ei optimeeri.
**Lahendus:** `cost-budget.js` hook + `framework.json` budget field.

---

## Konkreetsed failimuudatused {#changes}

### A. Uued skill'id (3)

#### A.1 `.claude/skills/spec-formalization/SKILL.md`
- Triggerid: kui agent saab freeform feature request'i
- Output: `.claude/specs/<feature-id>.md` EARS-formaadis
- Template: WHEN/WHILE/WHERE/THE SYSTEM SHALL pattern
- Auto-link sprint.json `features[].spec_path`

#### A.2 `.claude/skills/spec-validation/SKILL.md`
- Triggerid: enne `/done` käivitamist
- Action: võrdle implementatsioon spec'i acceptance criteria'tega
- Output: pass/fail iga AC kohta + concrete evidence
- Bloki `/done` kui fail

#### A.3 `.claude/skills/production-safety/SKILL.md`
- Triggerid: kui kasutaja mainib "deploy", "prod", "release"
- Checklist: feature flag? rollback plan? monitoring? smoke test?
- Refuses to proceed kui checklist incomplete

### B. Uued commandid (2)

#### B.1 `.claude/commands/spec.md`
```
/spec [feature-id]   → loo EARS-spec failina
/spec validate       → kontrolli implementation vs spec
/spec list           → näita kõik specid
```

#### B.2 `.claude/commands/security-scan.md`
```
/security-scan         → Semgrep + dependency audit
/security-scan deep    → + Snyk + secrets scan
```

### C. Uued hookid (3) → kokku 16

#### C.1 `hooks/security-scan.js` (PostToolUse: Edit|Write)
- Käivita Semgrep `--config=auto` muudetud failidel
- High severity → block commit (exit 2)
- Medium → warning logi `.claude/security.log`-i
- Low → silent

#### C.2 `hooks/spec-conformance.js` (UserPromptSubmit kui ":done" mainitud)
- Loe `sprint.json` current_feature.spec_path
- Loe spec'i AC'd
- Reminder agendile: "Enne /done kontrolli AC: [list]"

#### C.3 `hooks/cost-budget.js` (Stop)
- Loe `usage-tracker.js` output
- Võrdle `framework.json.budgets.{daily,sprint}` vastu
- 80% → warning, 100% → suggesteerib `/handoff` CX-ile (odavam)

### D. Uued agendid (1) → kokku 7

#### D.1 `.claude/agents/spec-validator.md`
- Frontmatter: `model: haiku` (kiire, odav AC matching)
- Input: spec.md path + implementation files
- Output: structured JSON pass/fail per AC + evidence quote

### E. Uued reeglid (1) → kokku 7

#### E.1 `.claude/rules/deployment-safety.md`
- 5 kohustuslikku punkti enne prod deploy:
  1. Feature flag wrap (LaunchDarkly/GrowthBook/env var)
  2. Rollback plan dokumenteeritud
  3. Monitoring alert konfigureeritud (Sentry)
  4. Smoke test käivitatud staging'is
  5. PR approved (mitte ainult agent peer-review)

### F. framework.json laiendused

```json
{
  "version": "7.2.0",
  "features": {
    "ears_specs": true,
    "security_scan": true,
    "spec_conformance": true,
    "production_safety": true,
    "cost_budget": true
  },
  "budgets": {
    "daily_usd": 5.00,
    "sprint_usd": 30.00,
    "warn_at_pct": 80
  },
  "security": {
    "tool": "semgrep",
    "config": "auto",
    "block_on": "high"
  },
  "specs": {
    "format": "ears",
    "path": ".claude/specs"
  }
}
```

### G. Template laiendused

#### G.1 `templates/project-init/.claude/specs/.gitkeep`
- Tühi kaust spec'idele

#### G.2 `templates/spec.template.md`
- EARS-formaadis spec template
- Acceptance criteria sektsioon
- Non-functional requirements sektsioon

#### G.3 `templates/sprint.template.json` muudatus
- Feature objektile lisada: `spec_path`, `spec_validated_at`

---

## Migratsiooni-strateegia {#migration}

### v7.1 → v7.2 update flow (`migrate-project.sh`)

```bash
./migrate-project.sh /path/to/project --from 7.1 --to 7.2
```

Sammud:
1. Backup `.claude/` → `.claude.backup-v7.1/`
2. Lisa uued failid (3 skill, 2 command, 3 hook, 1 agent, 1 rule)
3. Update `framework.json` versioon → "7.2.0", lisa `features` flag'id
4. Update `sprint.json` schema (lisa `spec_path` field, default null)
5. Update `.claude/settings.local.json` hookide registreerimine
6. Käivita `tests/framework-consistency.sh`

### Backwards compatibility

- Kõik uued features = opt-in läbi `framework.json.features.*`
- Vanad projektid v7.1.0 töötavad ilma migrate'imata
- Spec validation võib bypass'ida `/done --skip-spec-check` flag'iga

---

## Testimine {#testing}

### tests/framework-consistency.sh laiendus
- Kontrolli et VERSION fail = framework.json.version = README.md badge
- Kontrolli et kõik 16 hooki on settings.template.json'is

### Uued testid:
- `tests/spec-formalization.test.sh` — genereeri EARS spec, validate
- `tests/security-hook.test.sh` — eval test SQL injection muster, kontrolli block
- `tests/migration-7.1-to-7.2.test.sh` — täielik migration roundtrip

### Manual smoke test:
1. `./setup-project.sh /tmp/test-v72`
2. `/feature add-login` → genereerib spec.md
3. Implementeeri → `hooks/security-scan.js` käivitub
4. `/spec validate` → AC pass/fail
5. `/done` → blokeeritud kui spec fail
6. `/done --skip-spec-check` → läheb läbi koos warning'iga

---

## Out of scope — v8.0 kandidaadid {#future}

Need olid raamatus aga jätame v8.0-le:

1. **Firecracker microVM sandboxing** (raamat ptk 9) — vajaks Docker/Linux infra, macOS-il keeruline
2. **OpenRewrite deterministic refactoring** (raamat ptk 10) — Java-keskne, ei sobi Python/JS workflow'iga
3. **Headless event-driven cloud factory** (raamat ptk 2) — vajaks GitHub Actions / Vercel cron pipeline
4. **Visual regression testing** (Percy/Chromatic) — projekti-spetsiifiline, ei kuulu framework'i
5. **Spec-Factory tagasitulek** (orchestrator-driven) — equal partnership mudel võitis v4.0+

---

## Implementatsiooni järjekord (4 nädalat)

| Nädal | Fookus | Deliverable |
|-------|--------|-------------|
| W1 (2026-05-04 → 05-10) | Spec formalization | A.1, B.1, G.1, G.2 |
| W2 (2026-05-11 → 05-17) | Security + spec validation | A.2, B.2, C.1, C.2, D.1 |
| W3 (2026-05-18 → 05-24) | Production safety + cost | A.3, C.3, E.1, F |
| W4 (2026-05-25 → 05-31) | Migration + testing + release | migrate-project.sh, tests/, README/CHANGELOG |

---

## Validation against book

Pärast v7.2 release küsi NLM-ist:

```
nlmq production-ready "Kui mul oleks framework järgmiste komponentidega:
- EARS-specs .claude/specs/
- Semgrep security hook
- spec-validator agent (Haiku)
- production-safety skill (5-punkti checklist)
- cost-budget hook
mis 3 olulist asja oleks veel puudu vs raamatu kooditehasest?"
```

→ Vastus → v8.0 plaan

---

## Seosed

- Vault: [[2026-05-04_Production_Ready_AI_Code_Factory]]
- Framework: `~/_VibeCoding/_tools/DG-VibeCoding-framework/README.md`
- NLM: production-ready (alias)
- Repo: [martparve/production-ready](https://github.com/martparve/production-ready)
