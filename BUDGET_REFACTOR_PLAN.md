# Budget Refactor Architectural Plan

This document outlines the architectural plan for refactoring the budget feature in the Budgetm application.

## 1. Data Models

### `Budget` Model

The `Budget` model will be updated to support weekly, monthly, and yearly budgets.

**File:** `lib/models/budget.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum BudgetType { weekly, monthly, yearly }

class Budget {
  final String id; // Composite key: {userId}_{categoryId}_{type}_{year}_{period}
  final String categoryId;
  final double limit;
  final BudgetType type;
  final int year;
  final int period; // Week number, month number, or year
  final DateTime startDate;
  final DateTime endDate;
  final String userId;
  double spentAmount; // This will be calculated dynamically

  Budget({
    required this.id,
    required this.categoryId,
    required this.limit,
    required this.type,
    required this.year,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.userId,
    this.spentAmount = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'limit': limit,
      'type': type.toString().split('.').last,
      'year': year,
      'period': period,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'userId': userId,
    };
  }

  factory Budget.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Budget(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      limit: (data['limit'] as num?)?.toDouble() ?? 0.0,
      type: _budgetTypeFromString(data['type']),
      year: data['year'] ?? DateTime.now().year,
      period: data['period'] ?? 0,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  static BudgetType _budgetTypeFromString(String? type) {
    switch (type) {
      case 'weekly':
        return BudgetType.weekly;
      case 'monthly':
        return BudgetType.monthly;
      case 'yearly':
        return BudgetType.yearly;
      default:
        return BudgetType.monthly;
    }
  }
}
```

## 2. Screen Structure

### `budget_screen.dart`

*   **State Management:** The screen will be a `StatefulWidget` to manage the selected filter chip.
*   **Widgets:**
    *   `AppBar`: Will remain mostly the same.
    *   `Filter Chips`: A `Row` of `ChoiceChip` widgets for "Weekly", "Monthly", and "Yearly".
    *   `(+) Button`: An `IconButton` next to the "Categories" title.
    *   `Budget List`: A `ListView.builder` to display budget cards.
    *   `Empty State`: A widget to show when there are no budgets.

### `add_budget_screen.dart` (New File)

*   **State Management:** A `StatefulWidget` to manage the form state.
*   **Widgets:**
    *   `AppBar`: With a title "Add Budget".
    *   `Category Selector`: A dropdown or a list to select a category.
    *   `Balance Limit Input`: A `TextFormField` for the budget limit.
    *   `Budget Type Selector`: `ChoiceChip` widgets for "Weekly", "Monthly", and "Yearly".
    *   `Save Button`: A button to save the new budget.

## 3. Implementation Strategy

### `BudgetProvider` (`lib/viewmodels/budget_provider.dart`)

The `BudgetProvider` will be significantly refactored.

*   **Remove Automatic Budget Creation:** The logic that automatically creates budgets from transactions will be removed.
*   **Filtering Logic:**
    *   A new property `selectedBudgetType` will be added to the provider.
    *   The `budgets` getter will be updated to filter budgets based on the `selectedBudgetType`.
*   **Transaction Mapping:**
    *   When a budget is created, the `BudgetProvider` will fetch all transactions for the selected category.
    *   It will then filter the transactions that fall within the budget's `startDate` and `endDate`.
    *   The `spentAmount` for the budget will be calculated by summing up the amounts of the mapped transactions. This will not be stored in Firestore but calculated on the fly.
*   **Weekly Budget Calculation:**
    *   A helper function will be created to calculate the start and end of the week (Monday to Sunday) for a given date.
*   **New Methods:**
    *   `addBudget(Budget budget)`: To add a new budget to Firestore.
    *   `getTransactionsForBudget(Budget budget)`: To get the list of transactions for a specific budget.

### `firestore_service.dart`

*   **New Methods:**
    *   `addBudget(Budget budget)`: To add a new budget document.
    *   `getBudgets(BudgetType type)`: To fetch budgets of a specific type.

### Workflow Diagram

```mermaid
graph TD
    A[User opens Budget Screen] --> B{Budgets exist?};
    B -->|Yes| C[Display budget list];
    B -->|No| D[Show empty state];
    C --> E{User selects filter};
    E --> F[Filter budget list];
    A --> G[User taps '+' button];
    G --> H[Navigate to Add Budget Screen];
    H --> I[User fills form and saves];
    I --> J[Call BudgetProvider.addBudget];
    J --> K[Save budget to Firestore];
    K --> L[Map existing transactions];
    L --> M[Update UI];
    C --> N[User taps on a budget];
    N --> O[Navigate to Budget Detail Screen];
    O --> P[Show transactions for that budget];