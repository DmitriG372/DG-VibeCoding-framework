# Reegel: Konteksti haldamine

> LLM kontekstiakna efektiivne kasutamine. Pre/post compaction protokollid.

## Probleem

Konteksti degradeerumine algab juba 50-60% akna täitumise juures. Compaction'i ajal agent kaotab detaile ja võib korrata juba tehtud tööd või lõhkuda koodi.

## Preventiivsed meetmed

### Regulaarne oleku salvestamine

Iga olulise tööploki järel (vähemalt iga 20 tool call'i — see vastab `context-monitor.js` hoogu sisendile):

1. **Kontrolli:** kas on commit'imata muudatusi?
   ```bash
   git status --short
   ```
2. **Kui jah:** `git add <konkreetsed failid>` + `git commit -m "..."`
3. **Uuenda SNAPSHOT.md**, kui projekti olek on muutunud (mis tehtud, järgmised sammud)
4. **Uuenda sprint.json** `last_updated` timestamp, kui mõni feature liikus

### Degradeerumise märgid

Kui märkad endas:
- Kordad varem öeldut
- Ei mäleta, mida sessiooni alguses tehti
- Segadusse ajavad failid või projekti struktuur
- Tahad korrata juba tehtud tööd

**Kohe:**
1. Loe `.claude/SNAPSHOT.md` (kui olemas)
2. Loe `PROJECT.md`
3. Loe `sprint/sprint.json` — eriti `current_feature` ja status
4. `git log --oneline -20` — taasta krooonoloogia
5. Kui see ei aita — käivita `/context-refresh`

> Vastab `execution-integrity.md` Rule 6 (Session Health Check) — kui health check näitab probleemi, kasuta seda taasteketi.

### Ära kogu commit'imata muudatusi

Suur kogus commit'imata muudatusi = suur risk compaction'i ajal kaotada. Commit'i tihti, atomaarselt.

## Pre-compaction protokoll

Enne compaction'it käivitub automaatselt `hooks/pre-compact.js`, mis teeb:

1. **`git add -u` + commit** tracked muudatuste jaoks (untracked faile EI lisata teadlikult — turvalisus)
2. **Uuendab timestamp'i** SNAPSHOT.md-s
3. **Repo_access kontroll** (v7.1+): kui re­žiim on `public` või `private-shared`, EI commit'i raamistiku faile (`.claude/`, `sprint/`, `manifest.md`, `CLAUDE.md`, `AGENTS.md`)

**Mida hook EI tee** (sinu vastutus rakkenduses):
- Ei uuenda SNAPSHOT.md sisukaid sektsioone (Mis tehtud, Mis ootel, Järgmised sammud)
- Ei lisa uusi untracked faile
- Ei lahenda merge konflikte

Seega uuenda SNAPSHOT.md **enne** compaction'it — regulaarsete commit'ide raames (iga 20 tool call'i). Kui agent uuendab SNAPSHOT'i jooksvalt, hook lihtsalt fikseerib viimase oleku.

## Post-compaction protokoll

Pärast compaction'it käivitub automaatselt `hooks/context-reload.js`, mis:

1. Kuvab git context'i (HEAD, status, viimased commitid)
2. **(v7.1+)** Kuvab `.claude/SNAPSHOT.md` sisu, kui olemas
3. Toob esile, kas on commit'imata muudatusi

**Sinu sammud pärast compaction'it:**

1. **Loe taastatud SNAPSHOT.md** ja sprint.json — taasta arusaam olekust
2. **`git log --oneline -10`** — kontrolli kronoloogiat (kuigi context-reload juba näitas)
3. **Ära alusta uut tööd**, kuni kontekst on taastatud
4. Kui taasloodud kontekst ei vasta sinu eelmisele arusaamisele — käivita `/context-refresh`

## Reegel pikkadele sessioonidele

Töötamisel > 30 min:
- **Iga 15 min:** commit + SNAPSHOT update
- **Enne iga suurt task'i:** kontrolli SNAPSHOT.md värskust
- **Pärast iga agendi käivitamist:** täielik tsükkel (commit + SNAPSHOT update + sprint.json update) — vt `delegation.md`

## Konteksti eelarve

Vt `vibecoding/SKILL.md`:
- Iga plaanile lisatud samm tarbib konteksti jälgimiseks
- Eelista 3-sammulist plaani 7-sammulisele
- `execution-integrity.md` Rule 1: max 5 sammu plaanis
- Pärast compaction'it loe alati sprint.json enne jätkamist
