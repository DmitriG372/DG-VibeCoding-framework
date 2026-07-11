# Claude Code Rules — projekt

> **Globaalne Operating Protocol:** `~/.claude/CLAUDE.md` — sama 5 reeglit, mis kehtivad iga sessioonis.
> **Projekti reeglid:** `PROJECT.md` (IMMUTABLE) | **Sprint olek:** `sprint/sprint.json` (MUTABLE).
> **Detailsed reeglid:** `EXECUTION_PROTOCOL.md` (delegatsioon, autonoomia, prod-safety, negatiivsed piirangud).

## Loading (sessiooni alguses)

1. `PROJECT.md` — stack, patterns, conventions
2. `sprint/sprint.json` — features, oma assigned_to staatus
3. `EXECUTION_PROTOCOL.md` — kui projektil on lokaalsed erandid globaalsest

## The 5 Rules — projekti tasandile mapitud

### 1. Decompose
Mitte-triviaalne feature peab `sprint.json`-is sisaldama:
- `description` (goal — üks lause)
- `acceptance_criteria` (mõõdetav siht)
- `steps` (5–10 alamosa)

`decomposition-guard.js` hook blokeerib `Edit/Write/MultiEdit` aktiivsel feature'il, kui `steps` puudub või on tühi ja `trivial != true`.

### 2. Surface uncertainty
Eeldused → `feature.notes`. Hägused nõuded → küsi enne kui jätkad. Ära fabritseeri (vt `EXECUTION_PROTOCOL.md` Rule 3 — evidence-based completion).

### 3. Simplicity
Minimaalne kood mis lahendab. Ei service layer'eid, ei factory'sid, ei "tuleviku-kindlustust" kui feature ei küsi. Kolm sarnast rida > enneaegne abstraktsioon.

### 4. Surgical
Iga muudetud fail peab kuuluma aktiivse feature `corridor.allowed` mustrisse. `scope-guard.js` hook hoiatab Edit/Write hetkel, kui fail langeb `corridor.forbidden` alla või on väljaspool `corridor.allowed`.

### 5. Goal-driven
Enne kodeerimist: defineeri `acceptance_criteria`. Enne `/done`: verifitseeri iga kriteerium (käivita testid, näita output — `EXECUTION_PROTOCOL.md` Rule 3).

## Contracts

Inter-agent: JSON sprint.json kaudu. Inimesele: markdown/text.

## Identity

- `CLAUDE.md` entry → CC, branch prefix `cc/`
- `AGENTS.md` entry → CX, branch prefix `cx/`

## References

- `EXECUTION_PROTOCOL.md` — execution integrity, negative constraints, autonomy, delegation, prod safety
- `framework.json#core.hooks_critical` — kriitilised hookid (decomposition-guard, scope-guard, completion-guard)
- Hooks/skills/commands — vt `framework.json`
