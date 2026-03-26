Create a widget test for "$ARGUMENTS".

1. Read the screen at `lib/views/{feature}_screen.dart` to understand what it renders.
2. Create `test/{feature}_test.dart` with:
   - Import `flutter_test`, `flutter_riverpod`, and the screen widget
   - A `testWidgets` smoke test that:
     - Wraps the screen in `ProviderScope` and `MaterialApp` (or `MaterialApp.router` if navigation is involved)
     - Calls `pumpWidget` and `pumpAndSettle`
     - Verifies the screen title text is present
     - Verifies key interactive elements (FAB, buttons) are present
3. Run `flutter test test/{feature}_test.dart` to verify the test passes.

Keep tests minimal — smoke-level. Only test that the widget renders without errors and key elements are present.
