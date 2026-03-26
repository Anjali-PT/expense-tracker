Create minimal MVVM files for a new feature named "$ARGUMENTS".

Create the following files (replace `feature` with the feature name in snake_case):

1. `lib/models/{feature}.dart` — Data class with `@JsonSerializable()`, `fromJson`, `toJson`, `copyWith`. Include `part '{feature}.g.dart'`.

2. `lib/views/{feature}_screen.dart` — `ConsumerWidget` with a `Scaffold`, `AppBar` with the feature title, and a placeholder body.

3. `lib/viewmodels/{feature}_viewmodel.dart` — `@riverpod` annotated `Notifier` class with an empty list as initial state and basic `add`/`remove` methods. Include `part '{feature}_viewmodel.g.dart'`.

After creating the files, run: `dart run build_runner build --delete-conflicting-outputs`

Do NOT add a route to `router.dart` — the user will wire it up manually.
