# Budgeting Feature: Technical Plan

This document outlines the technical plan for implementing the budgeting feature.

## 1. Data Model

### 1.1. `Budget` Model

A new file `lib/models/budget.dart` will be created to define the `Budget` model.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String id;
  final String name;
  final double totalAmount;
  final double currentAmount;
  final String categoryId;
  final DateTime endDate;
  final String userId;

  Budget({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.currentAmount,
    required this.categoryId,
    required this.endDate,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalAmount': totalAmount,
      'currentAmount': currentAmount,
      'categoryId': categoryId,
      'endDate': Timestamp.fromDate(endDate),
      'userId': userId,
    };
  }

  factory Budget.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Budget(
      id: doc.id,
      name: data['name'] ?? '',
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (data['currentAmount'] as num?)?.toDouble() ?? 0.0,
      categoryId: data['categoryId'] ?? '',
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] ?? '',
    );
  }
}
```

### 1.2. `FirestoreTransaction` Model Modification

The `lib/models/firestore_transaction.dart` file will be modified to include an optional `budgetId` field.

-   **Add new field:** `final String? budgetId;`
-   **Update constructor:** Add `this.budgetId`
-   **Update `toJson()`:** Add `'budgetId': budgetId,`
-   **Update `fromFirestore()`:** Add `budgetId: data['budgetId'],`
-   **Update `copyWith()`:** Add `String? budgetId` parameter and logic.

## 2. Firestore Schema

A new `budgets` collection will be created under `/users/{userId}/budgets`.

**Structure of a budget document:**

```json
{
  "name": "Monthly Savings",
  "totalAmount": 500.00,
  "currentAmount": 150.00,
  "categoryId": "some_income_category_id",
  "endDate": "timestamp",
  "userId": "user_id_abc"
}
```

## 3. `FirestoreService` Modifications

The `lib/services/firestore_service.dart` file will be updated with the following changes:

### 3.1. New `_budgetsCollection` Reference

```dart
CollectionReference<Budget> get _budgetsCollection {
  if (_userId == null) throw Exception('User not authenticated');
  return _firestore
      .collection('users')
      .doc(_userId!)
      .collection('budgets')
      .withConverter<Budget>(
        fromFirestore: (snapshot, _) => Budget.fromFirestore(snapshot),
        toFirestore: (budget, _) => budget.toJson(),
      );
}
```

### 3.2. Budget CRUD Operations

-   `Future<String> createBudget(Budget budget)`
-   `Stream<List<Budget>> getBudgets()`
-   `Future<void> updateBudget(String budgetId, double amount)`
-   `Future<void> deleteBudget(String budgetId)`
-   `Future<Budget?> getBudgetById(String budgetId)`

### 3.3. Logic for `updateBudget`

When an income transaction with a `budgetId` is created, the `currentAmount` of the corresponding budget should be increased.

The `createTransaction` method in `firestore_service.dart` will be modified:

```dart
// Inside createTransaction method
if (transaction.type == 'income' && transaction.budgetId != null) {
  final budgetDocRef = _budgetsCollection.doc(transaction.budgetId!);
  final budgetSnapshot = await budgetDocRef.get();
  if (budgetSnapshot.exists) {
    final budget = budgetSnapshot.data()!;
    final newCurrentAmount = budget.currentAmount + transaction.amount;
    await budgetDocRef.update({'currentAmount': newCurrentAmount});
  }
}
```

## 4. Implementation Steps (for `code` mode)

### 4.1. `add_budget_screen.dart`

-   Remove the "More" toggle and make the `End Date` field visible by default.
-   Remove the "Add Progress" checkbox.
-   The "Category" dropdown should only show categories of type "INCOME".
-   The `createBudget` method from `FirestoreService` will be called on save.

### 4.2. `add_transaction_screen.dart`

-   If the transaction type is "Income", an optional dropdown to select a budget should be displayed.
-   The dropdown should list all active (not fully funded) budgets. A budget is active if `currentAmount` < `totalAmount`.
-   When a budget is selected, the `budgetId` should be saved with the transaction.
-   Budgets that are fully funded (`currentAmount` >= `totalAmount`) should not appear in the dropdown.

### 4.3. `budget_screen.dart`

-   Fetch and display a list of active budgets using a `StreamBuilder` connected to `firestore_service.getBudgets()`.
-   For each budget, display:
    -   Name
    -   Category Name (requires fetching category details using `categoryId`)
    -   Progress bar showing `currentAmount` / `totalAmount`.
    -   Days remaining until `endDate`.

## 5. Mermaid Diagram

Here is a diagram illustrating the data flow:

```mermaid
graph TD
    subgraph "Add Transaction Screen"
        A[User adds Income Transaction] --> B{Selects a Budget?};
    end

    subgraph "Firestore Service"
        B -- Yes --> C[createTransaction];
        C --> D{Update Budget's currentAmount};
    end

    subgraph "Budget Screen"
        E[StreamBuilder listens for Budget updates] --> F[UI displays updated progress];
    end

    D --> E;