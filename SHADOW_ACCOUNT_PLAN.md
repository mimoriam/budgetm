# Shadow Default Cash Account Implementation Plan

This document outlines the detailed steps required to implement a "shadow" default cash account feature. This account will be automatically created for new users upon sign-up, remain hidden from the user interface, and all initial transactions will be associated with it until the user creates their own account.

## 1. Core Data Model Changes

The `FirestoreAccount` model already includes an `isDefault` boolean field, which is ideal for identifying the shadow account. No changes are required to the `FirestoreAccount` model itself.

## 2. Default Account Creation upon Sign-up

The shadow account needs to be created when a new user signs up. The `SelectCurrencyScreen` is identified as the correct place for this logic.

### File: [`lib/screens/auth/first_time_settings/select_currency_screen.dart`](lib/screens/auth/first_time_settings/select_currency_screen.dart)

**Objective**: Ensure the `createDefaultAccountIfNeeded` method is called with `isDefault: true` and appropriate default values.

**Proposed Changes**:
Modify the `_firestoreService.createDefaultAccountIfNeeded` call within the `onPressed` callback of the "Continue" button (around line 209). The existing implementation already sets `isDefault: true` and uses "None" as the name, which aligns with the "hidden" requirement.

```dart
// Original (already sets isDefault: true and name: 'None')
await _firestoreService.createDefaultAccountIfNeeded(
  _selectedCurrency!.code,
  _selectedCurrency!.symbol,
);
```

### File: [`lib/services/firestore_service.dart`](lib/services/firestore_service.dart)

**Objective**: Verify and ensure the `createDefaultAccountIfNeeded` method correctly creates an account marked as default.

**Proposed Changes**:
The `createDefaultAccountIfNeeded` method (lines 741-766) already sets `isDefault: true` and `name: 'None'`. This is suitable for a hidden shadow account. No direct changes are needed here, but it's important to understand its role.

```dart
// Excerpt from lib/services/firestore_service.dart
Future<void> createDefaultAccountIfNeeded(String currencyCode, String currencySymbol) async {
  try {
    final defaultId = 'default_cash';
    final docRef = _accountsCollection.doc(defaultId);

    await _firestore.runTransaction((t) async {
      final snap = await t.get(docRef);
      if (!snap.exists) {
        final defaultAccount = FirestoreAccount(
          id: defaultId,
          name: 'None', // This name makes it "hidden" from user selection
          accountType: 'Cash',
          balance: 0.0,
          description: 'Default $currencyCode account',
          color: 'green',
          icon: 'account_balance_wallet',
          currency: currencyCode,
          isDefault: true, // Crucial for identifying the shadow account
        );
        t.set(docRef, defaultAccount);
        print('Created default Cash account for new user with currency: $currencyCode');
      } else {
        print('Default account already exists, skipping creation');
      }
    });
  } catch (e) {
    print('Error in createDefaultAccountIfNeeded: $e');
    rethrow;
  }
}
```

## 3. Transaction List in `home.dart`

**Objective**: Hide the account name and type for any transaction associated with the default account in the transaction list.

### File: [`lib/screens/dashboard/navbar/home.dart`](lib/screens/dashboard/navbar/home.dart)

**Proposed Changes**:
Locate the `_buildTransactionItem` widget (around line 844). Inside this widget, the account name and type are displayed using `transactionWithAccount.account?.name` and `transactionWithAccount.account?.accountType`. Add a conditional check for `isDefault`.

```dart
// Inside _buildTransactionItem, around line 909
// Original:
// Text(
//   [account?.name, account?.accountType]
//       .where((text) => text != null && text.isNotEmpty)
//       .join(' - '),
//   style: const TextStyle(color: Colors.grey, fontSize: 12),
// ),

// Modified:
if (account != null && !(account.isDefault ?? false)) { // Check if account is not default
  Text(
    [account.name, account.accountType]
        .where((text) => text != null && text.isNotEmpty)
        .join(' - '),
    style: const TextStyle(color: Colors.grey, fontSize: 12),
  ),
} else {
  // Optionally display a generic message or an empty SizedBox
  const SizedBox.shrink(), // Hide completely
}
```

## 4. Transaction Detail Screen

**Objective**: Do not display the account name and type if the transaction belongs to the default account.

### File: [`lib/screens/dashboard/navbar/home/expense_detail/expense_detail_screen.dart`](lib/screens/dashboard/navbar/home/expense_detail/expense_detail_screen.dart)

