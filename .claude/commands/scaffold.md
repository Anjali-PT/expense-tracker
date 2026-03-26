Create minimal MVVM files for a new feature named "$ARGUMENTS".

## Rules
- Create ONLY the 3 files listed below — nothing extra
- Follow existing code patterns in the project
- Use `@JsonSerializable()` for models, `@riverpod` for viewmodels
- Suppress `deprecated_member_use_from_same_package` on functional provider Ref types
- Do NOT add routes — user wires those up via `/add-route`
- Do NOT create services or repositories — user adds those via `/add-service` or `/add-repo`

## Files to create (replace `{feature}` with snake_case name)

### 1. `lib/models/{feature}.dart`
- `@JsonSerializable()` class with `id` (String) + sensible fields inferred from name
- `part '{feature}.g.dart'`
- `fromJson`, `toJson`, `copyWith`

### 2. `lib/views/{feature}_screen.dart`
- `ConsumerWidget` with `Scaffold`, `AppBar` titled with feature name
- Unique `heroTag` on any FAB (use `'{feature}_fab'`)
- Placeholder body

### 3. `lib/viewmodels/{feature}_viewmodel.dart`
- `@riverpod` annotated `Notifier` with `Future<List<{Model}>>` return type
- `part '{feature}_viewmodel.g.dart'`
- Methods: `build()`, `add()`, `remove()`

## After creating files
```
dart run build_runner build --delete-conflicting-outputs
dart analyze lib/
```
Verify zero issues before finishing.
