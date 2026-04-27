---
name: finish
description: "End working session: tests, commit, SNAPSHOT update, report. Run once at session end."
triggers: ["session end", "wrapping up", "stopping for the day", "session finish"]
negative_triggers: ["feature done", "mid-session checkpoint"]
user-invocable: true
level: "1"
---

# Skill: /finish

> Sessiooni-tase. Erinev `/done`-st: `/done` lõpetab ühe feature'i (sprint.json `in_review`), `/finish` lõpetab terve sessiooni (võib hõlmata mitut feature'it ja mitut commit'i).

## Mida teha

### 1. Käivita testid (kohustuslik)

```bash
# Tuvasta projekti tüüp ja jooksuta vastav käsk
if [ -f "package.json" ]; then
  npm test 2>&1 | tail -30
elif [ -f "pnpm-lock.yaml" ]; then
  pnpm test 2>&1 | tail -30
elif [ -f "pyproject.toml" ] || [ -f "pytest.ini" ]; then
  python3 -m pytest tests/ 2>&1 | tail -30
fi
```

**KOHUSTUSLIK:** Kuva *tegelik* runner output, mitte "tests pass" (vt `execution-integrity.md` Rule 3).

Kui testid kukuvad:
1. Proovi parandada (kuni 3 katset, autonoomselt) — vt `autonomy.md` "Punased testid ≠ blocker"
2. Kui ei õnnestu: jätka commit'iga, **märgi** SNAPSHOT.md-sse "Tuntud probleemid" sektsioonis

### 2. Stub-detekt (kohustuslik)

```bash
STUB_CHECK_BLOCK=0 scripts/stub-check.sh --staged 2>&1 | tail -20
```

Kui leitakse TODO/FIXME/empty stubs — eemalda või commit'i koos teadliku märkega SNAPSHOT-i.

### 3. Git-status ja commit (commit-policy järgi)

```bash
git status --short
git diff --stat
```

Iga commit'imata faili kohta otsusta (vt `negative-constraints.md` "Never commit"):
- **Keelatud alati** (`.env`, `*.key`, `*.db`) → veendu `.gitignore`-is, kui mitte — lisa
- **Lubatud** → `git add <konkreetsed failid>` (mitte `git add -A`)
- Sõnasta kirjeldav commit message

### 4. Uuenda `.claude/SNAPSHOT.md`

Sektsioonid:
- **Mis tehtud (selles sessioonis):** lisa kanded
- **Mis ootel:** uuenda või tühjenda
- **Tuntud probleemid:** lisa, kui avastati
- **Järgmised sammud:** mida järgmises sessioonis teha
- **Last update:** uus timestamp

### 5. Commit SNAPSHOT (kui repo_access lubab)

```bash
if [ -x scripts/framework-state-mode.sh ]; then
  if [ "$(scripts/framework-state-mode.sh should-commit-framework-state)" = "true" ]; then
    git add .claude/SNAPSHOT.md
    git diff --cached --quiet || git commit -m "docs: update SNAPSHOT after session"
  else
    echo "SNAPSHOT kept local (repo_access=$(scripts/framework-state-mode.sh repo-access))"
  fi
else
  # Fallback: kui skript pole olemas, käituma nagu private-solo
  git add .claude/SNAPSHOT.md
  git diff --cached --quiet || git commit -m "docs: update SNAPSHOT after session"
fi
```

### 6. Lõpeta sessiooni-logi

Lisa `.claude/logs/sessions/YYYY-MM-DD_HH-MM.md` lõppu:
- Testide tulemused (passed/failed/skipped)
- Sessiooni commit'ide hash'id (`git log --oneline <session_start>..HEAD`)
- Avastatud probleemid
- Sessiooni kestvus

### 7. Raport kasutajale (5-7 rida)

Vorming:

```
Sessioon lõpetatud: <kuupäev/aeg>
Tehtud: <N commits>, <M features in_review/completed>
Tests: <passed/failed counts>
Branch: <branch> ([clean] / [N uncommitted - jäid sihilikult])
Järgmine: <SNAPSHOT-i Järgmised sammud esimene punkt>

Hash'id: <commit hash list>
```

## Mida MITTE teha

- **Ära `git push`** automaatselt — see on eraldi otsus, vajadusel kasuta `/housekeeping` enne push'i
- **Ära commit'i** keelatud failide nimekirjast (vt `negative-constraints.md`)
- **Ära kuluta > 2 min** finish'ile

## Kontekst

- Vahepealne checkpoint sessiooni jooksul: `context-management.md` "iga 20 tool call'i" reegel
- Feature'i lõpp: `/done` (mitte `/finish`)
- Sessiooni lõpp: `/finish` (see fail)
