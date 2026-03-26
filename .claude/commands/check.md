Run the full project health check.

Execute the following in order and report results:

1. `dart analyze lib/` — expect zero issues
2. `flutter test` — expect all tests pass
3. `dart run build_runner build --delete-conflicting-outputs` — ensure generated files are up to date

Report a summary with pass/fail for each step. If any step fails, show the relevant error output and suggest a fix.
