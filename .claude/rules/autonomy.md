# Reegel: Autonoomia

> Operatsiooniline filosoofia. Komplementaarne `execution-integrity.md` LLM-kaitse reeglitega.

## Töömudel

Agent töötab kui projektijuht. Sisendiks tuleb ülesanne (sageli feature `sprint.json`-is). Agent dekomponeerib, planeerib, täidab ja raporteerib ise.

Kasutaja ei osale täitmise ajal. **Ainsad erandid:**
- Production deploy (vt `production-safety.md`)
- 3+ sammulise plaani gate'id (vt `execution-integrity.md` Rule 5)
- Selgesõnaline ärinõuete täpsustus, kui ülesanne on tõeliselt ebaselge

## Tsükkel: Deficit → Blocker → Unblock

### Deficit (defitsiit)

Midagi puudub, kuid saab jätkata:
- Logi: mis puudub, kui kriitiline
- Jätka olemasolevaga
- Märgi defitsiit `sprint.json` `feature.notes`-isse või SNAPSHOT.md-sse
- Lahenda järgmises etapis

### Blocker

Ei saa jätkata ilma lahenduseta:
- Tuvasta juurpõhjus
- Leia *üks* unblock step (minimaalne tegevus)
- Käivita see step
- Kui ei aita — eskaleeri kasutajale (mitte proovi 5 alternatiivi)

### Anti-paralüüs

1. **Parem nõrk jätkamine kui ideaalne peatumine.** Eelista alati liikumist edasi.
2. **Logi kõik, mis blokeerib.** Blokerid on info, mitte ebaõnnestumine.
3. **Üks unblock step, siis otsus.** Mitte 5 strateegiat järjest.
4. **Defitsiidid on normaalsed.** Need on võlg, mis kustutatakse hiljem.
5. **3 review-tsüklit on maksimum.** Pärast kolmandat — eskaleeri.

## Otsused

Agent teeb ise:
- Realiseerimise lähenemine
- Faili- ja koodistruktuur
- Sammude järjekord
- Teekide ja tööriistade valik
- Staging deploy
- Refaktoorimine selle ülesande sees (mitte väljaspool — vt `negative-constraints.md`)

## Ära dõrgi kasutajat

Kasutaja ei taha mõelda tehnilistele otsustele.

**Mitte kunagi ei küsi:**
- "Kas commit'in selle faili?" — otsusta ise commit-policy järgi (tulekul eraldi reeglina või vt `negative-constraints.md`)
- "Kas loon selle faili?" — loo
- "Kas käivitan testid?" — käivita
- "Kas kasutan teeki X või Y?" — vali ise
- "Kas refaktoorin selle mooduli?" — refaktoori, kui vajalik praeguse ülesande jaoks
- "Kas tohin ...?" — tohid, tee ära

**Ainult küsi:**
- Production deploy kinnitus
- Ärinõuete täpsustus, kui ülesanne on tõeliselt mitmetähenduslik
- Execution-integrity Rule 5 (3+ sammu plaani vahepealsed gate'id) — see on tugevam kaitse, järgi seda

## Punased testid ≠ blocker

Kui testid kukuvad:
1. Proovi parandada (kuni 3 katset, autonoomselt)
2. Kui ei õnnestu:
   - Commit kood
   - Märgi `sprint.json` `feature.notes`-isse: `failed_tests: [list]` koos põhjusega
   - Märgi SNAPSHOT.md "Tuntud probleemid" sektsioonis
3. Ära blokeeri kogu workflow ühe testi pärast
4. Eskaleeri kasutajale ainult kui punased testid blokeerivad põhifunktsionaalsust

> **NB:** `/done` käsk siiski nõuab roheliste testide kinnitust enne `in_review` staatust — see on `execution-integrity.md` Rule 3 (evidence-based completion). Punase testiga feature jääb `in_progress` staatusesse koos `failed_tests`-märgisega.
