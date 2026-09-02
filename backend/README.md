# Flexio backend (.NET 10)

A Flexio saját API-ja. A Supabase marad az adat- és identitásréteg (Auth,
Postgres, RLS); ez a szolgáltatás oda kerül, ahová a telefon nem nyúlhat:
Gemini-kulcs, kvóta, Open Food Facts import, katalógus, később admin.

A teljes terv és a döntések indoklása: `.cursor/plans/flexio_c#_backend_*.plan.md`.

## Rétegek

```
src/Flexio.Domain/          entitások, value objectek, domain szabályok, kivételek
src/Flexio.Application/     use case-ek, DTO-k, validátorok, port interfészek
src/Flexio.Infrastructure/  konkrét implementációk: Postgres, Gemini, OFF import
src/Flexio.Api/             HTTP határ, DI, middleware, health - a composition root
tests/Flexio.UnitTests/         Domain és Application, külső függőség nélkül
tests/Flexio.IntegrationTests/  a összeépített alkalmazás WebApplicationFactoryvel
```

A referenciák iránya `Api -> Application -> Domain`, illetve
`Infrastructure -> Application`. A Domain projektnek szándékosan nincs egyetlen
külső csomagja sem: a fordítási irány akadályozza meg, hogy egy üzleti szabály
infrastruktúrától függjön.

## Futtatás

```bash
dotnet restore
dotnet build
dotnet test
dotnet run --project src/Flexio.Api
```

A cél-framework egy helyen van (`Directory.Build.props`), a csomagverziók
központilag (`Directory.Packages.props`), az SDK pedig `global.json`-ban pinelve.

### SDK a gépen

A .NET 10 SDK a `~/.dotnet` alatt van. Hogy a terminál és az IDE is lássa, a
`~/.zshrc`-be ez a két sor kell:

```bash
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$HOME/.dotnet:$PATH"
```

## Konfiguráció

Minden titok környezeti változóból jön, semmi nem kerül az `appsettings.json`-ba.
A kettős aláhúzás a szekció-elválasztó.

| Változó | Kötelező | Leírás |
| --- | --- | --- |
| `SupabaseAuth__ProjectUrl` | **igen** | Például `https://abcdefgh.supabase.co`. Enélkül a szolgáltatás szándékosan nem indul el: token-kibocsátó nélkül nem lehet felhasználói adatot kiszolgálni. |
| `SupabaseAuth__LegacyJwtSecret` | nem | Csak amíg a projekt HS256-tal ír alá. Aszimmetrikus kulcs esetén hagyd üresen. |
| `Postgres__ApiConnectionString` | **igen** | A `flexio_api` role kapcsolata. RLS alatt fut; a `rolbypassrls` induláskor ellenőrzött. |
| `Postgres__JobsConnectionString` | nem | A `flexio_jobs` role kapcsolata (OFF import, seed). Hiányában az import endpointok nem érhetők el. |
| `Postgres__StartupProbeAttempts` | nem | Alap: `5`. A `0` kikapcsolja az induláskori DB-ellenőrzést (csak tesztekhez). |
| `InternalJobs__SharedSecret` | nem* | Legalább 16 karakter. Hiányában a `/internal/jobs/*` végpontok 401-et adnak. |
| `PORT` | nem | A platform (Render) adja meg; hiányában 8080. |
| `Gemini__ApiKey` | nem | Hiányában a coach a kliens tartalék szövegét adja vissza (readiness: degraded). |
| `Gemini__Model` | nem | Alapértelmezés: `gemini-2.0-flash`. |

```bash
SupabaseAuth__ProjectUrl=https://abcdefgh.supabase.co \
Postgres__ApiConnectionString='Host=...;Username=flexio_api;Password=...;Database=postgres;SSL Mode=Require' \
dotnet run --project src/Flexio.Api
```

A migráció (`supabase/migrations/20260830190000_api_role.sql`) létrehozza a
`flexio_api` / `flexio_jobs` role-okat és a `flexio_current_user_id()` illesztési
pontot. A jelszót a migráció szándékosan nem állítja be — egyszeri lépés a
Supabase SQL konzolban:

```sql
alter role flexio_api  password '...';
alter role flexio_jobs password '...';
```

