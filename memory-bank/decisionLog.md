# Decision Log

This file records architectural and implementation decisions using a list format.
2025-09-17 07:16:45 - Log of updates made.

*

## Decision

*

## Rationale 

*

## Implementation Details

*
2025-09-17 07:28:0 - Initial project analysis completed. No major architectural decisions required at this stage. The project structure is well-organized with clear separation of concerns between models, views, and view models. The use of Provider for state management and SharedPreferences for local storage is appropriate for this type of application.
2025-09-17 10:09:00 - Implemented logout functionality in ProfileScreen using FirebaseAuthService. Added import, instantiated service, and implemented signOut() method with proper navigation to AuthGate.
[2025-09-17 10:20:45] - Fixed onboarding screen repeatedly popping up issue. Made SharedPreferences access consistent across the project by changing all instances from SharedPreferencesAsync to SharedPreferences.getInstance() in main.dart, onboarding_screen.dart, and theme_provider.dart. This ensures immediate synchronization of SharedPreferences values.
[2025-09-17 10:34:00] - Added circular progress indicators to authentication buttons in login, signup, and forgot password screens. Implemented loading state management for all authentication operations to prevent multiple submissions and provide visual feedback to users.
2025-09-17 11:15:59 - Removed CircularProgressIndicator from AuthGate during initial onboarding check to avoid showing a loading indicator before the onboarding status is determined.
[2025-09-17 11:18:0] - Enabled Firebase Authentication local persistence by adding FirebaseAuth.instance.setPersistence(Persistence.LOCAL) in main.dart after Firebase initialization. This ensures user authentication state is persisted across app restarts.
2025-09-17 11:45:40 - Modified login screen to use separate loading states for Google Sign-In and Email/Password login, added mounted checks for setState calls, and implemented circular progress indicators for both authentication methods.
[2025-09-17 16:52:00] - [Optimized AuthGate to reduce unnecessary CircularProgressIndicator during navigation by implementing authentication state caching]
[2025-09-18 09:08:51] - Added sqlite3_flutter_libs to dependencies in pubspec.yaml for Drift database integration
[2025-09-18 10:15:05] - Extended TransactionModel to include all fields from Add Transaction screen. Added accountId, time, repeat, remind, icon, color, notes, and paid fields. Updated AppDatabase with schema version 2 and migration strategy to add these columns to the existing transactions table.
[2025-09-18 1:18:00] - Fixed "table 'accounts' has more than one primary key" error by removing redundant PRIMARY KEY declaration in account_model.dart and updating app_database.dart schema version
[2025-09-18 16:42:00] - Implemented automatic refresh of home screen after adding income/expense transactions. Created HomeScreenProvider to manage refresh state and modified MainScreen to await results from AddTransactionScreen and trigger home screen refresh when transactions are successfully added.
[2025-09-18 16:45:00] - Fixed critical "Error saving transaction: type 'Null' is not a subtype of type 'DateTime' in type cast" error in add_transaction_screen.dart. Implemented default DateTime value (DateTime.now()) for date field when "more" options are not expanded, ensuring transactions can be saved without explicitly setting date/time.
2025-09-18 12:40:08 - Modified HomeScreen to enable independent scrolling of transaction list while keeping app bar fixed
[2025-09-18 12:45:00] - Implemented navigation from HomeScreen to ExpenseDetailScreen when a transaction is tapped. Added a helper function to convert database Transaction model to UI Transaction model for proper data passing between screens.
[2025-09-18 17:57:49] - Implemented delete functionality in ExpenseDetailScreen. Modified UI Transaction model to include database transaction ID, updated home screen to pass this ID to ExpenseDetailScreen, and converted ExpenseDetailScreen to StatefulWidget with delete implementation.
[2025-09-18 18:55:00] - Modified home screen layout to ensure scrollable background card expands to fill available vertical space. Implemented LayoutBuilder, ConstrainedBox, and IntrinsicHeight to force the white card background to expand even when empty.
[2025-09-18 19:05:00] - Added top padding to the appbar in home.dart to separate it from the status bar. Used MediaQuery.of(context).padding.top to dynamically calculate the status bar height and added it as top padding to the appbar container.
[2025-09-18 19:21:0] - Fixed issue with home screen refresh loading data for current month instead of selected month. Modified _refreshData() method in home.dart to use month-specific data loading methods (_loadIncomeAndExpensesForMonth, _loadTransactionsForMonth, _loadUpcomingTasksForMonth) with _months[_selectedMonthIndex] parameter instead of generic methods that always loaded current month data.
2025-09-18 14:40:00 - Implemented singleton pattern for AppDatabase to prevent multiple instances and race conditions