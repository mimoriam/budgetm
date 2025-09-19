# Project Debug Rules (Non-Obvious Only)
- Debugging `print()` statements are explicitly allowed due to the disabled `avoid_print` lint rule.
- Error handling consistently uses try/catch blocks, especially in service layers, with specific Firebase exception handling.
- `flutter pub run build_runner build` is critical for regenerating database code after schema changes; issues here can lead to runtime errors.