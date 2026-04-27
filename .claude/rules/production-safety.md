# Reegel: Production-ohutus

> Mida küsida vs. mida otsustada ise. Komplementaarne `negative-constraints.md`-ga.

## Põhimõte

Kõik, mis puudutab production'it — küsi kasutajalt. Kõik muu — täisautonoomia (`autonomy.md`).

## Nõuab kinnitust

- **Production deploy** (Vercel, Netlify, fly.io, npm publish, PyPI upload, Docker push)
- **Production andmebaasi muutused** (migratsioon, andmete kustutamine, seed)
- **DNS, domeen, SSL muutused**
- **Production environment variables muutused**
- **`git push` kui sihtbranch on production** (main/master, kui see on deployment trigger)
- **CI/CD pipeline muutused production'i jaoks**
- **Force push main'i** (kunagi pole vaikimisi OK)

## Täisautonoomia (ei küsi)

- Failide loomine, muutmine, kustutamine projekti sees
- Testide käivitamine (unit, integration, E2E)
- Git operatsioonid: commit, branch, merge, rebase, checkout (välja arvatud production push)
- **Staging deploy**
- Lokaalne areng
- Sõltuvuste install (`npm install`, `pip install`) — kuid mitte uue *deps* lisamine ilma küsimata; vt `negative-constraints.md`
- Refaktoorimine olemasolevas töökoodis (praeguse feature'i raames)
- Dokumentatsiooni loomine ja uuendamine

## Kuidas küsida

Lühidalt, ilma saagaks. Template:

```
Production deploy valmis:
- Mis deploy'itakse: <komponent>
- Millised muudatused: <kokkuvõte 2-3 punktis>
- Risk: <madal | keskmine | kõrge>

Kinnita? (y/n)
```

> Pärast kinnituse saamist — tee. Ära küsi uuesti vahepealse step'i kohta.

## Suhe teiste reeglitega

- **`negative-constraints.md`** ütleb negatiivselt: "Mitte kunagi tee X ilma kinnituseta" (force push, secrets commit, jne)
- **See reegel** ütleb positiivselt: "Just need on hetked, kui küsi"
- **`autonomy.md`** ütleb: "Kõik muu — otsusta ise"
- **`execution-integrity.md` Rule 5** ütleb: "3+ sammu plaani puhul ka vahepealsetes gate'ides peatu" — see kehtib production'ile lisaks

Kui kahtled — pigem küsi. Production üksiku force push'i kahju >> liigselt küsimine.
