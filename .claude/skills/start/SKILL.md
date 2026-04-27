---
name: start
description: "Initialize a working session: load project state, assess readiness, report. Run once per session."
triggers: ["session start", "begin work", "what's the state", "where are we"]
negative_triggers: ["mid-session", "after compaction", "switching feature"]
user-invocable: true
level: "1"
---

# Skill: /start

> Sessiooni-tase. Erinev `/feature`-st: `/feature` valib feature'i, `/start` valmistab sessiooni ette. Käivita kord sessiooni alguses.

## Mida teha

### 1. Loe projekti kontekst (paralleelselt)

```
Read PROJECT.md
Read sprint/sprint.json
Read .claude/SNAPSHOT.md   # kui olemas
```

Kui `SNAPSHOT.md` puudub — loo see `templates/SNAPSHOT.md.template` põhjal koos tänase kuupäevaga.

### 2. Kontrolli git-olek

```bash
git status --short
git log --oneline -5
git branch --show-current
```

### 3. Loo sessiooni-logi (kui võimalik)

```bash
mkdir -p .claude/logs/sessions
SESSION_LOG=".claude/logs/sessions/$(date +%Y-%m-%d_%H-%M).md"
```

Kirjuta logifaili algne sissekanne:
- Timestamp
- SNAPSHOT staatus (loetud / loodud / tühi)
- Git status (clean / N uncommitted)
- Active feature (sprint.json `current_feature`)
- Repo access mode (kui `manifest.md` olemas, vt `scripts/framework-state-mode.sh`)

### 4. Doll kasutajale (lühidalt, 3-5 rida)

Vorming:

```
Sessioon avatud: <kuupäev/aeg>
Branch: <branch> | <N> uncommitted
Sprint: <sprint_id>, <X>/<Y> features completed
Active feature: <F-ID> <name> (<status>) — <assigned_to>
Last session ended: <SNAPSHOT.md "Last update" timestamp>

Valmis tööks. Mis on tänase ülesanne?
```

## Mida MITTE teha

- **Ära käivita teste** — see on `/finish` ülesanne
- **Ära commit'i** — kui on uncommitted, raporteeri kasutajale, ära ise sea ette
- **Ära alusta tööd** — oota kasutajalt ülesannet
- **Ära kuluta > 30 sek** initsialiseerimisele

## Pärast

Agent on valmis vastu võtma ülesannet. Tüüpiliselt järgneb:
- Kasutaja annab ülesande → vastavalt sellele võib käivituda `/feature`, `/orchestrate`, `/fix` vms
- Või kasutaja ütleb "jätka" → loe `current_feature` ja jätka selle kallal

## Kontekst

`/start` ↔ `/finish` ümbritsevad sessiooni. `/feature` ↔ `/done` ümbritsevad ühe feature'i (tihti mitu sessiooni jooksul).
