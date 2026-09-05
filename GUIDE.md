# DG-VibeCoding-Framework v9.0.0 — Kasutusjuhend

## 1. Komponendid

| Komponent | Arv | Roll |
|---|---:|---|
| Leping   | 1 | `AGENTS.md` — jagatud käitumisleping, alla 150 rea |
| Commands | 4 | `/done`, `/review`, `/handoff`, `/sprint` |
| Agents   | 2 | `reviewer`, `debugger` |
| Hooks    | 5 | Ainult pöördumatute tegevuste guardrail'id |

Invariant: **kõik, mida agent peab teadma, on `AGENTS.md`-is.** Codex loeb seda
natiivselt; `CLAUDE.md` algab `@AGENTS.md` impordiga ja lisab alla ainult
Claude'i-spetsiifilised mugavused. Jagatud lähtefail väldib juhiste lahknemist. `tests/parity.test.js` kontrollib
importe ja seadistuste vastavust; see ei tõesta hookide käivitumist mõlema
paigaldatud runtime’i versioonis.

Framework ei paigalda `.claude/rules/` ega `.claude/skills/` sisu: Codex ei loe
kumbagi, seega ei tohi kummaski olla midagi vajalikku.

## 2. Uue projekti loomine

```bash
/path/to/DG-VibeCoding-framework/setup-project.sh /path/to/new-project
cd /path/to/new-project
```

Setup töötab vaikimisi ainult tühjas kaustas. Olemasolevate framework-failide
asendamine nõuab `--force`; enne kirjutamist luuakse ajatempliga backup.

Täida pärast setup'i:

1. `PROJECT.md` — päris stack, struktuur, käsud ja konventsioonid.
2. Initsialiseeri Git, kui projekt ei ole veel repository.
3. Alusta tööd.

`AGENTS.md` ja `CLAUDE.md` tulevad frameworkilt valmis kujul. Projektispetsiifiline
info kuulub `PROJECT.md`-i, mitte juhisefaili.

## 3. Vaiketsükkel

```text
mõista → muuda minimaalselt → jooksuta kitsaim päris kontroll → näita tõendit
```

Väike töö ei vaja sprinti ega eraldi plaani. Alusta Giti seisust ja säilita olemasolevad
muudatused. Kasuta projekti päris kontrollkäske ning korda kontrolli siis, kui selle
sisend muutus. Veaparandusega lisa enne parandust ebaõnnestuv regressioonikontroll.
Sprindi olemasolul võib ülesande lõppseisu lisada parandusega samasse commit’i.
Peatu ainult `AGENTS.md` sektsioonis `## Approval gates` loetletud juhtudel:
production deploy, hävitavad Git- või DB-operatsioonid, uus sõltuvus, väline
kirjutamine. Juba antud luba kehtib selle ulatuses; ära küsi seda iga sammu eel uuesti.

## 4. Sprint on valikuline

`sprint/sprint.json` ei paigaldata ega nõuta. See eksisteerib ainult siis, kui
CC ja CX töötavad paralleelselt.

```json
{ "schema_version": 4, "base_branch": "dev", "updated": "…",
  "tasks": [{ "id": "T1", "title": "…", "assigned_to": "cx",
              "status": "in_progress", "branch": "cx/t1-slug" }] }
```

```bash
node scripts/validate-sprint.js sprint/sprint.json
```

Viis välja ülesande kohta. `status` ∈ `planned` | `in_progress` | `in_review` |
`done`. Tundmatuid võtmeid valideerija ignoreerib — range leping maksis varem
ainult töötunde, kui käsitsi muudetud fail lakkas valideerumast.

## 5. Paralleelne CC + CX töö

```text
CC: /handoff T1
    → ülesanne valideeritakse ja commit'itakse
    → cx/t1-... worktree luuakse sellest commit'ist
CX: cd <worktree> && codex --sandbox workspace-write
```

Handoff nõuab uut harunime ja vaba sihtkausta; konflikt tuvastatakse enne commit’i.

Ära käivita kahte agenti samas checkout'is. Git hoiab ühes tööpuus korraga
ainult üht harul. Merge on alati kasutaja otsus.

## 6. Review

```text
/review                 # reviewer subagent, värske kontekst
/review src/            # kitsam skoop
```

```bash
scripts/headless-review.sh --tool claude --mode quick --staged
scripts/headless-review.sh --tool codex --mode full src/ --output review.json
```

Raporteeri ainult leiud, mis mõjutavad korrektsust või püstitatud nõuet.
Reviewer, kellel kästakse leida puudusi, leiab neid alati; iga leiu jahtimine
toodab kaitsvat koodi ja teste olukordadele, mida ei saa juhtuda.

## 7. Turvaskann

