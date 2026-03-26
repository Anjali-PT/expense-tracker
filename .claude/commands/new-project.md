Bootstrap a complete Flutter project named "$ARGUMENTS" with the standard MVVM + Riverpod architecture.

## Steps

### 1. Create the Flutter project
```
flutter create --org com.wac $ARGUMENTS
cd $ARGUMENTS
```

### 2. Add dependencies to pubspec.yaml
Dependencies: `flutter_riverpod`, `riverpod_annotation`, `go_router`, `hive_flutter`, `intl`, `json_annotation`, `http`, `fl_chart`
Dev: `riverpod_generator`, `build_runner`, `json_serializable`
Add asset folders: `assets/images/`, `assets/icons/`

### 3. Create folder structure
```
lib/
  core/env.dart          — String.fromEnvironment wrapper for API_BASE_URL
  core/constants.dart    — App name, currency, Hive box name
  core/theme.dart        — Material 3 light/dark themes with green seed color (#2E7D32)
  core/router.dart       — GoRouter with home route
  models/                — (empty, ready for features)
  viewmodels/            — (empty, ready for features)
  views/home_screen.dart — ConsumerWidget with AppBar, empty state, and FAB
  services/.gitkeep
  repositories/.gitkeep
```

### 4. Rewrite main.dart
`ProviderScope` → `MaterialApp.router` → GoRouter → HomeScreen

### 5. Setup config files
- `.gitignore` — add `.env.*`, `*.g.dart`, `*.freezed.dart`, `backend/*.db`, `backend/__pycache__/`, `backend/.venv/`
- `.env.development` — `API_BASE_URL=http://192.168.3.27:8080`
- `.env.production` — `API_BASE_URL=https://api.example.com`
- `.env.development.example` — committed template

### 6. Setup analysis_options.yaml
Include strict lint rules: `prefer_single_quotes`, `prefer_const_constructors`, `type_annotate_public_apis`, `avoid_print`, `avoid_dynamic_calls`, `always_declare_return_types`, etc.
Exclude `**/*.g.dart` and `**/*.freezed.dart` from analyzer.

### 7. Create test
Minimal smoke test wrapping app in `ProviderScope`.

### 8. Run setup
```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 9. Generate CLAUDE.md
Analyze the created codebase and generate a CLAUDE.md with: architecture, project structure, code generation commands, asset rules (PNG only), environment config (LAN IP not localhost), testing, analysis, and key decisions.

### 10. Verify
```
dart analyze lib/  — zero issues
flutter test       — all pass
```

## Rules
- **PNG only** for assets — no SVGs
- **LAN IP** (not localhost) in .env defaults — physical devices can't resolve localhost
- **Minimal files** — only create what's listed above, nothing extra
- Do NOT open VS Code — user will do that
- Do NOT create a backend — user will add that separately if needed
