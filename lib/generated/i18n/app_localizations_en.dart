// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginTitle => 'Login';

  @override
  String get loginSubtitle => 'Enter your email and password to log in';

  @override
  String get emailHint => 'Email';

  @override
  String get passwordHint => 'Password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get loginButton => 'Login';

  @override
  String get orLoginWith => 'Or login with';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email address to recover password';

  @override
  String get emailLabel => 'Email';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get passwordResetEmailSent =>
      'Password reset email sent. Please check your inbox.';

  @override
  String get getStartedTitle => 'Get Started';

  @override
  String get createAccountSubtitle => 'Create an account to continue';

  @override
  String get nameHint => 'Name';

  @override
  String get confirmPasswordHint => 'Confirm Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get orContinueWith => 'Or Continue with';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get selectCurrencyTitle => 'Select Currency';

  @override
  String get selectCurrencySubtitle => 'Select your preferred Currency';

  @override
  String get selectCurrencyLabel => 'Select Currency';

  @override
  String get continueButton => 'Continue';

  @override
  String errorDuringSetup(Object error) {
    return 'Error during setup: $error';
  }

  @override
  String get backButton => 'Back';

  @override
  String get onboardingPage1Title => 'Save Smarter';

  @override
  String get onboardingPage1Description =>
      'Set aside money effortlessly and watch your savings grow with every step.';

  @override
  String get onboardingPage2Title => 'Achieve Your Goals';

  @override
  String get onboardingPage2Description =>
      'Create financial goals, from a new gadget to your dream trip, and track your progress.';

  @override
  String get onboardingPage3Title => 'Stay on Track';

  @override
  String get onboardingPage3Description =>
      'Monitor your spending, income, and savings all in one simple dashboard.';

  @override
  String get paywallCouldNotLoadPlans =>
      'Could not load plans.\nPlease try again later.';

  @override
  String get paywallChooseYourPlan => 'Choose Your Plan';

  @override
  String get paywallInvestInFinancialFreedom =>
      'Invest in your financial freedom today';

  @override
  String paywallPricePerDay(Object price) {
    return '$price/day';
  }

  @override
  String paywallSaveAmount(Object amount) {
    return 'Save $amount';
  }

  @override
  String get paywallEverythingIncluded => 'Everything included:';

  @override
  String get paywallPersonalizedBudgetInsights =>
      'Personalized budget insights';

  @override
  String get paywallDailyProgressTracking => 'Daily progress tracking';

  @override
  String get paywallExpenseManagementTools => 'Expense management tools';

  @override
  String get paywallFinancialHealthTimeline => 'Financial health timeline';

  @override
  String get paywallExpertGuidanceTips => 'Expert guidance & tips';

  @override
  String get paywallCommunitySupportAccess => 'Community support access';

  @override
  String get paywallSaveYourFinances => 'Save your finances and future';

  @override
  String get paywallAverageUserSaves =>
      'Average user saves ~£2,500 per year by budgeting effectively';

  @override
  String get paywallSubscribeYourPlan => 'Subscribe Your Plan';

  @override
  String get paywallPleaseSelectPlan => 'Please select a plan.';

  @override
  String get paywallSubscriptionActivated =>
      'Subscription activated! You now have access to premium features.';

  @override
  String paywallFailedToPurchase(Object message) {
    return 'Failed to purchase: $message';
  }

  @override
  String paywallUnexpectedError(Object error) {
    return 'An unexpected error occurred: $error';
  }

  @override
  String get paywallRestorePurchases => 'Restore purchases';

  @override
  String get paywallManageSubscription => 'Manage subscription';

  @override
  String get paywallPurchasesRestoredSuccessfully =>
      'Purchases restored successfully!';

  @override
  String get paywallNoActiveSubscriptionFound =>
      'No active subscription found. You are now on the free plan.';

  @override
  String get paywallPerMonth => 'per month';

  @override
  String get paywallPerYear => 'per year';

  @override
  String get paywallBestValue => 'Best Value';

  @override
  String get paywallMostPopular => 'Most Popular';

  @override
  String get mainScreenHome => 'Home';

  @override
  String get mainScreenBudget => 'Budget';

  @override
  String get mainScreenBalance => 'Balance';

  @override
  String get mainScreenGoals => 'Goals';

  @override
  String get mainScreenPersonal => 'Personal';

  @override
  String get mainScreenIncome => 'Income';

  @override
  String get mainScreenExpense => 'Expense';

  @override
  String get balanceTitle => 'Balance';

  @override
  String get balanceAddAccount => 'Add Account';

  @override
  String get balanceMyAccounts => 'MY ACCOUNTS';

  @override
  String get balanceVacation => 'VACATION';

  @override
  String get balanceAccountBalance => 'Account Balance';

  @override
  String get balanceNoAccountsFound => 'No accounts found.';

  @override
  String get balanceNoAccountsCreated => 'No accounts created';

  @override
  String get balanceCreateFirstAccount =>
      'Create your first account to start tracking balances';

  @override
  String get balanceCreateFirstAccountFinances =>
      'Create your first account to start tracking your finances';

  @override
  String get balanceNoVacationsYet => 'No vacations yet';

  @override
  String get balanceCreateFirstVacation =>
      'Create your first vacation account to start planning your trips';

  @override
  String get balanceSingleAccountView => 'Single Account View';

  @override
  String get balanceAddMoreAccounts => 'Add more accounts to see charts';

  @override
  String get balanceNoAccountsForCurrency =>
      'No accounts found for selected currency';

  @override
  String balanceCreditLimit(Object value) {
    return 'Credit Limit: $value';
  }

  @override
  String balanceBalanceLimit(Object value) {
    return 'Balance Limit: $value';
  }

  @override
  String get budgetTitle => 'Budget';

  @override
  String get budgetAddBudget => 'Add Budget';

  @override
  String get budgetDaily => 'Daily';

  @override
  String get budgetWeekly => 'Weekly';

  @override
  String get budgetMonthly => 'Monthly';

  @override
  String get budgetSelectWeek => 'Select Week';

  @override
  String get budgetSelectDate => 'Select Date';

  @override
  String get budgetSelectDay => 'Select Day';

  @override
  String get budgetCancel => 'Cancel';

  @override
  String get budgetApply => 'Apply';

  @override
  String get budgetTotalSpending => 'Total Spending';

  @override
  String get budgetCategoryBreakdown => 'Category Breakdown';

  @override
  String get budgetViewAll => 'View All';

  @override
  String get budgetBudgets => 'Budgets';

  @override
  String get budgetNoBudgetCreated => 'No budget created';

  @override
  String get budgetStartCreatingBudget =>
      'Start by creating a budget to see your spending breakdown here.';

  @override
  String get budgetSetSpendingLimit => 'Set spending limit';

  @override
  String get budgetEnterLimitAmount => 'Enter limit amount';

  @override
  String get budgetSave => 'Save';

  @override
  String get budgetEnterValidNumber => 'Enter a valid number';

  @override
  String get budgetLimitSaved => 'Budget limit saved';

  @override
  String get budgetCreated => 'Budget created';

  @override
  String get budgetTransactions => 'transactions';

  @override
  String budgetOverBudget(Object amount) {
    return '$amount over budget';
  }

  @override
  String budgetRemaining(Object amount) {
    return '$amount remaining';
  }

  @override
  String get homeNoMoreTransactions => 'No more transactions';

  @override
  String get homeErrorLoadingMoreTransactions =>
      'Error loading more transactions';

  @override
  String get homeRetry => 'Retry';

  @override
  String get homeErrorLoadingData => 'Error loading data';

  @override
  String get homeNoTransactionsRecorded => 'No transactions recorded';

  @override
  String get homeStartAddingTransactions =>
      'Start by adding transactions to see your spending breakdown here.';

  @override
  String get homeCurrencyChange => 'Currency Change';

  @override
  String get homeCurrencyChangeMessage =>
      'Changing your currency will convert all existing amounts. This action cannot be undone. Do you want to continue?';

  @override
  String get homeNo => 'No';

  @override
  String get homeYes => 'Yes';

  @override
  String get homeVacationBudgetBreakdown => 'Vacation Budget Breakdown';

  @override
  String get homeBalanceBreakdown => 'Balance Breakdown';

  @override
  String get homeClose => 'Close';

  @override
  String get transactionPickColor => 'Pick a color';

  @override
  String get transactionSelectDate => 'Select Date';

  @override
  String get transactionCancel => 'Cancel';

  @override
  String get transactionApply => 'Apply';

  @override
  String get transactionAmount => 'Amount';

  @override
  String get transactionSelect => 'Select';

  @override
  String get transactionPaid => 'Paid';

  @override
  String get transactionAddTransaction => 'Add Transaction';

  @override
  String get transactionEditTransaction => 'Edit Transaction';

  @override
  String get transactionIncome => 'Income';

  @override
  String get transactionExpense => 'Expense';

  @override
  String get transactionDescription => 'Description';

  @override
  String get transactionCategory => 'Category';

  @override
  String get transactionAccount => 'Account';

  @override
  String get transactionDate => 'Date';

  @override
  String get transactionSave => 'Save';

  @override
  String get transactionDelete => 'Delete';

  @override
  String get transactionSuccess => 'Transaction saved successfully';

  @override
  String get transactionError => 'Error saving transaction';

  @override
  String get transactionDeleteConfirm =>
      'Are you sure you want to delete this transaction?';

  @override
  String get transactionDeleteSuccess => 'Transaction deleted successfully';

  @override
  String get goalsTitle => 'Goals';

  @override
  String get goalsAddGoal => 'Add Goal';

  @override
  String get goalsNoGoalsCreated => 'No goals created';

  @override
  String get goalsStartCreatingGoal =>
      'Start by creating a goal to track your financial progress';

  @override
  String get goalsCreateGoal => 'Create Goal';

  @override
  String get goalsEditGoal => 'Edit Goal';

  @override
  String get goalsGoalName => 'Goal Name';

  @override
  String get goalsTargetAmount => 'Target Amount';

  @override
  String get goalsCurrentAmount => 'Current Amount';

  @override
  String get goalsDeadline => 'Deadline';

  @override
  String get goalsDescription => 'Description';

  @override
  String get goalsSave => 'Save';

  @override
  String get goalsCancel => 'Cancel';

  @override
  String get goalsDelete => 'Delete';

  @override
  String get goalsGoalCreated => 'Goal created successfully';

  @override
  String get goalsGoalUpdated => 'Goal updated successfully';

  @override
  String get goalsGoalDeleted => 'Goal deleted successfully';

  @override
  String get goalsErrorSaving => 'Error saving goal';

  @override
  String get goalsDeleteConfirm => 'Are you sure you want to delete this goal?';

  @override
  String get goalsProgress => 'Progress';

  @override
  String get goalsCompleted => 'Completed';

  @override
  String get goalsInProgress => 'In Progress';

  @override
  String get goalsNotStarted => 'Not Started';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profilePremiumActive => 'Premium Active';

  @override
  String get profilePremiumDescription =>
      'You have access to all premium features';

  @override
  String get profileFreePlan => 'Free Plan';

  @override
  String get profileUpgradeDescription =>
      'Upgrade to premium for advanced features';

  @override
  String profileRenewalDate(Object date) {
    return 'Renews on $date';
  }

  @override
  String profileExpiresOn(Object date) {
    return 'Expires on $date';
  }

  @override
  String profileErrorSigningOut(Object error) {
    return 'Error signing out: $error';
  }

  @override
  String get profileUserNotFound => 'User not found';

  @override
  String get profileEditDisplayName => 'Edit display name';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileSave => 'Save';

  @override
  String get profileDisplayNameUpdated => 'Display name updated successfully';

  @override
  String get profileErrorUpdatingName => 'Error updating display name';

  @override
  String get profileManageSubscription => 'Manage subscription';

  @override
  String get profileRestorePurchases => 'Restore purchases';

  @override
  String get profileRefreshStatus => 'Refresh status';

  @override
  String get profileSubscriptionRefreshed => 'Subscription status refreshed';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get profileSignOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get profileCurrencyRates => 'Currency Rates';

  @override
  String get profileCategories => 'Categories';

  @override
  String get profileFeedback => 'Feedback';

  @override
  String get profileExportData => 'Export Data';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileDisplayName => 'Display Name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileSubscription => 'Subscription';

  @override
  String get profileVersion => 'Version';

  @override
  String get personalTitle => 'Personal';

  @override
  String get personalSubscriptions => 'Subscriptions';

  @override
  String get personalLent => 'Lent';

  @override
  String get personalBorrowed => 'Borrowed';

  @override
  String get personalAddSubscription => 'Add Subscription';

  @override
  String get personalAddLent => 'Add Lent';

  @override
  String get personalAddBorrowed => 'Add Borrowed';

  @override
  String get personalNoSubscriptions => 'No subscriptions found';

  @override
  String get personalNoLent => 'No lent items found';

  @override
  String get personalNoBorrowed => 'No borrowed items found';

  @override
  String get personalStartAddingSubscription =>
      'Start by adding a subscription to track your recurring payments';

  @override
  String get personalStartAddingLent =>
      'Start by adding lent items to track money you\'ve lent';

  @override
  String get personalStartAddingBorrowed =>
      'Start by adding borrowed items to track money you\'ve borrowed';

  @override
  String get personalEdit => 'Edit';

  @override
  String get personalDelete => 'Delete';

  @override
  String get personalMarkAsPaid => 'Mark as Paid';

  @override
  String get personalMarkAsUnpaid => 'Mark as Unpaid';

  @override
  String get personalAmount => 'Amount';

  @override
  String get personalDescription => 'Description';

  @override
  String get personalDueDate => 'Due Date';

  @override
  String get personalRecurring => 'Recurring';

  @override
  String get personalOneTime => 'One Time';

  @override
  String get personalMonthly => 'Monthly';

  @override
  String get personalYearly => 'Yearly';

  @override
  String get personalWeekly => 'Weekly';

  @override
  String get personalDaily => 'Daily';

  @override
  String get personalName => 'Name';

  @override
  String get personalCategory => 'Category';

  @override
  String get personalNotes => 'Notes';

  @override
  String get personalSave => 'Save';

  @override
  String get personalCancel => 'Cancel';

  @override
  String get personalDeleteConfirm =>
      'Are you sure you want to delete this item?';

  @override
  String get personalItemSaved => 'Item saved successfully';

  @override
  String get personalItemDeleted => 'Item deleted successfully';

  @override
  String get personalErrorSaving => 'Error saving item';

  @override
  String get personalErrorDeleting => 'Error deleting item';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsOverview => 'Overview';

  @override
  String get analyticsIncome => 'Income';

  @override
  String get analyticsExpenses => 'Expenses';

  @override
  String get analyticsSavings => 'Savings';

  @override
  String get analyticsCategories => 'Categories';

  @override
  String get analyticsTrends => 'Trends';

  @override
  String get analyticsMonthly => 'Monthly';

  @override
  String get analyticsWeekly => 'Weekly';

  @override
  String get analyticsDaily => 'Daily';

  @override
  String get analyticsYearly => 'Yearly';

  @override
  String get analyticsNoData => 'No data available';

  @override
  String get analyticsStartTracking =>
      'Start tracking your finances to see analytics here';

  @override
  String get analyticsTotalIncome => 'Total Income';

  @override
  String get analyticsTotalExpenses => 'Total Expenses';

  @override
  String get analyticsNetSavings => 'Net Savings';

  @override
  String get analyticsTopCategories => 'Top Categories';

  @override
  String get analyticsSpendingTrends => 'Spending Trends';

  @override
  String get analyticsIncomeTrends => 'Income Trends';

  @override
  String get analyticsSavingsRate => 'Savings Rate';

  @override
  String get analyticsAverageDaily => 'Average Daily';

  @override
  String get analyticsAverageWeekly => 'Average Weekly';

  @override
  String get analyticsAverageMonthly => 'Average Monthly';

  @override
  String get analyticsSelectPeriod => 'Select Period';

  @override
  String get analyticsExportData => 'Export Data';

  @override
  String get analyticsRefresh => 'Refresh';

  @override
  String get analyticsErrorLoading => 'Error loading analytics data';

  @override
  String get analyticsRetry => 'Retry';

  @override
  String get goalsSelectColor => 'Select Color';

  @override
  String get goalsMore => 'More';

  @override
  String get goalsName => 'Goal Name';

  @override
  String get goalsColor => 'Color';

  @override
  String get goalsNameRequired => 'Goal name is required';

  @override
  String get goalsAmountRequired => 'Target amount is required';

  @override
  String get goalsAmountMustBePositive =>
      'Target amount must be greater than 0';

  @override
  String get goalsDeadlineRequired => 'Deadline is required';

  @override
  String get goalsDeadlineMustBeFuture => 'Deadline must be in the future';

  @override
  String get goalsNameAlreadyExists => 'A goal with this name already exists';

  @override
  String goalsErrorCreating(Object error) {
    return 'Error creating goal: $error';
  }

  @override
  String goalsErrorUpdating(Object error) {
    return 'Error updating goal: $error';
  }

  @override
  String goalsErrorDeleting(Object error) {
    return 'Error deleting goal: $error';
  }

  @override
  String get expenseDetailTitle => 'Expense Detail';

  @override
  String get expenseDetailEdit => 'Edit';

  @override
  String get expenseDetailDelete => 'Delete';

  @override
  String get expenseDetailAmount => 'Amount';

  @override
  String get expenseDetailCategory => 'Category';

  @override
  String get expenseDetailAccount => 'Account';

  @override
  String get expenseDetailDate => 'Date';

  @override
  String get expenseDetailDescription => 'Description';

  @override
  String get expenseDetailNotes => 'Notes';

  @override
  String get expenseDetailSave => 'Save';

  @override
  String get expenseDetailCancel => 'Cancel';

  @override
  String get expenseDetailDeleteConfirm =>
      'Are you sure you want to delete this expense?';

  @override
  String get expenseDetailUpdated => 'Expense updated successfully';

  @override
  String get expenseDetailDeleted => 'Expense deleted successfully';

  @override
  String get expenseDetailErrorSaving => 'Error saving expense';

  @override
  String get expenseDetailErrorDeleting => 'Error deleting expense';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarSelectDate => 'Select Date';

  @override
  String get calendarToday => 'Today';

  @override
  String get calendarThisWeek => 'This Week';

  @override
  String get calendarThisMonth => 'This Month';

  @override
  String get calendarThisYear => 'This Year';

  @override
  String get calendarNoTransactions => 'No transactions on this date';

  @override
  String get calendarStartAddingTransactions =>
      'Start adding transactions to see them on the calendar';

  @override
  String get vacationDialogTitle => 'Vacation Mode';

  @override
  String get vacationDialogEnable => 'Enable Vacation Mode';

  @override
  String get vacationDialogDisable => 'Disable Vacation Mode';

  @override
  String get vacationDialogDescription =>
      'Vacation mode helps you track expenses during trips and holidays';

  @override
  String get vacationDialogCancel => 'Cancel';

  @override
  String get vacationDialogConfirm => 'Confirm';

  @override
  String get vacationDialogEnabled => 'Vacation mode enabled';

  @override
  String get vacationDialogDisabled => 'Vacation mode disabled';

  @override
  String get balanceDetailTitle => 'Account Detail';

  @override
  String get balanceDetailEdit => 'Edit';

  @override
  String get balanceDetailDelete => 'Delete';

  @override
  String get balanceDetailTransactions => 'Transactions';

  @override
  String get balanceDetailBalance => 'Balance';

  @override
  String get balanceDetailCreditLimit => 'Credit Limit';

  @override
  String get balanceDetailBalanceLimit => 'Balance Limit';

  @override
  String get balanceDetailCurrency => 'Currency';

  @override
  String get balanceDetailAccountType => 'Account Type';

  @override
  String get balanceDetailAccountName => 'Account Name';

  @override
  String get balanceDetailSave => 'Save';

  @override
  String get balanceDetailCancel => 'Cancel';

  @override
  String get balanceDetailDeleteConfirm =>
      'Are you sure you want to delete this account?';

  @override
  String get balanceDetailUpdated => 'Account updated successfully';

  @override
  String get balanceDetailDeleted => 'Account deleted successfully';

  @override
  String get balanceDetailErrorSaving => 'Error saving account';

  @override
  String get balanceDetailErrorDeleting => 'Error deleting account';

  @override
  String get addAccountTitle => 'Add Account';

  @override
  String get addAccountEditTitle => 'Edit Account';

  @override
  String get addAccountName => 'Account Name';

  @override
  String get addAccountType => 'Account Type';

  @override
  String get addAccountCurrency => 'Currency';

  @override
  String get addAccountInitialBalance => 'Initial Balance';

  @override
  String get addAccountCreditLimit => 'Credit Limit';

  @override
  String get addAccountBalanceLimit => 'Balance Limit';

  @override
  String get addAccountColor => 'Color';

  @override
  String get addAccountIcon => 'Icon';

  @override
  String get addAccountSave => 'Save';

  @override
  String get addAccountCancel => 'Cancel';

  @override
  String get addAccountCreated => 'Account created successfully';

  @override
  String get addAccountUpdated => 'Account updated successfully';

  @override
  String get addAccountErrorSaving => 'Error saving account';

  @override
  String get addAccountNameRequired => 'Account name is required';

  @override
  String get addAccountTypeRequired => 'Account type is required';

  @override
  String get addAccountCurrencyRequired => 'Currency is required';

  @override
  String get budgetDetailTitle => 'Budget Detail';

  @override
  String get budgetDetailEdit => 'Edit';

  @override
  String get budgetDetailDelete => 'Delete';

  @override
  String get budgetDetailSpending => 'Spending';

  @override
  String get budgetDetailLimit => 'Limit';

  @override
  String get budgetDetailRemaining => 'Remaining';

  @override
  String get budgetDetailOverBudget => 'Over Budget';

  @override
  String get budgetDetailCategories => 'Categories';

  @override
  String get budgetDetailTransactions => 'Transactions';

  @override
  String get budgetDetailSave => 'Save';

  @override
  String get budgetDetailCancel => 'Cancel';

  @override
  String get budgetDetailDeleteConfirm =>
      'Are you sure you want to delete this budget?';

  @override
  String get budgetDetailUpdated => 'Budget updated successfully';

  @override
  String get budgetDetailDeleted => 'Budget deleted successfully';

  @override
  String get budgetDetailErrorSaving => 'Error saving budget';

  @override
  String get budgetDetailErrorDeleting => 'Error deleting budget';

  @override
  String get addBudgetTitle => 'Add Budget';

  @override
  String get addBudgetEditTitle => 'Edit Budget';

  @override
  String get addBudgetName => 'Budget Name';

  @override
  String get addBudgetType => 'Budget Type';

  @override
  String get addBudgetAmount => 'Amount';

  @override
  String get addBudgetCurrency => 'Currency';

  @override
  String get addBudgetPeriod => 'Period';

  @override
  String get addBudgetCategories => 'Categories';

  @override
  String get addBudgetColor => 'Color';

  @override
  String get addBudgetSave => 'Save';

  @override
  String get addBudgetSaveBudget => 'Save Budget';

  @override
  String get addBudgetCancel => 'Cancel';

  @override
  String get addBudgetCreated => 'Budget created successfully';

  @override
  String get addBudgetUpdated => 'Budget updated successfully';

  @override
  String get addBudgetErrorSaving => 'Error saving budget';

  @override
  String get addBudgetNameRequired => 'Budget name is required';

  @override
  String get addBudgetAmountRequired => 'Budget amount is required';

  @override
  String get addBudgetAmountMustBePositive =>
      'Budget amount must be greater than 0';

  @override
  String get addBudgetCategoryRequired => 'Please select a category';

  @override
  String get budgetDetailNoBudgetToDelete =>
      'No budget to delete. This is just a placeholder for transactions.';

  @override
  String get personalItemDetails => 'Item Details';

  @override
  String get personalStartDateRequired => 'Please select a start date';

  @override
  String get profileMainCurrency => 'MAIN CURRENCY';

  @override
  String get profileFeedbackThankYou => 'Thank you for your feedback!';

  @override
  String get profileFeedbackEmailError => 'Could not open email client.';

  @override
  String get feedbackModalTitle => 'Enjoying the app?';

  @override
  String get feedbackModalDescription =>
      'Your feedback keeps us motivated and helps us improve.';

  @override
  String get goalNameAlreadyExistsSnackbar =>
      'A goal with this name already exists';

  @override
  String get lentSelectBothDates => 'Please select both date and due date';

  @override
  String get lentDueDateBeforeLentDate =>
      'Due date cannot be before the lent date';

  @override
  String get lentItemAddedSuccessfully => 'Lent item added successfully';

  @override
  String lentItemError(Object error) {
    return 'Error: $error';
  }

  @override
  String get borrowedSelectBothDates => 'Please select both date and due date';

  @override
  String get borrowedDueDateBeforeBorrowedDate =>
      'Due date cannot be before the borrowed date';

  @override
  String get borrowedItemAddedSuccessfully =>
      'Borrowed item added successfully';

  @override
  String borrowedItemError(Object error) {
    return 'Error: $error';
  }

  @override
  String get subscriptionCreatedSuccessfully =>
      'Subscription created successfully';

  @override
  String subscriptionError(Object error) {
    return 'Error: $error';
  }

  @override
  String get paymentMarkedSuccessfully => 'Payment marked successfully';

  @override
  String get subscriptionContinued => 'Subscription continued successfully';

  @override
  String get subscriptionPaused => 'Subscription paused successfully';

  @override
  String get itemMarkedAsReturnedSuccessfully =>
      'Item marked as returned successfully';

  @override
  String get itemDeletedSuccessfully => 'Item deleted successfully';

  @override
  String get failedToDeleteBudget => 'Failed to delete budget';

  @override
  String get failedToDeleteGoal => 'Failed to delete goal';

  @override
  String failedToSaveTransaction(Object error) {
    return 'Failed to save transaction: $error';
  }

  @override
  String get failedToReorderCategories =>
      'Failed to reorder categories. Reverting changes.';

  @override
  String get categoryAddedSuccessfully => 'Category added successfully';

  @override
  String failedToAddCategory(Object error) {
    return 'Failed to add category: $error';
  }

  @override
  String errorCreatingGoal(Object error) {
    return 'Error creating goal: $error';
  }

  @override
  String get hintName => 'Name';

  @override
  String get hintDescription => 'Description';

  @override
  String get hintSelectDate => 'Select Date';

  @override
  String get hintSelectDueDate => 'Select Due Date';

  @override
  String get hintSelectCategory => 'Select Category';

  @override
  String get hintSelectAccount => 'Select Account';

  @override
  String get hintSelectGoal => 'Select Goal';

  @override
  String get hintNotes => 'Notes';

  @override
  String get hintSelectColor => 'Select Color';

  @override
  String get hintEnterCategoryName => 'Enter category name';

  @override
  String get hintSelectType => 'Select Type';

  @override
  String get hintWriteThoughts => 'Write about your thoughts here......';

  @override
  String get hintEnterDisplayName => 'Enter display name';

  @override
  String get hintSelectBudgetType => 'Select Budget Type';

  @override
  String get hintSelectAccountType => 'Select Account Type';

  @override
  String get hintEnterName => 'Enter Name';

  @override
  String get hintSelectIcon => 'Select Icon';

  @override
  String get hintSelect => 'Select';

  @override
  String get hintAmountPlaceholder => '0.00';

  @override
  String get labelValue => 'Value';

  @override
  String get labelName => 'Name';

  @override
  String get labelDescription => 'Description';

  @override
  String get labelCategory => 'Category';

  @override
  String get labelDate => 'Date';

  @override
  String get labelDueDate => 'Due Date';

  @override
  String get labelColor => 'Color';

  @override
  String get labelNotes => 'Notes';

  @override
  String get labelAccount => 'Account';

  @override
  String get labelMore => 'More';

  @override
  String get labelHome => 'Home';

  @override
  String get titlePickColor => 'Pick a color';

  @override
  String get titleAddLentItem => 'Add Lent Item';

  @override
  String get titleAddBorrowedItem => 'Add Borrowed Item';

  @override
  String get titleSelectCategory => 'Select Category';

  @override
  String get titleSelectAccount => 'Select Account';

  @override
  String get titleSelectGoal => 'Select Goal';

  @override
  String get titleSelectType => 'Select Type';

  @override
  String get titleSelectAccountType => 'Select Account Type';

  @override
  String get titleSelectBudgetType => 'Select Budget Type';

  @override
  String get validationNameRequired => 'Name is required';

  @override
  String get validationAmountRequired => 'Amount is required';

  @override
  String get validationPleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get validationPleaseSelectIcon => 'Please select an icon';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonAdd => 'Add';

  @override
  String get buttonSave => 'Save';

  @override
  String get switchAddProgress => 'Add Progress';

  @override
  String get pickColor => 'Pick a color';

  @override
  String get name => 'Name';

  @override
  String get itemName => 'Item Name';

  @override
  String get account => 'Account';

  @override
  String get selectIcon => 'Please select an icon';

  @override
  String get value => 'Value';

  @override
  String get hintAmount => '0.00';

  @override
  String get hintItemName => 'Item Name';

  @override
  String get amountRequired => 'Amount is required';

  @override
  String get validNumber => 'Please enter a valid number';

  @override
  String get category => 'Category';

  @override
  String get date => 'Date';

  @override
  String get dueDate => 'Due Date';

  @override
  String get color => 'Color';

  @override
  String get notes => 'Notes';

  @override
  String get selectColor => 'Select Color';

  @override
  String get more => 'More';

  @override
  String get addLentItem => 'Add Lent Item';

  @override
  String get addBorrowedItem => 'Add Borrowed Item';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get buttonOk => 'OK';

  @override
  String get vacationNoAccountsAvailable => 'No vacation accounts available.';

  @override
  String get exportFormat => 'Format';

  @override
  String get exportOptions => 'Options';

  @override
  String get exportAccountData => 'Export Account Data';

  @override
  String get exportGoalsData => 'Export Goals Data';

  @override
  String get exportCurrentMonth => 'Current Month';

  @override
  String get exportLast30Days => 'Last 30 Days';

  @override
  String get exportLast90Days => 'Last 90 Days';

  @override
  String get exportLast365Days => 'Last 365 Days';

  @override
  String get exportCsv => 'CSV';

  @override
  String get exportJson => 'JSON';

  @override
  String get exportImportInstructions =>
      'You can import your data from a CSV file into the app.';

  @override
  String get exportInstructions1 =>
      'Save the example file to see the required data format;';

  @override
  String get exportInstructions2 =>
      'Format your data according to the template. Make sure that the columns, their order and names are exactly the same as in the template. The names of columns should be in English;';

  @override
  String get exportInstructions3 => 'Press Import and select your file;';

  @override
  String get exportInstructions4 =>
      'Choose whether to override existing data or add imported data to the existing data. When choosing the override option, existing data will be permanently deleted;';

  @override
  String get exportButtonExport => 'Export';

  @override
  String get exportButtonImport => 'Import';

  @override
  String get exportTabExport => 'Export';

  @override
  String get exportTabImport => 'Import';

  @override
  String get enableVacationMode => 'Enable Vacation Mode';

  @override
  String get addProgress => 'Add Progress';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get pleaseSelectCurrency => 'Please select a currency';

  @override
  String get pleaseSelectAccount => 'Please select an account';

  @override
  String get pleaseSelectDate => 'Please select a date';

  @override
  String get pleaseSelectIcon => 'Please select an icon';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String get markAsReturned => 'Mark as Returned';

  @override
  String get markPayment => 'Mark Payment';

  @override
  String get markPaid => 'Mark Paid';

  @override
  String get deleteItem => 'Delete Item';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAllAssociatedTransactions =>
      'Delete all associated transactions';

  @override
  String get normalMode => 'Normal Mode';

  @override
  String get changeCurrency => 'Change Currency';

  @override
  String get vacationModeDialog => 'Vacation Mode Dialog';

  @override
  String get categoryAndTransactionsDeleted =>
      'Category and associated transactions deleted successfully';

  @override
  String get select => 'Select';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get yourData => 'Your Data';

  @override
  String get profileMenuAccount => 'ACCOUNT';

  @override
  String get profileMenuCurrency => 'Currency';

  @override
  String get profileSectionLegal => 'LEGAL';

  @override
  String get profileTermsConditions => 'Terms & Conditions';

  @override
  String get profilePrivacyPolicy => 'Privacy Policy';

  @override
  String get profileSectionSupport => 'SUPPORT';

  @override
  String get profileHelpSupport => 'Help & Support';

  @override
  String get profileSectionDanger => 'DANGER ZONE';

  @override
  String get currencyPageChange => 'CHANGE';

  @override
  String get addTransactionNotes => 'Notes';

  @override
  String get addTransactionMore => 'More';

  @override
  String get addTransactionDate => 'Date';

  @override
  String get addTransactionTime => 'Time';

  @override
  String get addTransactionPaid => 'Paid';

  @override
  String get addTransactionColor => 'Color';

  @override
  String get addTransactionCancel => 'Cancel';

  @override
  String get addTransactionCreate => 'Create';

  @override
  String get addTransactionUpdate => 'Update';

  @override
  String get addBudgetLimitAmount => 'Limit Amount';

  @override
  String get addBudgetSelectCategory => 'Select Category';

  @override
  String get addBudgetBudgetType => 'Budget Type';

  @override
  String get addBudgetRecurring => 'Recurring Budget';

  @override
  String get addBudgetRecurringSubtitle =>
      'Automatically renew this budget for each period';

  @override
  String get addBudgetRecurringDailySubtitle => 'Applies to every day';

  @override
  String get addBudgetRecurringPremiumSubtitle =>
      'Premium feature - Subscribe to enable';

  @override
  String get addBudget => 'Add Budget';

  @override
  String get addAccountTransactionLimit => 'Transaction Limit';

  @override
  String get addAccountAccountType => 'Account Type';

  @override
  String get addAccountAdd => 'Add';

  @override
  String get addAccountBalance => 'Balance';

  @override
  String get addAccountCredit => 'Credit';

  @override
  String get homeIncomeCard => 'Income';

  @override
  String get homeExpenseCard => 'Expense';

  @override
  String get homeTotalBudget => 'Total Budget';

  @override
  String get balanceDetailInitialBalance => 'Initial Balance';

  @override
  String get balanceDetailCurrentBalance => 'Current Balance';

  @override
  String get expenseDetailTotal => 'Total';

  @override
  String get expenseDetailAccumulatedAmount => 'Accumulated Amount';

  @override
  String get expenseDetailPaidStatus => 'PAID/UNPAID';

  @override
  String get expenseDetailVacation => 'Vacation';

  @override
  String get expenseDetailMarkPaid => 'Mark as Paid';

  @override
  String get goalsScreenPending => 'Pending Goals';

  @override
  String get goalsScreenFulfilled => 'Fulfilled Goals';

  @override
  String get createGoalTitle => 'Create a pending goal';

  @override
  String get createGoalAmount => 'Amount';

  @override
  String get createGoalName => 'Name';

  @override
  String get createGoalCurrency => 'Currency';

  @override
  String get createGoalMore => 'More';

  @override
  String get createGoalNotes => 'Notes';

  @override
  String get createGoalDate => 'Date';

  @override
  String get createGoalColor => 'Color';

  @override
  String get personalScreenSubscriptions => 'Subscriptions';

  @override
  String get personalScreenBorrowed => 'Borrowed';

  @override
  String get personalScreenLent => 'Lent';

  @override
  String get personalScreenTotal => 'Total';

  @override
  String get personalScreenActive => 'Active';

  @override
  String get personalScreenNoSubscriptions => 'No subscriptions yet';

  @override
  String get personalScreenNoBorrowed => 'No Borrowed Items yet';

  @override
  String get personalScreenBorrowedItems => 'Borrowed items';

  @override
  String get personalScreenLentItems => 'Lent items';

  @override
  String get personalScreenNoLent => 'No lent items yet';

  @override
  String get addBorrowedTitle => 'Add Borrowed Item';

  @override
  String get addLentTitle => 'Add Lent Item';

  @override
  String get addBorrowedName => 'Name';

  @override
  String get addBorrowedAmount => 'Amount';

  @override
  String get addBorrowedNotes => 'Notes';

  @override
  String get addBorrowedMore => 'More';

  @override
  String get addBorrowedDate => 'Date';

  @override
  String get addBorrowedDueDate => 'Due Date';

  @override
  String get addBorrowedReturned => 'Returned';

  @override
  String get addBorrowedMarkReturned => 'Mark as Returned';

  @override
  String get addSubscriptionPrice => 'Price';

  @override
  String get addSubscriptionName => 'Name';

  @override
  String get addSubscriptionRecurrence => 'Recurrence';

  @override
  String get addSubscriptionMore => 'More';

  @override
  String get addSubscriptionNotes => 'Notes';

  @override
  String get addSubscriptionStartDate => 'Start Date';

  @override
  String get addLentName => 'Name';

  @override
  String get addLentAmount => 'Amount';

  @override
  String get addLentNotes => 'Notes';

  @override
  String get addLentMore => 'More';

  @override
  String get addLentDate => 'Date';

  @override
  String get addLentDueDate => 'Due Date';

  @override
  String get addLentReturned => 'Returned';

  @override
  String get addLentMarkReturned => 'Mark as Returned';

  @override
  String get currencyPageTitle => 'Currency Rates';

  @override
  String get profileVacationMode => 'Vacation Mode';

  @override
  String get profileCurrency => 'Currency';

  @override
  String get profileLegal => 'LEGAL';

  @override
  String get profileSupport => 'SUPPORT';

  @override
  String get profileDangerZone => 'DANGER ZONE';

  @override
  String get profileLogout => 'Logout';

  @override
  String get homeIncome => 'Income';

  @override
  String get homeExpense => 'Expense';

  @override
  String get expenseDetailPaidUnpaid => 'PAID/UNPAID';

  @override
  String get goalsScreenPendingGoals => 'Pending Goals';

  @override
  String get goalsScreenFulfilledGoals => 'Fulfilled Goals';

  @override
  String get transactionEditIncome => 'Edit Income';

  @override
  String get transactionEditExpense => 'Edit Expense';

  @override
  String get transactionPlanIncome => 'Plan an Income';

  @override
  String get transactionPlanExpense => 'Plan an Expense';

  @override
  String get goal => 'Goal';

  @override
  String get none => 'None';

  @override
  String get unnamedCategory => 'Unnamed Category';

  @override
  String get month => 'Month';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';
}
