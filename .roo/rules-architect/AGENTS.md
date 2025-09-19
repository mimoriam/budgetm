# Project Architecture Rules (Non-Obvious Only)
- The application employs a layered persistence strategy combining `SharedPreferences`, Firebase, and Drift for different data needs.
- The `AuthGate` component orchestrates a complex user onboarding and authentication flow.
- State management is highly granular, utilizing multiple specialized `ChangeNotifierProvider` instances.
- The strong reliance on Drift implies an architectural consideration for offline capabilities.
- The `Transactions` model in [`lib/data/local/models/transaction_model.dart`](lib/data/local/models/transaction_model.dart) is extended with custom fields, indicating specific domain requirements.