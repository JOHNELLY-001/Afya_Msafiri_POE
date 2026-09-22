# AfyaMsafiri PoE — Setup & Implementation Manual

A mobile app for Point-of-Entry (PoE) health officers: scan a traveller's
AfyaMsafiri QR code, review the booking record, run a risk assessment and
record an entry decision (CLEAR / REFER / QUARANTINE), online or offline.

---

## 1. Tech stack

| Layer | Choice |
|---|---|
| Framework / language | Flutter 3.47 (stable) / Dart 3.13 |
| State management | `flutter_riverpod` (Notifier + Future/Stream providers) |
| Navigation | `go_router` (typed route table in `lib/app/routes.dart`) |
| HTTP | `dio` (mediator client in `lib/core/network/mediator_client.dart`) |
| Backend SDK | `d2_touch` 1.1.9 (DHIS2; auth path currently bypassed — §5) |
| Local storage | Drift + SQLite (`afyamsafiri_manager.sqlite`), `shared_preferences`, `flutter_secure_storage` |
| QR scanning | `mobile_scanner` |
| Connectivity | `connectivity_plus` |
| Fonts | **Bundled Inter TTFs** (`assets/fonts/`, declared in `pubspec.yaml`). The `google_fonts` *package* is intentionally NOT used: `d2_touch` pins `intl ^0.19.0`, which conflicts with `google_fonts` v6, and runtime-fetched fonts break offline field use. |
| Linting | `flutter_lints` (`flutter analyze`) |

Multi-platform project (android/ios/web/windows/linux/macos); the
supported field target is **Android (portrait phones)**.

---

## 2. Prerequisites

1. Flutter SDK 3.47+ on stable (`flutter --version`), Dart bundled with it.
2. Android Studio (or VS Code + Flutter plugin) with an Android SDK.
3. A physical Android device with USB debugging **or** an emulator.
   Camera is required for real QR scanning (manual entry works anywhere).
4. Network access to `https://afyamsafiri.moh.go.tz/test/mediator/api`
   for live data (the app still runs offline with fallbacks).

---

## 3. Installation & running

```powershell
# from the project root
flutter clean
flutter pub get
flutter run            # debug build on the connected device

# release install file
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

> Always **uninstall the previous app from the device first** when
> switching between mock/live modes or after dependency changes, so no
> stale database or install lingers.

Useful checks:

```powershell
flutter analyze --no-pub lib/     # static analysis (infos only = clean)
flutter pub outdated              # dependency update overview (do NOT
                                  # upgrade intl past 0.19.x — d2_touch pins it)
```

---

## 4. Configuration — the two global flags

Everything is driven from **`lib/app/config.dart`** (the single contract,
as documented in the file header):

```dart
AppConfig.useMockData = true    // mock traveller/risk/decisions/login
AppConfig.bypassAuth  = true    // skip the login window (temporary)
```

| Flag | `true` (current) | `false` |
|---|---|---|
| `useMockData` | Traveller = built-in "John Mushi" record; risk = static 16-country list; decisions pretend to sync; login accepts anything | Traveller + risk go **live** on the mediator; decisions queue on-device for **manual sync** (§6) |
| `bypassAuth` | Splash → duty station directly; router guard off; login screen has "Continue without login" | Login enforced via `D2TouchAuthRepository` (needs a real auth endpoint — none exists yet) |

**Always-live regardless of flags:** PoE border types/stations
(`GET /poeCenters`), QR validation (booking lookups), flagged-country
count, pending-sync count, Drift queue, connectivity banner.

Other config files:

* `lib/app/dhis2_config.dart` — DHIS2 base URL (no trailing `/api`;
  d2_touch appends it) + local DB name. Only used when auth is enabled.
* `lib/core/network/mediator_client.dart` — `MediatorConfig.baseUrl`
  (`.../test/mediator/api`), 20s timeouts, `MediatorNotFoundException`
  mapping (the mediator answers 400 "…could not be found").

---

## 5. Backend endpoints & live/mock matrix

Mediator Swagger UI: `https://afyamsafiri.moh.go.tz/test/mediator/api/`
(no login endpoint exists — verified; that is why auth is bypassed).