Minden adatbázis-művelet (az olvasás is) tranzakcióban fut, mert a felhasználói
kontextus (`app.current_user_id`) tranzakció-lokális. Tranzakció nélkül a
beállítás a statement végén eldobódna.
## Hitelesítés

A tokent a Supabase Auth adja ki, ez a szolgáltatás csak validál: a kulcsokat a
`{ProjectUrl}/auth/v1/.well-known/jwks.json` végpontról tölti, gyorsítótárral és
automatikus kulcsrotációval. Jelszót, refresh tokent és fióklétrehozást nem kezel.

A felhasználót kizárólag a token `sub` claimje azonosítja. A kliens sosem küld
`user_id`-t a kérés törzsében, így nem tud más nevében írni.

Az alapállapot zárt: az `AuthorizationBuilder` fallback szabálya minden
endpointtól hitelesítést kér, a nyilvános kivételeket (health, séma) explicit
`AllowAnonymous` jelöli. Ennek egy szándékos következménye van: hitelesítés
nélkül egy nem létező útvonal is `401`-et kap, nem `404`-et, tehát a
végpontlista sem szivárog ki. Érvényes tokennel a nem létező útvonal `404`.

| Útvonal | Mit ad |
| --- | --- |
| `GET /api/v1/me` | A tokenből felismert felhasználó azonosítója. A kliens ezzel tudja ellenőrizni, hogy a szerver ugyanazt az identitást látja. |
| `POST /api/v1/coach` | Magyar coach szöveg rövid pillanatképből. Gemini kulcs nélkül a kliens `fallback` szövegét adja vissza. Felhasználó-alapú kvóta: 40 kérés / óra. |
| `POST /api/v1/sync` | Piszkos sorok feltöltése (diary, workouts, sleep, profile, goals) és a watermark óta változott sorok lekérése. LWW az `updated_at` szerint; batch max 500. |
| `GET /api/v1/foods/search?q=` | Rétegzett ételkeresés (Postgres `search_foods` RPC). |
| `GET /api/v1/foods/barcode/{code}` | Étel vonalkód alapján. |
| `POST /api/v1/foods/search-miss` | Találat nélküli keresés napló. |
| `POST /internal/jobs/import-off` | OFF import (cron, `X-Flexio-Job-Secret`). Háttérben fut, 202 Accepted. |
| `POST /internal/jobs/seed-foods` | Katalógus seed (cron, `X-Flexio-Job-Secret`). Szinkron, 200 + statisztika. |

A coach kérés törzse legfeljebb 8 KiB. A válasz soha nem tartalmaz orvosi
tanácsot vagy kitalált számot - a számokat a telefon számolja.

A sync JSON snake_case (Flutter / Supabase szerződés). A szerver megtartja a
kliens `updated_at` értékét; a `touch_updated_at` trigger csak akkor ír
`now()`-t, ha a hívó nem küldött új időbélyeget.## Health

| Útvonal | Mit mond |
| --- | --- |
| `GET /health/live` | Csak a folyamat élete. Külső próbát szándékosan nem futtat, hogy egy adatbázis-kimaradás ne indítson konténer-újraindítást. |
| `GET /health/ready` | A külső függőségek is beleszámítanak; a forgalomból való ki- és bevezetés ezen dől el. |

## Hibaformátum

Minden hibaválasz RFC 9457 `application/problem+json`, a kivételből származók és
a middleware-ből jövők (nem talált útvonal, hitelesítési elutasítás) egyaránt:

```json
{
  "type": "https://flexio.app/problems/NotFound",
  "title": "Nem található",
  "status": 404,
  "detail": "A kért erőforrás nem található: naplóbejegyzés.",
  "instance": "/api/v1/diary/...",
  "errorCode": "NotFound",
  "traceId": "..."
}
```

A `detail` sosem tartalmaz erőforrás-azonosítót: a nem létező és a más
felhasználóhoz tartozó erőforrás válasza megkülönböztethetetlen, különben az
azonosító létezése kiszivárogna.

## Docker

```bash
docker build -t flexio-api .
docker run --rm -p 8080:8080 flexio-api
```

Kétszakaszos build: a végleges képbe nem kerül SDK vagy forráskód, és nem root
felhasználóként fut.
