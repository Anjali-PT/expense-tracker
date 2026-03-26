Create an API service client for "$ARGUMENTS".

1. Create `lib/services/{feature}_service.dart` with:
   - Import `dart:convert` and `package:http/http.dart`
   - Import `lib/core/env.dart` for `Env.apiBaseUrl`
   - Import the corresponding model from `lib/models/` if it exists
   - A class `{Feature}Service` with:
     - A base URL derived from `Env.apiBaseUrl`
     - Async methods for standard CRUD: `getAll`, `getById`, `create`, `update`, `delete`
     - Each method returns the appropriate model type or `List<Model>`
     - Basic error handling with try/catch
2. Create a Riverpod provider for the service using `@riverpod` annotation.
3. Run `dart run build_runner build --delete-conflicting-outputs`.
4. Run `dart analyze lib/services/` to confirm no issues.

Note: if `http` package is not in pubspec.yaml, add it first with `flutter pub add http`.
