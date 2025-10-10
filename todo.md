# Currency Unification Plan

This document outlines the architectural changes required to unify currency handling across the application.

## 1. Goals

*   **Single Source of Truth**: Establish a single, reliable source for the user's selected currency.
*   **Global Accessibility**: Make the current currency symbol and code easily accessible throughout the application.
*   **Dynamic Updates**: Ensure that any change in the user's selected currency is reflected immediately across the entire UI.
*   **Data Integrity**: Store currency information consistently across all relevant data models.
*   **No Hardcoded Symbols**: Eliminate all hardcoded currency symbols (e.g., "$").

## 2. Proposed Architecture

### 2.1. Data Storage and Management

*   **Primary Storage**: The user's selected currency code (e.g., "USD", "EUR") will continue to be stored in the `FirestoreAccount` document for the user under the `currency` field. This will be the ultimate source of truth.
*   **Application State**: The `CurrencyProvider` will remain the central point for managing the currency state within the application. It will be responsible for:
    *   Loading the currency from `SharedPreferences` on startup.
    *   Fetching the currency from Firestore if it's not in `SharedPreferences`.
    *   Providing the currency symbol, code, and other details to the UI.
    *   Notifying listeners when the currency changes.

### 2.2. Currency Change Propagation

1.  **User Action**: The user changes their currency in the settings.
2.  **Update `CurrencyProvider`**: The UI calls a method on the `CurrencyProvider` (e.g., `setCurrency`) to update the currency.
3.  **Update Firestore**: The `CurrencyProvider` updates the `currency` field in the user's `FirestoreAccount` document.
4.  **Update `SharedPreferences`**: The `CurrencyProvider` saves the new currency to `SharedPreferences` for faster loading next time.
5.  **Notify Listeners**: The `CurrencyProvider` calls `notifyListeners()` to trigger a UI rebuild.
6.  **UI Update**: All widgets listening to the `CurrencyProvider` will rebuild with the new currency symbol.

### 2.3. Model Modifications

The following models will be updated to include a `currency` field:

*   `Budget`
*   `FirestoreGoal`
*   `Subscription`
*   `Borrowed`
*   `Lent`
*   `Transaction`
*   `FirestoreTransaction`

This will ensure that every financial record has an associated currency, which is crucial for data integrity and future features like multi-currency support.

### 2.4. Replacing Hardcoded Symbols

A global search and replace will be performed to replace all instances of `"$"` with `Provider.of<CurrencyProvider>(context).currencySymbol`. This will be done in all files that display currency values.

## 3. Implementation Steps

1.  **Update Data Models**: Add a `currency` field to all the models listed in section 2.3.
2.  **Update `CurrencyProvider`**:
    *   Add a method to update the currency in Firestore.
    *   Ensure the provider correctly loads the currency from Firestore if it's not in `SharedPreferences`.
3.  **Update UI**:
    *   Create a currency selection screen in the user's profile.
    *   Perform a global search and replace to replace all hardcoded `"$"` symbols with the dynamic currency symbol from the `CurrencyProvider`.
4.  **Data Migration**: (Optional, but recommended) Write a script to update existing Firestore documents with the user's default currency.

## 4. Mermaid Diagram

```mermaid
graph TD
    A[User selects currency in UI] --> B{CurrencyProvider};
    B --> C[Update SharedPreferences];
    B --> D[Update FirestoreAccount];
    B --> E[notifyListeners()];
    E --> F[UI Widgets listening to Provider];
    F --> G[Rebuild with new currency symbol];

    subgraph "Data Flow"
        D --> H((Firestore));
        C --> I((SharedPreferences));
    end

    subgraph "Models"
        J[Budget]
        K[Goal]
        L[Transaction]
        M[...]
    end

    D -.-> J;
    D -.-> K;
    D -.-> L;
    D -.-> M;
```
