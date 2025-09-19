# Project Coding Rules (Non-Obvious Only)
- Custom conversion logic for database to UI models is in `_convertToUiTransaction` in [`lib/screens/dashboard/navbar/home.dart`](lib/screens/dashboard/navbar/home.dart).
- The database access follows a singleton pattern implemented in [`lib/data/local/app_database.dart`](lib/data/local/app_database.dart).
- Screen refreshes are coordinated via `HomeScreenProvider` in [`lib/viewmodels/home_screen_provider.dart`](lib/viewmodels/home_screen_provider.dart), which requires specific refresh cycle management.
- The `Transactions` table in [`lib/data/local/models/transaction_model.dart`](lib/data/local/models/transaction_model.dart) has extended fields beyond basic transaction data for scheduling, UI customization, and payment status.
- `print()` statements are allowed as the `avoid_print` lint rule is disabled.
- Both single and double quotes are permitted for string literals as `prefer_single_quotes` is disabled.