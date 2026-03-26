Create a new screen view for "$ARGUMENTS".

1. Create `lib/views/{feature}_screen.dart` as a `ConsumerWidget` with:
   - A `Scaffold` with an `AppBar` titled with the human-readable feature name
   - A placeholder `body` with centered text saying "TODO: build {feature} UI"
   - Import `flutter_riverpod` for `ConsumerWidget` and `WidgetRef`
2. If a corresponding viewmodel exists at `lib/viewmodels/{feature}_viewmodel.dart`, import it and `ref.watch` its provider in the build method.
3. Run `dart analyze lib/views/` to confirm no issues.

Do NOT add a route — use `/add-route` for that.
Do NOT create a model or viewmodel — use `/scaffold` for the full MVVM triple.
