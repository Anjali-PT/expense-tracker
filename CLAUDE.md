# Expense Tracker

Personal expense tracking app built with Flutter.

## Architecture

- **Pattern**: MVVM — models, views, viewmodels
- **State management**: Riverpod with codegen (`@riverpod` annotations)
- **Routing**: GoRouter (declarative, `lib/core/router.dart`)
- **Backend**: Python FastAPI + SQLite (`backend/`)
- **HTTP**: `package:http` for API calls
- **Serialization**: `json_serializable` (not freezed)

## Project Structure

```
lib/
  core/        — env, constants, theme, router
  models/      — data classes with json_serializable
  viewmodels/  — Riverpod Notifiers
  views/       — ConsumerWidget screens
  services/    — API clients (when needed)
  repositories/ — Hive persistence (when needed)
```

## Code Generation

After changing models or viewmodels with annotations:
```
dart run build_runner build --delete-conflicting-outputs
```

Generated files (`*.g.dart`) are gitignored.

## Assets

- Put images in `assets/images/`, icons in `assets/icons/`
- **PNG only** — no SVGs (avoids extra dependencies)
- Register new asset folders in `pubspec.yaml` under `flutter.assets`

## Environment Config

- `lib/core/env.dart` reads `--dart-define` values at compile time
- `.env.development` / `.env.production` hold the values
- Default API URL uses LAN IP (192.168.1.x), not localhost — physical devices can't resolve localhost
- Pass env vars: `flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8080`

## Testing

```
flutter test
```

- Smoke tests go in `test/widget_test.dart`
- Wrap app with `ProviderScope` in tests when testing Riverpod consumers

## Analysis

```
dart analyze lib/
```

Target: zero issues.

## Backend

Python FastAPI server in `backend/` with SQLite storage.

```bash
# Setup (first time)
cd backend
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt

# Run
cd backend
.venv/bin/uvicorn main:app --host 0.0.0.0 --port 8080 --reload
```

- API docs available at `http://localhost:8080/docs`
- Endpoints: `GET/POST /api/expenses`, `GET/PUT/DELETE /api/expenses/{id}`
- Database file `expenses.db` is gitignored

## Key Decisions

- FastAPI + SQLite for backend — simple, auto-docs, zero config DB
- json_serializable over freezed — lighter, manual copyWith
- Riverpod codegen — compile-time safety, recommended approach
- LAN IP in .env default — prevents localhost-on-device issues