| Endpoint | Used by | Live? |
|---|---|---|
| `GET /poeCenters`, `GET /poeCenters/{id}` | Duty-station picker (Air 12, Land 26, Lake 12, Sea 5) | ✅ always live |
| `GET /arrivalBooking/{id}`, `/yellowFeverBooking/{id}`, `/cardReplacementBooking/{id}` | QR validation + traveller record | ✅ live (scan always; record when `useMockData=false`) |
| `POST …/check` (`{bookingId, identifiers[]}`) | Lighter verify alternative (wired as fallback pattern) | ✅ available |
| `GET /riskcountries` (16 flagged) | Risk assessment + dashboard count | ✅ live (assessment when `useMockData=false`) |
| `GET /*Metadata/bookingForm?locale=` | Field codes the parser mirrors (symptoms, exposure, travel history) | ✅ reference |
| `GET /client/{id}?identifierType=&showServices=` | Traveller enrichment | ⚠️ unverified (needs a real identifier) |
| `POST /certificates`, `GET /certificates/{id}` | — (no UI yet) | Endpoints exist, not wired |
| Decision submission (CLEAR/REFER/QUARANTINE) | Sync Center | ❌ **no endpoint exists** → manual on-device queue (§6) |
| `GET /api/me.json` (DHIS2 login) | Login | ❌ 404 on mediator → bypassed |

QR format (live): `{"bookingID":"TSFA…","arrivalDate":"…","portOfEntry":"<uid>"}`.
Test codes: `TSFA-EXPIRED-TEST`, `TSFA-USED-TEST` (mock paths).

### Wiring a future endpoint (decisions example)

When the backend ships a submission endpoint, open
`lib/features/decisions/data/repositories/api_decision_repository.dart`
and follow the `SERVER CONFIG` block: set the path/method, map the
`Decision` payload, inject the shared mediator Dio, delete the throw.
No screen or provider changes needed (repository interface is stable).

---

## 6. Offline & manual-sync behavior

* Scan validation degrades to format-only (`TSFA…` prefix) offline.
* Traveller/risk/PoE fall back to bundled data offline (mock record,
  static country list, 3 fallback stations).
* Confirming a decision while offline (or with no endpoint configured)
  stores it in Drift (`queuedDecisions`, `synced=false`) and the receipt
  reads **"Saved on device"**.
* **Sync Center** (`/sync`): pending list with per-item status, manual
  **retry** button, auto-retry when connectivity returns
  (`autoSyncProvider`). **Sync Diagnostics** (`/sync/diagnostics`):
  connectivity, pending count, data mode (Mock/Live), version.
* With `useMockData=false` and no decision endpoint, retries fail with
  *"Kept on device — no server endpoint configured …"* and stay queued.
  Nothing is ever lost; sync will succeed once §5 is configured.

---

## 7. Officer journey (routes)

`splash (/)` → `login (/login, bypassed)` →
`point-of-entry` (border type → station, searchable) →
`dashboard` (officer header, duty station, scan hero, live stats) →
`scan` (+ `manual-entry`) →
`scan/success` · `scan/invalid` · `scan/already-processed` →
`traveller` (+ `history`, `screening`) →
`risk` (+ `details`) →
`decision` → `decision/confirm` → `decision/recorded` →
`sync`, `sync/diagnostics`.

Auth guard lives in `routerProvider` (`lib/app/routes.dart`); splash
restores SDK sessions (`SessionNotifier.restoreSession`) with an 8s
timeout and a manual **Continue** failsafe after 6s (never traps the
officer on splash).

---

## 8. UI system

* Theme: Material 3 "Azure Horizon" (`lib/app/theme.dart`), Inter
  everywhere, 12-style type scale, `AppStatus` semantic colors
  (sunlight-legible success/warning/danger/info).
* Tokens: `lib/app/design_tokens.dart` (`AppSpacing`, `AppRadius`,
  `AppStatus`).
* Shared widgets (`lib/core/widgets/`): `AppButton`, `AppTextField`,
  `AppSearchField`, `SectionHeader`, `StatusChip`, `InitialsAvatar`,
  `AppErrorState`/`AppLoadingState`, `ScanResultView`, plus newer
  `AfyaAppBar`, `PageHero`, `FlowSteps`.
* Conventions: every async screen has loading / error+retry / empty
  states; record screens mirror the live booking-form groups; no
  fabricated data (already-processed shows only the reference + link).

---

## 9. Troubleshooting

| Symptom | Cause / fix |
|---|---|
| Stuck on splash | Old install — uninstall, `flutter clean`, `flutter run`. After 6s a **Continue** button appears; console `SPLASH:` lines pinpoint hangs. Do not modify providers inside `initState` (Riverpod forbids it — resolve post-frame). |
| `Null is not a subtype of String` at login | d2_touch `User.fromApi` vs mediator's non-DHIS2 body. Keep `bypassAuth=true` until a real auth endpoint exists. |
| Booking "not found" | Correct behavior for unknown IDs (mediator 400). Test with a real `TSFA…` ID from a live QR. |
| `flutter pub get` version solves fail | Never upgrade `intl` past 0.19.x (`d2_touch` pins it); never re-add `google_fonts` v6. Fonts are bundled — nothing to install. |
| Analyzer OOM on huge files | Re-run on a smaller scope (`flutter analyze --no-pub lib/<area>/`). Pre-existing infos (`withOpacity`, generated `main.reflectable.dart`) are safe to ignore. |
