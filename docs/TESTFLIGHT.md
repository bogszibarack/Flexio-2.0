# TestFlight és App Store feltöltés — Flexio (iOS)

Ez az útmutató lépésről lépésre végigvezet, hogyan töltheted fel az appot **TestFlight**-ra, hogy ismerősök is letölthessék regisztráció nélkül (nyilvános linkkel) vagy meghívóval.

## Előfeltételek

| Követelmény | Megjegyzés |
|-------------|------------|
| **Apple Developer Program** | ~99 USD/év — [developer.apple.com/programs](https://developer.apple.com/programs/) |
| **Mac + Xcode** | Legfrissebb stabil Xcode |
| **Bundle ID** | `com.kokaiadam.flexio` (már beállítva) |
| **Supabase + API** | Éles kulcsok a buildhez |

> Ingyenes Apple ID-val csak ~7 napig működik a USB-s telepítés. TestFlight-hoz **fizetős** fejlesztői fiók kell.

---

## 1. App Store Connect — új app

1. Nyisd meg: [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. **My Apps** → **+** → **New App**
3. Platform: **iOS**
4. Name: **Flexio**
5. Primary Language: **Hungarian**
6. Bundle ID: válaszd ki a `com.kokaiadam.flexio`-t (ha nincs, előbb regisztráld a [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list) oldalon)
7. SKU: pl. `flexio-ios`

---

## 2. Xcode aláírás

```bash
open ios/Runner.xcworkspace
```

1. **Runner** target → **Signing & Capabilities**
2. **Team:** válaszd ki a fejlesztői csapatodat
3. **Bundle Identifier:** `com.kokaiadam.flexio`
4. **HealthKit** capability már be van kapcsolva (`Runner.entitlements`)

Mentsd el a **Team ID**-t (10 karakteres kód) — kell a build scripthez.

---

## 3. IPA build és feltöltés

### Automatikus script

```bash
export SUPABASE_URL="https://qbppiqfmhoaogyzaueix.supabase.co"
export SUPABASE_PUBLISHABLE_KEY="sb_publishable_..."
export API_BASE_URL="https://flexio-api.onrender.com"
export APPLE_TEAM_ID="XXXXXXXXXX"   # opcionális

chmod +x scripts/ios_testflight.sh
./scripts/ios_testflight.sh
```

### Kézi build

```bash
flutter build ipa --release \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<key> \
  --dart-define=API_BASE_URL=https://flexio-api.onrender.com
```

Az IPA: `build/ios/ipa/*.ipa`

### Feltöltés

- **Transporter** app (Mac App Store) → húzd rá az IPA-t  
- vagy Xcode → **Window → Organizer** → **Distribute App**

---

## 4. TestFlight beállítás

1. App Store Connect → **Flexio** → **TestFlight**
2. Várj, amíg a build **Processing** → **Ready to Test** (~5–15 perc)
3. Ha kéri: töltsd ki az **Export Compliance** kérdőívet (általában „No” titkosításra, ha csak HTTPS-t használsz)

### Belső tesztelők (azonnal)

- **Internal Testing** → add hozzá az Apple ID-dat és ismerőseidét (max 100 fő, Developer Program tagok)

### Külső tesztelők (nyilvános link)

1. **External Testing** → **+** új csoport (pl. „Béta”)
2. Add hozzá a buildet
3. Első alkalommal: **Beta App Review** (~1 nap)
4. Jóváhagyás után: **Public Link** → másold ki a linket

A link formátuma kb.: `https://testflight.apple.com/join/XXXXXXXX`

**Tedd be a README-be** a „TestFlight” szekcióba, hogy bárki kipróbálhassa.

---

## 5. Supabase — éles redirect URL

A TestFlight / App Store build ugyanazt a bundle ID-t használja. Ellenőrizd a Supabase Dashboard-on:

**Auth → URL Configuration → Redirect URLs:**

```
com.kokaiadam.flexio://login-callback/
```

---

## 6. Verzió növelés új feltöltésnél

`pubspec.yaml`:

```yaml
version: 1.0.1+2   # 1.0.1 = felhasználónak látható, +2 = build szám
```

Minden új TestFlight buildnél növeld a `+` utáni számot.

---

## Gyakori hibák

| Hiba | Megoldás |
|------|----------|
| „No signing certificate” | Xcode → Settings → Accounts → Download Manual Profiles |
| „Bundle ID not available” | Másik ID vagy regisztráld a Developer portálon |
| Build „Processing” órákig | Néha elakad — új build feltöltése |
| Bejelentkezés nem működik | Supabase redirect URL + éles kulcsok a buildben |
| HealthKit entitlement | Provisioning profile frissítése Xcode-ban |

---

## Következő lépés: App Store

Ha készen állsz a nyilvános megjelenésre:

1. App Store Connect → **App Information** + **Pricing**
2. Képernyőképek (6.7", 6.5", 5.5" — a `docs/screenshots/` alapból indulhatsz)
3. **Submit for Review**
