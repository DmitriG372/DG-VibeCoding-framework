# Reegel: Delegatsioon agentidele

> Millal teha ise vs. millal kutsuda agent. Kohustuslik post-agent commit-tsükkel.

## Otsustuskriteeriumid

**Tee ise (< 2 min):**
- Kiired parandused, väikesed fixed
- Arutelud, analüüs, vastused küsimustele
- Muudatused < 50 LOC
- Konfide ja metafailide uuendamine
- Plaani lõikamine, sprint.json ad-hoc edits

**Delegeeri agendile (> 5 min või > 50 LOC):**
- Kood > 50 LOC, uued moodulid/komponendid
- Refaktoorimine olemasolevas koodis
- UI muudatused mitmes failis
- Uurimine ja dokumentatsiooni analüüs (researcher käitumine — vt `vibecoding/SKILL.md`)
- Testimine (unit, integration, E2E) — `tester` agent
- Code review — `reviewer` agent
- Bug debugging — `debugger` agent

## Meie agendid

| Agent | Käivita kui |
|-------|-------------|
| `orchestrator` | Mitme-domeeniline ülesanne, vaja koordineerida 2+ agenti |
| `implementer` | Kood > 50 LOC, uus moodul, refactor |
| `tester` | Testide kirjutamine ja jooksutamine |
| `reviewer` | Code review enne `/done`, kvaliteedi kontroll |
| `debugger` | Aktiivne bug, error message, broken state |
| `plan-checker` | Enne suure plaani täitmist, valideeri sammud |

## Delegatsiooni protokoll

1. **Koosta detailne ülesanne agendile:**
   - Kontekst (millise feature'iga töötame)
   - Failid mida lugeda (full paths)
   - Oodatav tulemus
   - Piirangud (mida MITTE muuta)

2. **Käivita agent** (Agent tool, sobiv `subagent_type`)

3. **Teata kasutajale lühidalt** (1 lause: "Saatsin implementer agendile X-task'i")

4. **Paralleelsus:** kui ülesanded on sõltumatud, käivita mitu agenti ühes vastuses (multiple Agent tool calls in one message)

## Kohustuslik tsükkel pärast agenti

> **See on KRIITILINE.** Ilma selleta agendi töö "kaob".

Meie 6 agenti **ei commit'i ise** — see on orkestreerija (sina) vastutus. Hooks (`completion-guard.js`, `sprint-sync.js`) ei tee commit'i — need on guardrail'id.

Pärast agendi tagasitulekut tee:

1. **Hinda tulemust** — kas ülesanne sai korralikult tehtud?
   - Kontrolli failid (Read tool, kui agent muutis koodi)
   - Vaata diff (`git diff`)
   - Kui mitte — tagasi agendile uue ülesandega või tee ise üle

2. **`git add` + `git commit`** — fikseeri muudatused konkreetsete failinimedega:
   ```bash
   git add path/to/specific/files
   git commit -m "feat(scope): F<ID> kirjeldus

   - mida tehti
   - millised failid muutusid"
   ```
   **Ei kasuta** `git add .` ega `git add -A` (vt `negative-constraints.md`).

3. **Uuenda `sprint.json`** kui see on feature'i osa:
   - `feature.git.hash` = uus commit hash
   - `feature.git.message`, `feature.git.timestamp`
   - `last_updated`, `last_updated_by`

4. **Uuenda SNAPSHOT.md** kui käib käsil sessioonipõhine töö (kui projektis on SNAPSHOT.md):
   - "Mis tehtud" lisand
   - "Järgmised sammud" uuendus

5. **Integreeri kontekstis** — veendu, et oma arusaam projektist on värske. Kui mitu agenti töötasid paralleelselt, loe iga tulemus enne edasiminekut.

### Paralleelsete agentide korral

- **Ei oota kõiki.** Iga agent → eraldi commit kohe, kui tagasi tuleb.
- Üks agent = üks commit = üks `sprint.json` uuendus.
- Erand: kui kaks agenti muutsid sama faili (ei tohiks juhtuda korraliku ülesannete jaotamisega) — siis ühenda käsitsi enne commit'i.

### Kui see tsükkel jääb tegemata

- Pärast compaction'it agent "unustab" agendi töö
- Järgmises sessioonis projekti olek on aegunud
- Drift: agent hakkab tegema juba tehtud tööd
- `/done` ei näe agendi tööd, kuna see ei ole sprint.json-is fikseeritud
