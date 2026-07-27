# Reegel: Konteksti haldamine

> LLM kontekstiakna efektiivne kasutamine. Pre/post compaction protokollid.

## Probleem

Konteksti degradeerumine algab juba 50-60% akna täitumise juures. Compaction'i ajal agent kaotab detaile ja võib korrata juba tehtud tööd või lõhkuda koodi.

## Preventiivsed meetmed

### Regulaarne oleku salvestamine

Iga olulise tööploki järel või `context-monitor.js` hoiatuse korral:

1. **Kontrolli:** kas on commit'imata muudatusi?
   ```bash
   git status --short
   ```
2. **Uuenda `.claude/SNAPSHOT.md`**, kui projekti olek on muutunud (mis tehtud,
   järgmised sammud). See jääb alati lokaalseks.
3. **Uuenda ja valideeri `sprint.json`**, kui mõni feature päriselt liikus.
4. Commit'i ainult aktiivse töövoo ja kasutaja antud Git-volituse järgi;
   compaction ise ei anna commit'i tegemiseks luba.

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
4. `git log --oneline -20` — taasta kronoloogia
5. Kui see ei aita — käivita `/context-refresh`

> Vastab `execution-integrity.md` Rule 6 (Session Health Check) — kui health check näitab probleemi, kasuta seda taasteketi.

### Hoia muudatuste ulatus arusaadav

Suur segatud diff raskendab taastamist ja review'd. Hoia loogilised muudatused
eraldi ning kontrolli `git status --short`; ära tee konteksti haldamise nimel
automaatselt commit'i.

## Pre-compaction protokoll

Enne compaction'it käivitub automaatselt `hooks/pre-compact.js`, mis teeb:

1. Kirjutab lokaalse `.claude/context-snapshot.json` faili.
2. Uuendab olemasoleva lokaalse `.claude/SNAPSHOT.md` timestamp'i.
3. Salvestab lugemiseks projekti, Giti ja sprindi hetkeseisu.
4. Ei stage'i, commit'i ega push'i midagi.

Kõigis `repo_access` režiimides jäävad lokaalseks settings, logid, snapshotid
ja `manifest.md`. Tiimi juhised (`PROJECT.md`, `AGENTS.md`, `CLAUDE.md`) ning
`sprint/sprint.json` jäävad jälgitavaks.

**Mida hook EI tee** (sinu vastutus rakenduses):
- Ei uuenda SNAPSHOT.md sisukaid sektsioone (Mis tehtud, Mis ootel, Järgmised sammud)
- Ei lisa faile Git indexisse
- Ei lahenda merge konflikte

Seega uuenda SNAPSHOT.md sisulisi sektsioone **enne** compaction'it. Hook
fikseerib ainult hetkeseisu ja timestamp'i.

## Post-compaction protokoll

Pärast compaction'it käivitub automaatselt `hooks/context-reload.js`, mis:

1. Kuvab git context'i (HEAD, status, viimased commitid)
2. Kuvab `.claude/SNAPSHOT.md` sisu, kui olemas
3. Toob esile, kas on commit'imata muudatusi

**Sinu sammud pärast compaction'it:**

1. **Loe taastatud SNAPSHOT.md** ja sprint.json — taasta arusaam olekust
2. **`git log --oneline -10`** — kontrolli kronoloogiat (kuigi context-reload juba näitas)
3. **Ära alusta uut tööd**, kuni kontekst on taastatud
4. Kui taasloodud kontekst ei vasta sinu eelmisele arusaamisele — käivita `/context-refresh`

## Reegel pikkadele sessioonidele

Töötamisel > 30 min:
- **Regulaarselt:** kontrolli diffi ulatust ja uuenda lokaalset SNAPSHOT-i
- **Enne iga suurt task'i:** kontrolli SNAPSHOT.md värskust
- **Pärast iga agendi käivitamist:** valideeri tulemus, uuenda sprinti ja järgi
  `delegation.md` commit-poliitikat

## Konteksti eelarve

Vt `vibecoding/SKILL.md`:
- Iga interaktiivsele täitmisplaanile lisatud samm tarbib jälgimiskonteksti
- Hoia täitmisplaan 5–7 kõrgtaseme sammu piires; sprindi feature'i 5–10
  tehnilist dekompositsioonisammu on eraldi leping
- `execution-integrity.md` Rule 1 kirjeldab täitmisplaani, sprint-v3 skeem
  kirjeldab feature'i tööjaotust
- Pärast compaction'it loe alati sprint.json enne jätkamist
