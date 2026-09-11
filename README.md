# AfyaMsafiri Manager

A Flutter mobile application for **Point of Entry (POE) health officers** in Tanzania, built as part of the AfyaMsafiri traveller health-screening and surveillance system. This app is the officer-facing counterpart to the AfyaMsafiri Traveller Mobile Portal, and integrates with the existing **DHIS2/AfyaMsafiri backend**.

> **Status:** Practical training / academic project (University of Dar es Salaam). This is a student prototype, not an official Ministry of Health deployment.

---

## Overview

Officers use this app to:

1. Sign in and select their assigned Point of Entry
2. Scan a traveller's QR code (or search/enter a booking reference manually) to retrieve their booking and health-screening record
3. View the traveller's identity, travel history, and screening answers
4. See an automatic **risk assessment** (Low / Elevated / High) based on countries visited
5. Record an **entry decision** — Cleared, Referred for further screening, or Quarantined — with officer notes
6. Continue operating **offline**, with decisions queued locally and synced automatically once connectivity returns
7. Review screening history, flagged/high-risk travellers, and (for supervisors) basic operational summaries

The core operational loop:

```
Sign In → Select POE → Scan/Search Traveller → Traveller Record
   → Risk Assessment → Entry Decision → Confirm → Record/Sync
```

---

## Tech Stack

| Concern | Package |
|---|---|
| State management | `flutter_riverpod` |
| Navigation | `go_router` |
| DHIS2/AfyaMsafiri integration | `d2_touch` (UDSM DHIS2 Lab Flutter SDK) |
| Local offline storage (app-side decision queue) | `drift` + `sqlite3_flutter_libs` |
| QR scanning | `mobile_scanner` |
| Connectivity detection | `connectivity_plus` |
| Networking (mock/legacy paths) | `dio` |
| Secure token storage | `flutter_secure_storage` |

---

## Architecture

Feature-based structure, with each feature following a light `data / domain / presentation` split:

```
lib/
├── app/                     # App shell: routing, theme, design tokens, config
├── core/                    # Shared infra: network, utils, base widgets
├── shared/                  # Cross-feature models, components, Riverpod providers
└── features/
    ├── authentication/      # Login, session
    ├── point_of_entry/      # POE selection
    ├── dashboard/           # Officer home screen
    ├── scanning/            # QR scanner, manual entry, error states
    ├── traveller/           # Traveller record, travel history, screening
    ├── risk_assessment/     # Risk logic + screens
    ├── decisions/           # Entry decision, confirmation, recorded
    ├── synchronization/     # Offline queue, sync center, diagnostics
    ├── history/             # Scan history, flagged travellers
    └── supervisor/          # Minimal supervisor dashboard
```

### Repository pattern & the mock ↔ real API switch

Every feature depends on a **repository interface** (e.g. `TravellerRepository`), never on a concrete implementation. Two implementations exist side by side:

- A **mock** implementation, used for UI development without a backend
- A **`d2_touch`-backed** implementation, used against the real DHIS2/AfyaMsafiri instance

Switching between them is a single flag in `lib/app/config.dart`:

```dart
class AppConfig {
  static const bool useMockData = true; // false = real DHIS2 backend
}
```

Screens, providers, and navigation are identical either way — only the repository implementation changes.

### Offline & synchronization

Officer decisions are always written to a local **Drift** (SQLite) queue first. If the device is online, the app also attempts an immediate submission to the backend; if offline (or the submission fails), the decision stays queued and is retried automatically once connectivity is restored. This queue also doubles as the local screening history.

---

## Getting Started

### Prerequisites

- Flutter (stable channel, current SDK — see [Known Constraints](#known-constraints-important) below)
- Android SDK / an Android device or emulator
- A reachable AfyaMsafiri/DHIS2 instance URL (for real-backend testing)

### Setup

```bash
git clone <this-repo-url>
cd afyamsafiri_poe
flutter pub get
flutter run
```

### Configuration

- `lib/app/config.dart` — toggle `useMockData` (mock vs. real backend)
- `lib/app/dhis2_config.dart` — set the DHIS2/AfyaMsafiri base URL

---

## Known Constraints (important)

This project has a **hard dependency constraint**: the DHIS2 integration is built on `d2_touch`, whose own dependencies (`http`, `reflectable`) pin to older major versions. As a result:

- `google_fonts`, `intl`, and `package_info_plus` are pinned to **older versions** than their latest releases, to stay compatible with `d2_touch`.
- `build_runner` and `drift_dev` (code generators) are **not kept as permanent dependencies** — they conflict with `d2_touch`'s `reflectable` requirement. Generated files (`lib/main.reflectable.dart`, `lib/features/synchronization/data/local/app_database.g.dart`) are committed/generated ahead of time.

**If you need to regenerate code** (e.g. after changing the Drift schema, or Dart's reflection targets):

```bash
flutter pub add --dev build_runner:^2.4.9 reflectable:^4.0.6
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Then remove those two dev dependencies again and run `flutter pub get` before building the app normally — they must not remain installed alongside `d2_touch`.

---

## Project Status

| Phase | Description | Status |
|---|---|---|
| 0 | Foundation (theme, routing, session state) | ✅ Done |
| 1 | Scan flow (QR, manual entry, error states) | ✅ Done |
| 2 | Traveller record (mock data) | ✅ Done |
| 3 | Risk assessment logic | ✅ Done |
| 4 | Entry decision & confirmation | ✅ Done |
| 5 | Offline queue & auto-sync | ✅ Done |
| 6 | History & supervisor oversight | ✅ Done |
| 7 | Automated tests (risk & sync logic) | ⏳ Pending |
| 8 | Real DHIS2 integration via `d2_touch` | 🔨 In progress (auth working; traveller/risk/decision modules pending) |

---

## Roadmap

- [ ] Map authenticated DHIS2 `User` → application `Officer` (real name, role, assigned POE)
- [ ] Implement traveller lookup via `d2_touch` tracked entity instances
- [ ] Implement risk-country list via DHIS2 metadata (option set)
- [ ] Implement decision submission via `d2_touch` tracker/event functionality
- [ ] Unit tests for risk-matching and sync/retry logic
- [ ] Token-expiry handling during background sync

---

## Acknowledgements

- **AfyaMsafiri** — Tanzania Ministry of Health traveller health-surveillance system
- **[d2_touch](https://github.com/udsm-dhis2-lab/d2-touch)** — DHIS2 Flutter SDK by UDSM DHIS2 Lab

---

## License

Academic/practical-training project. License to be determined by the project team.
