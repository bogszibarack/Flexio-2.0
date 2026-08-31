# Flexio backend munkák

Ez a könyvtár nem futó szolgáltatás, hanem két adatmunka: a kurátorolt magyar
ételkatalógus betöltése és az Open Food Facts (OFF) import. A felhasználói
kéréseket a Supabase szolgálja ki közvetlenül, a Render csak számol.

## Előkészítés

1. Supabase projekt létrehozása **EU régióban** (az egészségadat a GDPR szerint
   különösen védett kategória).
2. A migrációk lefuttatása a `supabase/migrations` könyvtárból, időrendben:
   - `20260829090000_init.sql` — táblák, indexek, RLS
   - `20260829090100_search.sql` — `search_foods` és a többi RPC
   - `20260829090200_account.sql` — profil létrehozása regisztrációnál, fióktörlés

   Supabase CLI-vel: `supabase db push`, vagy a felület SQL editorába beillesztve.
3. `npm ci` ebben a könyvtárban (Node 20 vagy újabb).
4. A Flutter oldal a kulcsokat build időben kapja. Ha ezek nincsenek megadva, az
   app helyi módban indul: minden adat a készüléken marad.

   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=https://xxx.supabase.co \
     --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
   ```

## Katalógus

```bash
npm run build:catalog     # assets/food_catalog_part_*.json -> assets/food_catalog_hu.json
DATABASE_URL=postgres://... npm run seed:foods
```

A `build:catalog` ellenőrzi a kötelező mezőket, egységesíti az azonosítókat, és
a makrókból visszaszámolja a kalóriát, ha az eltérés 20% felett van. A generált
`assets/food_catalog_hu.json` egyben az app offline forrása is, tehát a
`build:catalog` futtatása után a Flutter oldalon nincs további dolog.

## Open Food Facts import

```bash
DATABASE_URL=postgres://... npm run import:off

# gyors próba a teljes dump nélkül:
DATABASE_URL=postgres://... OFF_MAX_ROWS=200000 npm run import:off
```

A szkript streamelve dolgozza fel a tabulátorral tagolt dumpot (kb. 0,9 GB
tömörítve), kiszűri azokat a termékeket, amiknél a `countries_tags` tartalmazza
Magyarországot vagy van magyar terméknév, és `barcode` kulcson upsertel. A
tápanyagadat nélküli termékeket kihagyja, mert naplózásra használhatatlanok.

Renderen a `render.yaml` egy heti cron jobot ír le (hétfő 03:00, frankfurti
régió). A `DATABASE_URL` értéke a Supabase connection string.

## Licenc

Az OFF adat Open Database License (ODbL) alatt van: forrásmegjelölés kötelező,
és a származtatott adatbázist hasonló feltételekkel kell megosztani. Az appban
ezt a Profil / Adatforrások képernyő tartalmazza.