**Proposed Changes**:
Locate the `FutureBuilder<FirestoreAccount?>` (around line 92) which is responsible for displaying the account details. Add a conditional check within its `builder` method.

```dart
// Inside FutureBuilder<FirestoreAccount?>, around line 102
// Original:
// return Text(
//   "${snapshot.data!.name} - ${snapshot.data!.accountType}",
//   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//         color: AppColors.secondaryTextColorLight,
//       ),
// );

// Modified:
if (snapshot.hasData && snapshot.data != null && !(snapshot.data!.isDefault ?? false)) {
  return Text(
    "${snapshot.data!.name} - ${snapshot.data!.accountType}",
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.secondaryTextColorLight,
        ),
  );
} else {
  return const SizedBox.shrink(); // Hide completely
}
```

## 5. Balance Screen

**Objective**:
*   Do not display the default account in the list of accounts.
*   Exclude transactions from the default account when calculating the data for the pie chart.

### File: [`lib/screens/dashboard/navbar/balance/balance_screen.dart`](lib/screens/dashboard/navbar/balance/balance_screen.dart)

**Proposed Changes**:

#### 5.1. Exclude Default Account from Account List

Locate the `_tryEmitCombined` method (around line 98). This method processes accounts and transactions. Filter out default accounts before they are added to `accountsWithData`.

```dart
// Inside _tryEmitCombined, around line 117
// Original:
// final accountsWithData = _latestAccounts!.map((account) {
//   return {
//     'account': account,
//     'transactionsAmount': transactionAmounts[account.id] ?? 0.0,
//   };
// }).toList();

// Modified:
final accountsWithData = _latestAccounts!
    .where((account) => !(account.isDefault ?? false)) // Filter out default accounts
    .map((account) {
  return {
    'account': account,
    'transactionsAmount': transactionAmounts[account.id] ?? 0.0,
  };
}).toList();
```

#### 5.2. Exclude Transactions from Default Account in Pie Chart Calculation

The `showingSections` method (around line 329) uses `accountsWithData` to generate pie chart sections. Since `accountsWithData` will now be filtered, the pie chart will automatically exclude default accounts. However, the `transactionAmounts` map (around line 102) also needs to exclude transactions from default accounts.

```dart
// Inside _tryEmitCombined, around line 102
// Original:
// for (var transaction in transactions) {
//   final accId = transaction.accountId;
//   if (accId == null) continue;
//   final isIncome =
//       transaction.type != null &&
//       transaction.type.toString().toLowerCase().contains('income');
//   final txnAmount = isIncome ? transaction.amount : -transaction.amount;
//   transactionAmounts.update(
//     accId,
//     (value) => value + txnAmount,
//     ifAbsent: () => txnAmount,
//   );
// }

// Modified:
// First, get all accounts to identify the default one
final allAccounts = _latestAccounts!;
final defaultAccountIds = allAccounts.where((acc) => acc.isDefault ?? false).map((acc) => acc.id).toSet();

for (var transaction in transactions) {
  final accId = transaction.accountId;
  if (accId == null || defaultAccountIds.contains(accId)) continue; // Skip if no account or if it's a default account

  final isIncome =
      transaction.type != null &&
      transaction.type.toString().toLowerCase().contains('income');
  final txnAmount = isIncome ? transaction.amount : -transaction.amount;
  transactionAmounts.update(
    accId,
    (value) => value + txnAmount,
    ifAbsent: () => txnAmount,
  );
}
```

## 6. Add Transaction Screen

**Objective**:
*   If the only account available is the default account, hide the account selector dropdown.
*   If a user creates their own account, the default account should stop showing up for selection. The new user-created account will automatically be used for future transactions and would be the default in the add transaction screen.

### File: [`lib/screens/dashboard/navbar/home/transaction/add_transaction_screen.dart`](lib/screens/dashboard/navbar/home/transaction/add_transaction_screen.dart)

**Proposed Changes**:

#### 6.1. Modify `_loadAccounts` to handle default account selection and filtering