Codex Security on valikuline, teadlikult käivitatav pre-merge kontroll. Kasuta
seda siis, kui muudatus puudutab autentimist, õiguseid, avalikke API-sid,
üleslaadimisi, makseid, saladusi või andmebaasi ligipääsu. See ei ole pre-commit
hook ega testsuite'i või tavareview asendus.

Paigalda CLI ainult organisatsiooni heakskiidetud kanali kaudu. Frameworki
skript ei lisa projekti npm-sõltuvust, ei loe võtmeid projektifailidest ning
salvestab tulemused repovälisesse privaatse õigustega kausta:

```bash
CODEX_SECURITY_BIN=/approved/path/codex-security \
  scripts/security-scan.sh --working-tree --dry-run

CODEX_SECURITY_BIN=/approved/path/codex-security \
  scripts/security-scan.sh --diff origin/main --mode standard
```

Alusta CI-s advisory-režiimis. Pärast sobiva baastaseme saavutamist lisa PR-i
skannile `--fail-on-severity high`. Hoia CI võti ainult skannisammu
keskkonnamuutujas, paigalda CLI ajutisse repovälisesse kausta ning säilita
JSON/SARIF tulemusi lühikese retention'iga. Vajaduste ja autentimise kohta vaata
[CLI kiirstarti](https://learn.chatgpt.com/docs/security/cli) ning
[CI juhendit](https://learn.chatgpt.com/docs/security/cli/ci).

## 8. Migratsioon 4.x–8.x → v9

```bash
./migrate-to-v9.sh /path/to/project --dry-run
./migrate-to-v9.sh /path/to/project
```

Migratsioon:

- teeb täieliku backup'i enne midagi muutmist;
- eemaldab pensionile saadetud masinavärgi **nime järgi** — 7 reeglifaili,
  8 skilli, 9 käsku, 4 agenti, 10 hooki, `EXECUTION_PROTOCOL.md`, `HOOKS.md`,
  `.tasks/`;
- säilitab projekti enda skillid, agendid, käsud, hookid ja settings'id;
- eemaldab pensionil hookide wiring'u mõlemast settings-failist;
- asendab triivinud `AGENTS.md` / `CLAUDE.md` v9 lepinguga (originaalid backup'is);
- arhiveerib mittevastava sprint-faili, ei püüa seda konverteerida;
- keeldub töötamast git worktree sees.

Pärast migratsiooni: vaata `<backup>/CLAUDE.md` üle ja tõsta seal olnud
projektifaktid `PROJECT.md`-i.

## 9. Repo access

`repo_access` on lokaalne poliitika, mitte põhjus peita tiimilt arenduslepingut.
`PROJECT.md`, `AGENTS.md`, `CLAUDE.md`, frameworki runtime ja `sprint/sprint.json`
jäävad kõigis režiimides trackituks. Ignoreeritud on lokaalsed settings'id,
logid, credentials, environment failid, andmebaasid ja build output.

```bash
scripts/switch-repo-access.sh private-solo
scripts/switch-repo-access.sh private-shared
scripts/switch-repo-access.sh public
```

## 10. Hookide käitumine

| Hook | Sündmus | Mida teeb |
|---|---|---|
| `block-env` | PreToolUse `Read\|Grep` | Blokeerib (exit 2) secret-failid. Matchib failinime ja tervete teekomponentide järgi, seega `password-reset.ts` on loetav. |
| `completion-guard` | PreToolUse `Bash` | Kontrollib staged koodis stub'e ainult `git commit` puhul. |
| `git-context` | SessionStart | Näitab Giti hetkeseisu. |
| `pre-compact` | PreCompact | Salvestab PROJECT.md jaotiste sisu; ei muuda käsitsi kirjutatud mälu ajatemplit. |
| `context-reload` | SessionStart `compact` | Kasutab ainult sama sessiooni hetktõmmist; Giti seis loetakse uuesti. |

**Ükski hook ei käivitu muutmisel.** Typecheck ja formatter kuuluvad
projekti dokumenteeritud kontrollidesse või CI-sse; ära eelda `make pre-commit` olemasolu. `tests/parity.test.js` kukub läbi, kui hook seotakse `Edit`/`Write`/
`apply_patch` matcheriga.

Hookid on guardrail'id, mitte täielik turvasandbox.

## 11. Verifitseerimine

```bash
bash tests/run.sh
```

Täiskomplekt kontrollib:

- CC/CX pariteeti — identne hook-komplekt, import, lepingu pikkus, sektsioonid;
- sprindi valideerimist ja skeemi v4;
- hookide käitumist, sh secret-matcheri valepositiivseid;
- setup artefakti täielikkust ja seda, et rules/skills ei paigaldata;
- migratsiooni säilitavust ja worktree-keeldu;
- worktree handoff'i;
- Codex JSONL review'd;
- versiooni, inventuuri ja dokumentatsiooni drifti.

Enne avalikku release'i peab omanik lisama teadlikult valitud `LICENSE` faili.
