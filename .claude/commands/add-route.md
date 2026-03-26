Add a new route to the GoRouter config for "$ARGUMENTS".

1. Read `lib/core/router.dart` to understand the current route structure.
2. Add a new `GoRoute` entry with:
   - `path`: derive from the feature name (e.g., feature "add_expense" → path "/add-expense")
   - `builder`: import and return the corresponding screen widget from `lib/views/{feature}_screen.dart`
3. Verify the screen file exists before adding the import. If it doesn't exist, tell the user to run `/scaffold {feature}` first.
4. Run `dart analyze lib/core/router.dart` to confirm no issues.

Do NOT create any new files — only modify `router.dart`.