```dart
// Inside _loadAccounts, around line 45
// Original:
// final accounts = await _firestoreService.getAllAccounts();
//
// // Find the default account or select the first one
// final defaultAccount = accounts.firstWhere(
//   (account) => account.isDefault == true,
//   orElse: () => accounts.first,
// );
//
// setState(() {
//   _accounts = accounts;
//   _selectedAccountId = defaultAccount.id;
// });
// _formKey.currentState?.patchValue({'account': defaultAccount.id});

// Modified:
final allAccounts = await _firestoreService.getAllAccounts();
final nonDefaultAccounts = allAccounts.where((account) => !(account.isDefault ?? false)).toList();
final defaultAccount = allAccounts.firstWhereOrNull((account) => account.isDefault ?? false);

setState(() {
  if (nonDefaultAccounts.isNotEmpty) {
    // If user has created accounts, only show those.
    _accounts = nonDefaultAccounts;
    _selectedAccountId = nonDefaultAccounts.first.id;
  } else if (defaultAccount != null) {
    // If only the default account exists, use it but don't show it in the dropdown.
    _accounts = []; // Empty list to hide dropdown
    _selectedAccountId = defaultAccount.id;
  } else {
    // No accounts exist at all.
    _accounts = [];
    _selectedAccountId = null;
  }
});

if (_selectedAccountId != null) {
  _formKey.currentState?.patchValue({'account': _selectedAccountId});
}
```
*Note: You might need to import `package:collection/collection.dart` for `firstWhereOrNull`.*

#### 6.2. Conditionally Render Account Selector

Locate the `_buildFormSection` for 'Account' (around line 307). Wrap the `GestureDetector` with a conditional check.

```dart
// Inside _buildFormSection for 'Account', around line 318
// Original:
// GestureDetector(
//   onTap: () async { ... },
//   child: Container(...)
// )

// Modified:
if (_accounts.isNotEmpty) { // Only show dropdown if there are user-created accounts
  GestureDetector(
    onTap: () async {
      final selectedAccount = _accounts.firstWhere(
        (acc) => acc.id == _selectedAccountId,
        orElse: () => _accounts.first,
      );

      final result = await _showSelectionBottomSheet<FirestoreAccount>(
        title: 'Select Account',
        items: _accounts,
        selectedItem: selectedAccount,
        getDisplayName: (account) => account.name,
      );

      if (result != null) {
        setState(() {
          _selectedAccountId = result.id;
        });
        field.didChange(result.id);
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 16.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(
          color: field.hasError
              ? AppColors.errorColor
              : Colors.grey.shade300,
          width: field.hasError ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _selectedAccountId != null
                  ? (_accounts.firstWhere(
                      (acc) => acc.id == _selectedAccountId,
                      orElse: () => _accounts.first,
                    ).name)
                  : 'Select',
              style: TextStyle(
                fontSize: 13,
                color: _selectedAccountId != null
                    ? AppColors.primaryTextColorLight
                    : AppColors.lightGreyBackground,
              ),
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: Colors.grey.shade600,
          ),
        ],
      ),
    ),
  );
} else {
  // If _accounts is empty, it means either only the default account exists or no accounts exist.
  // In either case, we don't show a dropdown.
  // The _selectedAccountId is already set to the default account if it exists.
  // We can show a disabled-looking field or nothing at all.
  const SizedBox.shrink();
}
```

#### 6.3. Ensure `_selectedAccountId` is correctly set in `_saveTransaction`

The `_saveTransaction` method (around line 797) already uses `_selectedAccountId`. With the modifications in `_loadAccounts`, `_selectedAccountId` will correctly point to the default account if it's the only one available, or to the first user-created account. No further changes are needed here.

## 7. Considerations for Existing and New Users

*   **New Users**: The `createDefaultAccountIfNeeded` logic ensures that a shadow account is created for every new user upon their first currency selection.
*   **Existing Users**: Existing users will not have a shadow account created automatically. If this is a requirement, a migration script or a one-time check upon app launch for existing users would be necessary. For this task, we assume the shadow account is only for *new* sign-ups. If an existing user has no accounts, they will be prompted to create one, and the shadow account logic won't apply unless they go through a "first-time setup" flow again.

## Mermaid Diagram for Account Creation Flow

```mermaid
graph TD
    A[User Sign-up] --> B{Is New User?};
    B -- Yes --> C[Navigate to SelectCurrencyScreen];
    C --> D[User Selects Currency];
    D --> E[Call createDefaultAccountIfNeeded];
    E --> F{Default Account Exists?};
    F -- No --> G[Create Shadow Account (isDefault: true, name: "None")];
    F -- Yes --> H[Skip Creation];
    G --> I[Proceed to MainScreen];
    H --> I;
    B -- No --> I;
```

## Conclusion

This plan provides a comprehensive approach to implementing the "shadow" default cash account feature. It addresses all specified requirements, including data model considerations, creation logic, and UI adjustments across various screens. The plan also considers the impact on both new and existing users.