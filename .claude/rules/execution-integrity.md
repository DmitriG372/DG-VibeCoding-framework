# Execution Integrity Rules (MANDATORY)

> Need reeglid neutraliseerivad tuntud LLM nõrkusi planeerimisel ja täitmisel. KOHUSTUSLIKUD.

## Rule 1: Max 5–7 High-Level Steps Per Execution Plan

Ära loo plaani rohkem kui 5-7 järjestikuse sammuga. Kui ülesanne nõuab rohkem:
- Jaota alamplaanideks (5 sammu igaüks)
- Lõpeta alamplaan 1 enne alamplaani 2 loomist
- Iga alamplaan peab olema iseseisvalt kontrollitav

See piirang kehtib agendi nähtavale täitmisplaanile. Sprint-v3 feature'i 5–10
tehnilist `steps` kirjet on detailsem tööleping, mitte sama checklist.

## Rule 2: Explicit Step Tracking

Mitmesammulise plaani täitmisel hoia nähtav checklist:
```
PLAN PROGRESS:
[x] Step 1: kirjeldus — DONE (tõend: fail loodud, test läbitud)
[ ] Step 2: kirjeldus — CURRENT
[ ] Step 3: kirjeldus — PENDING
```
Uuenda seda ENNE iga uue sammu alustamist. Ära jäta vahele.

## Rule 3: Evidence-Based Completion

Ära väida sammu lõpetatuks ilma konkreetse tõendita:
- Fail loodud → näita failitee ja sisu
- Test läbitud → näita tegelik test output
- Build õnnestus → näita build käsu väljund
- Bug parandatud → näita enne/pärast käitumist

**KEELATUD fraasid** (hallutseeritud lõpetamise indikaatorid):
- "Tests should pass" → KÄIVITA testid, näita väljund
- "This should work" → VERIFITSEERI, näita tõend
- "I've updated the file" → NÄITA diff või loe fail tagasi
- "Everything is in place" → LOETELE konkreetselt mida tegid koos tõenditega
- "The function handles..." → KÄIVITA funktsioon, näita väljund
- "I believe this fixes..." → REPRODUTSEERI bug, näita et parandus töötab
- "Should be working now" → TÕESTA konkreetse käsuga

**Stub Detection** — enne lõpetamist kontrolli, et EI jää:
- `TODO`, `FIXME`, `HACK`, `XXX` kommentaare
- Tühjad funktsioonid / komponendid (ainult `return null` vms)
- Hardcoded väärtused mis peaksid olema konfist/DB-st
- `console.log`-only error handlerid
- Placeholder tekste ("Lorem ipsum", "test", "asdf")

## Rule 4: Honest Failure Reporting

Kui tööriistakutse ebaõnnestub:
- Raporteeri TEGELIK viga kohe
- ÄRA jätka nagu see õnnestus
- ÄRA fabritseeri alternatiivset tulemust
- Ütle: "Step X failed: [tegelik viga]. Valikud: [A] proovi uuesti, [B] jäta vahele, [C] alternatiivne lähenemine"

## Rule 5: User Gate for Multi-Step Work

3+ sammuga plaani puhul peatu pärast iga sammu:
"Step N complete. [tõend]. Kas jätkan step N+1?"
Erand: Jäta gate vahele AINULT kui kasutaja ütles selgesõnaliselt "tee kõik sammud peatumata".

## Rule 6: Session Health Check

Kui märkad järgmist, PEATU ja teata kasutajale:
- Ei mäleta mis on praegune ülesanne
- Pole kindel mitmes sammus oled
- Tööriista tulemus on vastuolus oodatuga
- Kavatsed korrata juba tehtud tööd
Ütle: "Session health warning: [probleem]. Soovitan /context-refresh enne jätkamist."
