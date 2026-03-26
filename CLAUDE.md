# Expense Tracker

Personal expense tracking app built with Flutter.

## Development Environment

| Tool | Version | Notes |
|------|---------|-------|
| Flutter | 3.38.5 (stable) | Dart 3.10.4 |
| Xcode | 26.2 | Build 17C52 |
| Python | 3.9.6 | For FastAPI backend |
| macOS | Darwin 25.2.0 | Apple Silicon (arm64) |

### Devices
- **iPhone 17 Pro Max** (simulator) — `FE8EF8FB-0495-4F92-A305-C8BCCF864E29` (primary test device)
- **iPhone 17 Pro** (simulator) — `DB8B8980-55B9-4AD4-AF4B-B6ABE8DD7719`

### Network
- **LAN IP**: `192.168.3.27` (use this, NEVER use `localhost` for device targets)
- Physical devices cannot resolve `localhost` — always use LAN IP or `10.0.2.2` (Android emulator)

## Run Commands

```bash
# Backend
cd backend && .venv/bin/uvicorn main:app --host 0.0.0.0 --port 8080 --reload

# iOS Simulator (can use localhost)
flutter run -d FE8EF8FB --dart-define=API_BASE_URL=http://localhost:8080

# Physical iOS device (MUST use LAN IP)
flutter run --dart-define=API_BASE_URL=http://192.168.3.27:8080

# Android Emulator (use 10.0.2.2 for host loopback)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

## Architecture

- **Pattern**: MVVM — models, views, viewmodels
- **State management**: Riverpod with codegen (`@riverpod` annotations)
- **Routing**: GoRouter with `StatefulShellRoute` for bottom nav (`lib/core/router.dart`)
- **Backend**: Python FastAPI + SQLite (`backend/`)
- **HTTP**: `package:http` for API calls
- **Serialization**: `json_serializable` (not freezed)
- **Charts**: `fl_chart` for pie/bar charts

## Project Structure

```
lib/
  core/          — env, constants, theme, router, categories
  models/        — data classes with json_serializable
  viewmodels/    — Riverpod async Notifiers
  views/         — ConsumerWidget screens + app_shell (bottom nav)
  services/      — HTTP API clients
  repositories/  — Hive persistence (when needed)
backend/
  main.py        — FastAPI app (expenses, budgets, recurring, stats)
  models.py      — Pydantic request/response schemas
  database.py    — SQLite setup
test/
  core/          — categories, constants, theme tests
  models/        — serialization/copyWith tests for all models
  views/         — widget tests for all screens
  services/      — service unit tests
  backend/       — Python API integration tests
```

## Code Generation

After changing models or viewmodels with `@riverpod` or `@JsonSerializable` annotations:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated files (`*.g.dart`) are gitignored and excluded from analyzer.

## Assets

- Images in `assets/images/`, icons in `assets/icons/`
- **PNG only** — no SVGs (avoids `flutter_svg` dependency and related issues)
- Register new asset folders in `pubspec.yaml` under `flutter.assets`

## Environment Config

- `lib/core/env.dart` reads `--dart-define` values at compile time
- `.env.development` / `.env.production` hold the values
- Default API URL uses **LAN IP** (`192.168.3.27`), not `localhost`
- For `--dart-define-from-file`, create a `.env` file and pass via: `flutter run --dart-define-from-file=.env.development`

## Testing

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Single test file
flutter test test/views/home_screen_test.dart

# Backend API tests (requires running backend)
python3 test/backend/api_test.py
```

- **56 tests** across 13 files (models, core, views, services, backend)
- Wrap app with `ProviderScope` in widget tests
- Override async providers with fake implementations in tests
- Use unique `heroTag` on FABs in screens within `StatefulShellRoute`

## Analysis

```bash
dart analyze lib/
```

Target: **zero issues**. Strict lint rules enabled in `analysis_options.yaml` including:
- `type_annotate_public_apis`, `avoid_dynamic_calls`, `avoid_print`
- `prefer_const_constructors`, `prefer_final_locals`
- Generated files excluded from analysis

## Backend

Python FastAPI server in `backend/` with SQLite storage.

```bash
# Setup (first time)
cd backend
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt

# Run (binds to all interfaces for device access)
.venv/bin/uvicorn main:app --host 0.0.0.0 --port 8080 --reload
```

### Endpoints
| Group | Endpoints |
|-------|-----------|
| Expenses | `GET/POST /api/expenses`, `GET/PUT/DELETE /api/expenses/{id}` |
| Stats | `GET /api/stats/monthly?year=&month=`, `GET /api/stats/trend?months=` |
| Budgets | `GET/POST /api/budgets`, `PUT/DELETE /api/budgets/{id}` |
| Recurring | `GET/POST /api/recurring`, `PUT/DELETE /api/recurring/{id}`, `POST /api/recurring/{id}/trigger` |

- API docs at `http://localhost:8080/docs`
- Search/filter: `GET /api/expenses?search=&category=&from_date=&to_date=`
- Database `expenses.db` is gitignored

## Custom Commands

| Command | Purpose |
|---------|---------|
| `/new-project <name>` | Bootstrap a complete Flutter project with MVVM + Riverpod |
| `/scaffold <feature>` | Create model + view + viewmodel for a new feature |
| `/add-route <feature>` | Wire a screen into GoRouter |
| `/add-screen <feature>` | Create just a ConsumerWidget screen |
| `/add-model <feature>` | Create just a json_serializable model |
| `/add-repo <feature>` | Create a Hive repository + provider |
| `/add-service <feature>` | Create an HTTP API service client |
| `/add-test <feature>` | Create a widget test for a screen |
| `/check` | Run analyze + test + build_runner |

## Hooks (auto-run)

- **After Write/Edit**: `dart analyze lib/` runs automatically to catch issues immediately
- **After Commit**: `flutter test` runs automatically to verify nothing broke

## Key Decisions

- FastAPI + SQLite for backend — simple, auto-docs, zero config DB
- json_serializable over freezed — lighter, manual copyWith
- Riverpod codegen — compile-time safety, recommended approach
- LAN IP in .env default — prevents localhost-on-device issues
- PNG only for assets — avoids flutter_svg dependency issues
- Unique heroTag on FABs — prevents conflicts in StatefulShellRoute
- Strict analysis_options.yaml — catches issues at edit time via hooks

## Common Pitfalls to Avoid

1. **Never use `localhost`** for physical device API URLs — use LAN IP
2. **Always run `build_runner`** after changing `@riverpod` or `@JsonSerializable` annotated files
3. **Always add unique `heroTag`** to FABs in screens inside bottom nav shell
4. **Suppress `deprecated_member_use_from_same_package`** on Riverpod functional provider Ref types (v2.x limitation)
5. **Use `initialValue` not `value`** on `DropdownButtonFormField` (deprecated in Flutter 3.33+)
6. **Python 3.9 compatibility** — use `Optional[str]` not `str | None` in backend models
