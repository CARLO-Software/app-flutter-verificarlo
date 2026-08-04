# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

VerifiCARLO Inspector — a Flutter mobile app for vehicle inspection mechanics. Spanish-language UI. Inspectors log in, receive inspection assignments via push notifications, fill checklists with photos/voice notes, and submit reports. Backend is a Laravel API at `verificarlo.com`.

## Commands

```bash
flutter pub get          # install dependencies
flutter analyze          # static analysis (uses flutter_lints)
flutter test             # run all tests
flutter test test/widget_test.dart  # run single test
flutter run              # run on connected device/emulator
flutter build apk        # build Android release
```

## Architecture

**Layer pattern:** `core/` → `data/` → `presentation/`, dependencies flow inward.

- **State management:** Riverpod (`StateNotifier` + `StateNotifierProvider`). Providers live in `presentation/providers/`.
- **Routing:** GoRouter with auth redirect guard. Routes defined in `app.dart`. Shell route wraps the 4-tab navigation (Dashboard, Schedule, Notifications, Settings). `/inspection/:id` is a full-screen route outside the shell, receives `BookingModel` via `state.extra`.
- **Network:** Singleton `ApiClient` wrapping Dio. Auto-attaches JWT from `SecureStorage`. 401 responses auto-clear the session (except `/devices/` endpoints). All endpoints in `core/constants/api_endpoints.dart`.
- **Storage:** Two layers — `SecureStorage` (flutter_secure_storage) for JWT/user data, `LocalStorage` (Hive) for offline checklist backup and sync queue.
- **Offline sync:** `SyncService` queues failed report patches to Hive, retries on next launch or manual retry. `enqueueAndSync()` tries online first, falls back to queue.
- **Push notifications:** Firebase Cloud Messaging via `FcmService` singleton. Initialized before `runApp`. Registers device token with backend on login, unregisters on logout. Foreground messages with `type` containing "inspection" trigger `onInspectionReceived` callback.
- **Inspection flow:** `InspectionScreen` has 3 tabs (Info, Checklist, Summary). `ChecklistController` manages section/item state. Photos handled by `PhotoController` using `image_picker`. Voice input via `speech_to_text`.

## Key Conventions

- All API endpoints are string constants/static methods in `ApiEndpoints` — never hardcode URLs elsewhere.
- Singletons use `static final _instance` pattern (`ApiClient`, `FcmService`).
- Models use `factory fromJson` / `toJson` pattern, no code generation.
- UI text is in Spanish — keep it consistent.
- `ponytail:` comments mark deliberate simplifications with upgrade paths.
