---
name: housekeeping
description: "Project tidy-up before push: README/CHANGELOG drift, .gitignore audit, SNAPSHOT timestamp, sprint.json validation."
triggers: ["before push", "housekeeping", "project tidy", "drift check", "korras"]
negative_triggers: ["code change", "feature work"]
user-invocable: true
level: "2"
---

# Skill: /housekeeping

> Käivitub **kohustuslikult enne `git push`** ja kasutaja päringul. Kontrollib ja korrastab kõik metafailid, mis võivad olla aegunud.

## Mida kontrollida

### 1. README.md drift

```bash
# Kas viimane README muudatus on enne viimast oluliste failide muudatust?
git log -1 --format="%at" README.md
git log -1 --format="%at" -- src/ lib/ app/ pages/ 2>/dev/null
```

Loe README.md ja võrdle reaalse projekti seisuga:

- **Projekti kirjeldus** — vastab tegelikule funktsionaalsusele?
- **Install:** käsud (`npm install`, `pip install`) on õiged?
- **Usage / API:** kirjeldatud endpoint'id, käsud, funktsioonid eksisteerivad koodis?
- **Näited:** kas toimivad?

Kui aegunud — uuenda automaatselt. Ära küsi kasutajalt.

### 2. CHANGELOG.md (kui olemas)

```bash
# Vali viimane versioon CHANGELOG-ist
LAST_VERSION=$(grep -m1 -oE '\d+\.\d+\.\d+' CHANGELOG.md 2>/dev/null | head -1)
if [ -n "$LAST_VERSION" ]; then
  git log --oneline "v${LAST_VERSION}"..HEAD 2>/dev/null
fi
```

Kui leiti undokumenteeritud commit'e — lisa CHANGELOG.md-sse uus sektsioon ("Added", "Changed", "Fixed", "Removed" — Keep a Changelog format).

Kui CHANGELOG.md puudub ja projektis on > 10 commit'it — loo see.

### 3. Versiooni bump

```bash
[ -f package.json ] && grep '"version"' package.json | head -1
[ -f pyproject.toml ] && grep '^version' pyproject.toml
```

Kontrolli, kas muudatused vajavad version bump'i:
- Breaking changes (uued/eemaldatud API-d, signature muutused) → minor või major
- Ainult bug fixed → patch

Uuenda numbrit, **ära publish'i**.

### 4. .gitignore audit

```bash
# Otsi tracked failid, mis peaksid olema gitignore'is
git ls-files | grep -E '\.(env|key|pem|db|sqlite|sqlite3)$' && echo "BLOCKER"
git ls-files | grep -E '^(node_modules|__pycache__|dist|build|\.next|\.vercel)/' && echo "BLOCKER"
git ls-files | grep -E '\.DS_Store$' && echo "WARNING"
```

Kui leidub:
1. `git rm --cached <fail>` — eemalda indeksist
2. Veendu, et muster on `.gitignore`-is
3. Lisa kui puudub

### 5. SNAPSHOT.md ja sprint.json valideerimine

```bash
# Kontrolli SNAPSHOT.md timestamp'i
[ -f .claude/SNAPSHOT.md ] && grep "Last update" .claude/SNAPSHOT.md

# Valideeri sprint.json dependency-free frameworki validaatoriga
if [ -f sprint/sprint.json ]; then
  node scripts/validate-sprint.js sprint/sprint.json
fi
```

Kui SNAPSHOT.md timestamp on enne viimase sessiooni-commit'i — uuenda seda
lokaalselt, kuid ära stage'i ega commit'i.

### 6. Repo-access ohutus

```bash
[ -x scripts/framework-state-mode.sh ] && scripts/framework-state-mode.sh check-safe-mode
```

Kui väljub kood 2 — STOP: mõni alati lokaalne fail (settings, notebook,
SNAPSHOT, logi või `manifest.md`) on endiselt tracked. Käivita
`scripts/switch-repo-access.sh <mode>`; tiimi juhised ja sprint jäävad tracked.

### 7. Manifest täielikkus

```bash
if [ -f manifest.md ]; then
  grep -q "^project_name=" manifest.md || echo "MISSING: project_name"
  grep -q "^repo_access=" manifest.md || echo "MISSING: repo_access"
fi
```

Kui puudub — täida automaatselt:
- `project_name`: `basename "$(pwd)"`
- `repo_access`: `private-solo` kui pole ühtegi `git remote`, muidu `public` kui remote sisaldab "github.com" + projekt on public, muidu `private-solo`

## Millal käivitada

- **Enne `git push`** — agent peab seda käsitsi kutsuma (ei ole automaatne hook)
- **Kasutaja päring:** "tee korda", "housekeeping", "drift check"
- **`/finish` lõpus**, kui session lõpeb push'iga

## Mida MITTE teha

- **Ära muuda projekti koodi** — ainult dokumentatsiooni ja metafailid
- **Ära `git push`** automaatselt
- **Ära kustuta** kasutaja faile
- **Ära kuluta > 3 min** housekeeping'ile

## Raport (5-7 rida)

```
Housekeeping valmis:
- README: [up-to-date | uuendatud]
- CHANGELOG: [N undocumented commits added | up-to-date | not present]
- .gitignore: [clean | N files removed from tracking]
- SNAPSHOT: [fresh | uuendatud lokaalselt]
- Repo-access: <mode> [safe | BLOCKER message]

Valmis push'iks: yes / no (<põhjused>)
```
