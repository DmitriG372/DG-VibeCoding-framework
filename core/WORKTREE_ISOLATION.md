# Git Worktree Isolation

Turvaline arenduspraktika, mis hoiab eksperimentaalse koodi eraldi main harust.

Inspireeritud: Auto-Claude git worktrees pattern.

## Miks Worktree?

| Probleem | Worktree lahendus |
|----------|-------------------|
| Poolik kood main harus | Isoleeritud branch |
| Konfliktid meeskonnaga | Oma worktree |
| Kartus katsetada | Turvaliselt eraldi |
| Raske rollback | Lihtsalt kustuta worktree |

## Põhimõte

```
main branch (puhas, stabiilne)
     │
     ├── .worktrees/
     │   ├── feature-auth/        ← worktree 1
     │   ├── experiment-cache/    ← worktree 2
     │   └── bugfix-login/        ← worktree 3
```

## Kasutamine

### 1. Uue Feature Alustamine

```bash
# Loo worktree uue feature jaoks
git worktree add .worktrees/feature-name -b feature/feature-name

# Mine worktree kausta
cd .worktrees/feature-name

# Tööta seal (Claude Code töötab siin)
```

### 2. Töötamine Worktrees

```bash
# Worktree on täielik git repo
git status
git add .
git commit -m "WIP: feature progress"

# Push branch (kui soovid)
git push -u origin feature/feature-name
```

### 3. Feature Valmis - Merge

```bash
# Mine tagasi main harusse
cd ../..  # projekti juurkausta

# Merge feature branch
git merge feature/feature-name

# Või loo PR
gh pr create --base main --head feature/feature-name
```

### 4. Cleanup

```bash
# Eemalda worktree
git worktree remove .worktrees/feature-name

# Kustuta branch (kui ei ole vaja)
git branch -d feature/feature-name
```

## Framework Integratsioon

### Automaatne Worktree Loomine

Lisa `.claude/commands/` kausta:

```yaml
# feature-worktree.md
1. Kontrolli, kas .worktrees/ kaust eksisteerib
2. Loo worktree: git worktree add .worktrees/{name} -b feature/{name}
3. Uuenda cwd worktree'sse
4. Jätka tööga isoleeritult
```

### Sprint Mode + Worktree

```yaml
# Kui sprint-init käivitub:
1. Loo worktree sprint nimega
2. Kogu töö toimub worktrees
3. /done merge'ib tagasi main harusse
```

## Soovitused

### Millal Kasutada

| Kasuta worktree't | Ära kasuta |
|-------------------|------------|
| Eksperimentaalne feature | Väike fix (< 5 rida) |
| Refactoring | Dokumentatsiooni muudatus |
| Pikaajaline töö | Hotfix (otse main) |
| Meeskonnas töö | Solo quick change |

### Nimetamine

```
.worktrees/
├── feat-user-auth       # Feature
├── fix-login-bug        # Bugfix
├── exp-new-cache        # Experiment
├── refactor-api         # Refactoring
└── sprint-2025-01       # Terve sprint
```

### .gitignore

Lisa projekti `.gitignore`:

```
# Worktrees (ära commit'i worktree kausta)
.worktrees/
```

## Käsurida Cheatsheet

| Käsk | Kirjeldus |
|------|-----------|
| `git worktree list` | Näita kõik worktree'd |
| `git worktree add <path> -b <branch>` | Loo uus |
| `git worktree remove <path>` | Eemalda worktree |
| `git worktree prune` | Puhasta katkised lingid |

## Töövoog Diagramm

```
┌─────────────────────────────────────────────────────────────┐
│                         MAIN BRANCH                          │
│                    (puhas, stabiilne kood)                   │
└─────────────────────────────────────────────────────────────┘
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│  .worktrees/  │  │  .worktrees/  │  │  .worktrees/  │
│  feat-auth    │  │  fix-bug      │  │  exp-cache    │
│               │  │               │  │               │
│ [development] │  │ [development] │  │ [development] │
└───────┬───────┘  └───────┬───────┘  └───────────────┘
        │                  │                  │
        ▼                  ▼                  ✕ (discard)
    ┌───────┐          ┌───────┐
    │ MERGE │          │ MERGE │
    └───────┘          └───────┘
        │                  │
        ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│                         MAIN BRANCH                          │
│                      (uuendatud kood)                        │
└─────────────────────────────────────────────────────────────┘
```

## Probleemide Lahendamine

### Worktree ei lähe kustutama

```bash
# Force remove
git worktree remove --force .worktrees/name
```

### Branch on locked

```bash
# Prune stale worktrees
git worktree prune
```

### Worktree kadunud

```bash
# Vaata mis juhtus
git worktree list

# Kui path on vale, prune
git worktree prune
```

---

*Part of DG-VibeCoding-Framework v2.5*
*Inspired by Auto-Claude worktree isolation pattern*
