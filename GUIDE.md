# DG-VibeCoding-Framework v8.0.0 — Kasutusjuhend

## 1. Komponendid

| Komponent | Arv | Roll |
|---|---:|---|
| Skills    | 8 | Korduvkasutatavad töövood |
| Commands  | 12 | Sprint, review, handoff ja kontekst |
| Agents    | 6 | Spetsialiseeritud Claude Code rollid |
| Hooks     | 15 | Deterministlikud guardrail’id |

Claude Code ja Codex on võrdsed partnerid ühise projekti- ja sprindilepingu
tasandil. Runtime konfiguratsioon ei ole ühine: Claude kasutab `.claude/`
seadistust ning Codex `.codex/hooks.json` faili.

## 2. Uue projekti loomine

```bash
/path/to/DG-VibeCoding-framework/setup-project.sh /path/to/new-project
cd /path/to/new-project
```

Setup töötab vaikimisi ainult tühjas kaustas. Olemasolevate framework-failide
asendamine nõuab `--force`; enne kirjutamist luuakse projekti sisse ajatempliga
backup.

Täida pärast setup’i:

1. `PROJECT.md` — päris stack, struktuur, käsud ja konventsioonid.
2. `AGENTS.md` — ainult püsivad Codexi repo-juhised.
3. `CLAUDE.md` — ainult püsivad Claude Code’i repo-juhised.
4. Initsialiseeri Git, kui projekt ei ole veel repository.
5. Käivita `/sprint-init`.

## 3. Sprint-v3

Sprindi tõeallikas on `sprint/sprint.json`. Kontroll:

```bash
node scripts/validate-sprint.js sprint/sprint.json
```

Mitte-triviaalne feature sisaldab:

- unikaalset `FNNN` ID-d;
- selget eesmärki ja mõõdetavaid acceptance criteria’sid;
- 5–10 `{ id, desc, done }` sammu;
- `corridor.allowed` ja `corridor.forbidden` mustreid;
- agenti, staatust, keerukust ja testitõendit.

`stats` arvutatakse feature staatustest; seda ei käsitleta sõltumatu tõena.

## 4. Järjestikune töö

Kasuta `branch_strategy: "sequential"`, kui üks agent töötab korraga ühes
checkout’is.

```text
/sprint-init
/feature F001
[test → implementatsioon → kontroll]
/done
/peer-review
```

`/done` loob ühe implementation commit’i ja seejärel eraldi sprint-state
coordination commit’i.

## 5. Paralleelne CC + CX töö

Paralleeltöö nõuab `branch_strategy: "worktree"`.

```text
CC: /handoff F003
    → sprint-state valideeritakse ja commit’itakse
    → cx/F003-... worktree luuakse sellest commit’ist
CX: cd <worktree>
CX: codex --sandbox workspace-write
```

Ära käivita kahte agenti samas checkout’is. Git saab ühes tööpuus hoida korraga
ainult üht checkoutitud haru.

## 6. Review

Interaktiivne review:

```text
/review src/
/peer-review cx/F003-feature
```

Headless review:

```bash
scripts/headless-review.sh --tool claude --mode quick --staged
scripts/headless-review.sh --tool codex --mode full src/ --output review.json
```

Runner kasutab sprindi `base_branch` väärtust, Gitiga jälgitud faile,
secret-path filtrit, sisendi byte-limitit ja struktureeritud väljundit. Codexi
JSONL sündmused teisendatakse lõppvastuseks eraldi parseriga.

## 7. Migratsioon

Alusta dry-run’iga:

```bash
./migrate-v7-to-v8.sh /path/to/project --dry-run
./migrate-v7-to-v8.sh /path/to/project
```

Migratsioon:

- teeb framework-state backup’i;
- säilitab custom skill’id, agendid, käsud, hook’id ja settings’id;
- merge’ib frameworki hallatud failid nime järgi;
- teisendab sprindi ajutisse faili ja valideerib enne atomic rename’i;
- ei kirjuta algset `sprint.json.v7.bak` faili korduskäivitusel üle.

## 8. Repo access

`repo_access` on lokaalne poliitika, mitte põhjus peita tiimilt arenduslepingut.
Seetõttu jäävad `PROJECT.md`, `AGENTS.md`, `CLAUDE.md`, frameworki runtime ja
sprindileping kõigis režiimides trackituks.

Ignoreeritud on ainult lokaalsed settings’id, manifest, snapshotid, logid,
credentials, environment failid, andmebaasid ja build output.

```bash
scripts/switch-repo-access.sh private-solo
scripts/switch-repo-access.sh private-shared
scripts/switch-repo-access.sh public
```

## 9. Hookide käitumine

- decomposition guard blokeerib ebapiisavalt jaotatud aktiivse feature’i;
- scope guard hoiatab corridor’i rikkumisest;
- completion guard kontrollib staged koodi stub’e;
- test protection on pärast ebaõnnestunud testi advisory, mitte hard block;
- formatter kasutab ainult lokaalset installitud binary’t;
- typecheck ja formatter on debounce’itud;
- puuduva session ID korral context-monitor ei loo jagatud `unknown` loendurit.

Hookid on guardrail’id, mitte täielik turvasandbox.

## 10. Verifitseerimine

```bash
bash tests/run.sh
```

Täiskomplekt kontrollib:

- sprint-v3 valideerimist;
- Claude/Codex hook payload’e;
- setup artefakti täielikkust;
- migratsiooni säilitavust ja idempotentsust;
- worktree handoff’i;
- ohtlikke failinimesid ja secret-path’e;
- Codex JSONL review’d;
- versiooni, inventuuri ja dokumentatsiooni drifti.

Enne avalikku release’i peab omanik lisama teadlikult valitud `LICENSE` faili.
