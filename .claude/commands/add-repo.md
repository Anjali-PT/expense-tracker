Create a Hive repository for "$ARGUMENTS".

1. Read the corresponding model at `lib/models/{feature}.dart` to understand its fields. If the model doesn't exist, tell the user to create it first with `/add-model`.
2. Create `lib/repositories/{feature}_repository.dart` with:
   - Import `hive_flutter` and the model
   - A class `{Feature}Repository` with methods:
     - `Future<void> init()` — opens the Hive box
     - `List<{Model}> getAll()` — returns all items from the box
     - `Future<void> add({Model} item)` — puts item in box keyed by `item.id`
     - `Future<void> delete(String id)` — deletes by key
     - `Future<void> update({Model} item)` — puts updated item
   - Use box name from `AppConstants` or derive from model name
3. Create a Riverpod provider for the repository in the same file using `@riverpod` annotation.
4. Run `dart run build_runner build --delete-conflicting-outputs` to generate the `.g.dart` file.
5. Run `dart analyze lib/repositories/` to confirm no issues.
