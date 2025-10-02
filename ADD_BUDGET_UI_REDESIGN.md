# Add Budget Screen UI Redesign

This document outlines the UI redesign for the "Add Budget" screen to align it with the app's modern and consistent design language, using the "Add Transaction" screen as a reference.

## 1. AppBar

The existing `AppBar` will be replaced with a custom gradient app bar, consistent with the `add_transaction_screen.dart`.

-   **Style:** Custom widget with a gradient background (`AppColors.gradientStart` to `AppColors.gradientEnd2`).
-   **Shape:** Rounded bottom corners (`bottomLeft` and `bottomRight` with a radius of 30).
-   **Back Button:** A circular back button with a gradient background and a `HugeIcons.strokeRoundedArrowLeft01` icon.
-   **Title:** The title "Add Budget" will be styled with a bold font and a size of 18.

## 2. Body

The body of the screen will be updated to improve layout, styling, and user experience.

### 2.1. Background Color

-   The background color will be set to a slight grey (`#FAFAFA`) to match the `add_transaction_screen.dart`.

### 2.2. Form Fields

The form fields will be reorganized and restyled for a cleaner and more intuitive interface. The fields will be grouped into sections with titles.

#### Section 1: Amount

-   **Title:** "Limit Amount"
-   **Input Field:** A `FormBuilderTextField` for the budget limit.
    -   **Styling:** Centered text, large font size (26), and a custom input decoration with a rounded border and white background.
    -   **Hint Text:** "0.00"

#### Section 2: Category and Type

This section will contain the "Select Category" and "Budget Type" fields, arranged horizontally.

-   **Select Category:**
    -   **Interaction:** Tapping this field will open a bottom sheet (`_showSelectionBottomSheet`) for category selection.
    -   **Styling:** A `GestureDetector` wrapping a `Container` with a rounded border, white background, and a dropdown arrow icon. It will display the selected category name.
-   **Budget Type:**
    -   **Interaction:** Tapping this field will open a bottom sheet for selecting the budget type (Weekly, Monthly, Yearly).
    -   **Styling:** Similar to the "Select Category" field, it will be a `GestureDetector` wrapping a `Container` with a rounded border and white background.

## 3. Buttons

The single "Add Budget" button will be replaced with "Cancel" and "Save Budget" buttons at the bottom of the screen.

-   **Layout:** A `Row` containing two `Expanded` buttons.
-   **Cancel Button:**
    -   **Style:** An `OutlinedButton` with a white background, black border, and rounded corners.
    -   **Text:** "Cancel" in black.
-   **Save Budget Button:**
    -   **Style:** An `ElevatedButton` with a gradient background (`AppColors.gradientEnd`), and rounded corners.
    -   **Text:** "Save Budget" in white.

This redesign will create a more visually appealing and consistent user experience, aligning the "Add Budget" screen with the overall design of the application.