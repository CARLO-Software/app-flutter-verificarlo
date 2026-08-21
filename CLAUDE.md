# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

VerifiCARLO Inspector — a Flutter mobile app for vehicle inspection mechanics in Peru. Spanish-language UI. Inspectors log in, receive inspection assignments via push notifications, fill checklists with photos/voice notes, and submit reports. Backend is a Laravel API at `verificarlo.com`.

Dart SDK: `^3.9.2` (supports patterns, records, class modifiers).

## Commands

```bash
flutter pub get          # install dependencies
flutter analyze          # static analysis (uses flutter_lints)
flutter test             # run all tests
flutter test test/widget_test.dart  # run single test
flutter run              # run on connected device/emulator
flutter build apk        # build Android release
dart run flutter_launcher_icons  # regenerate app icons after changing assets/images/icono_amarillo.png
```

## Architecture

**Layer pattern:** `core/` → `data/` → `presentation/`, dependencies flow inward.

- **State management:** Riverpod (`StateNotifier` + `StateNotifierProvider`). Providers live in `presentation/providers/`.
- **Routing:** GoRouter with auth redirect guard. Routes defined in `app.dart`. Shell route wraps the 4-tab navigation (Dashboard, Schedule, Notifications, Settings). `/inspection/:id` is a full-screen route outside the shell, receives `BookingModel` via `state.extra`. Auth redirect: `AuthStatus.unknown` → `/splash` (loading screen), unauthenticated → `/login`, authenticated redirects away from `/login` to `/`.
- **Network:** Singleton `ApiClient` wrapping Dio. Auto-attaches JWT from `SecureStorage`. All endpoints in `core/constants/api_endpoints.dart`.
- **Storage:** Two layers — `SecureStorage` (flutter_secure_storage) for JWT/user data, `LocalStorage` (Hive) for offline checklist backup and sync queue.
- **Offline sync:** `SyncService` queues failed report patches to Hive, retries on next launch or manual retry. `enqueueAndSync()` tries online first, falls back to queue.
- **Push notifications:** Firebase Cloud Messaging via `FcmService` singleton. Initialized before `runApp`. Registers device token with backend on login, unregisters on logout. Foreground messages with `type` containing "inspection" trigger `onInspectionReceived` callback.
- **Init order** (in `main.dart`, order matters): Firebase → FCM → date formatting (`es`) → Hive → `runApp`.

## Inspection Flow

`InspectionScreen` has 3 tabs (Info, Checklist, Summary).

- **Checklist items are hardcoded** in `data/models/checklist_models.dart`, not fetched from API. 4 categories: Legal (11 items), Mecánica (19), Carrocería (12), Interior (13).
- **`checklistProvider`** is `.family` parameterized by `reportId`. `ChecklistNotifier` debounces saves (500ms) to LocalStorage, then syncs to server via `SyncService`.
- **Max 5 photos per checklist item** (enforced in `ChecklistNotifier.addPhoto`).
- **Quick chips:** subcategory-level obs/defecto chips in `checklist_models.dart`, per-item chips override when populated.
- **Photos** handled by `PhotoController` using `image_picker`. Voice input via `speech_to_text`.

## Scoring & Verdict

Scoring logic lives in `core/services/checklist_service.dart` and `verdict_service.dart`:

- **Per-item:** OK = 100, Observación = 50, Defecto = 0. `noAplica` items excluded from scoring.
- **Category score:** `(OK×100 + OBS×50) / total_evaluated`. Any defecto → category is `NO_APROBADO`.
- **Category weights:** Legal 30%, Mecánica 40%, Carrocería 30%, Interior 0% (informational only).
- **Overall status:** worst of all category statuses.
- **Verdict override:** `VerdictService` — siniestro or km adulterado forces `NO_APROBADO` regardless of score.

## Key Conventions

- All API endpoints are string constants/static methods in `ApiEndpoints` — never hardcode URLs elsewhere. `nextApiKey` is hardcoded there (PDF generation service) — don't add more secrets to source; existing one is a known debt.
- Singletons use `static final _instance` pattern (`ApiClient`, `FcmService`).
- Models use `factory fromJson` / `toJson` pattern, no code generation.
- UI text is in Spanish — keep it consistent.
- `ponytail:` comments mark deliberate simplifications with upgrade paths.
- Peru-specific: timezone `America/Lima` (UTC-5), Peruvian holidays in `InspectionConstants`, weekday 8-slot and Saturday 4-slot schedule.
