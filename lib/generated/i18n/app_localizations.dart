import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i18n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
  ];

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and password to log in'**
  String get loginSubtitle;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @orLoginWith.
  ///
  /// In en, this message translates to:
  /// **'Or login with'**
  String get orLoginWith;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to recover password'**
  String get forgotPasswordSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Please check your inbox.'**
  String get passwordResetEmailSent;

  /// No description provided for @getStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStartedTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to continue'**
  String get createAccountSubtitle;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordHint;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or Continue with'**
  String get orContinueWith;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @selectCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrencyTitle;

  /// No description provided for @selectCurrencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred Currency'**
  String get selectCurrencySubtitle;

  /// No description provided for @selectCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrencyLabel;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @errorDuringSetup.
  ///
  /// In en, this message translates to:
  /// **'Error during setup: {error}'**
  String errorDuringSetup(Object error);

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Save Smarter'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Description.
  ///
  /// In en, this message translates to:
  /// **'Set aside money effortlessly and watch your savings grow with every step.'**
  String get onboardingPage1Description;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Achieve Your Goals'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Description.
  ///
  /// In en, this message translates to:
  /// **'Create financial goals, from a new gadget to your dream trip, and track your progress.'**
  String get onboardingPage2Description;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Stay on Track'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Description.
  ///
  /// In en, this message translates to:
  /// **'Monitor your spending, income, and savings all in one simple dashboard.'**
  String get onboardingPage3Description;

  /// No description provided for @paywallCouldNotLoadPlans.
  ///
  /// In en, this message translates to:
  /// **'Could not load plans.\nPlease try again later.'**
  String get paywallCouldNotLoadPlans;

  /// No description provided for @paywallChooseYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get paywallChooseYourPlan;

  /// No description provided for @paywallInvestInFinancialFreedom.
  ///
  /// In en, this message translates to:
  /// **'Invest in your financial freedom today'**
  String get paywallInvestInFinancialFreedom;

  /// No description provided for @paywallPricePerDay.
  ///
  /// In en, this message translates to:
  /// **'{price}/day'**
  String paywallPricePerDay(Object price);

  /// No description provided for @paywallSaveAmount.
  ///
  /// In en, this message translates to:
  /// **'Save {amount}'**
  String paywallSaveAmount(Object amount);

  /// No description provided for @paywallEverythingIncluded.
  ///
  /// In en, this message translates to:
  /// **'Everything included:'**
  String get paywallEverythingIncluded;

  /// No description provided for @paywallPersonalizedBudgetInsights.
  ///
  /// In en, this message translates to:
  /// **'Vacation Mode'**
  String get paywallPersonalizedBudgetInsights;

  /// No description provided for @paywallDailyProgressTracking.
  ///
  /// In en, this message translates to:
  /// **'Multi-account creation'**
  String get paywallDailyProgressTracking;

  /// No description provided for @paywallExpenseManagementTools.
  ///
  /// In en, this message translates to:
  /// **'Recurring Budgets'**
  String get paywallExpenseManagementTools;

  /// No description provided for @paywallFinancialHealthTimeline.
  ///
  /// In en, this message translates to:
  /// **'Colors and Icon customization'**
  String get paywallFinancialHealthTimeline;

  /// No description provided for @paywallExpertGuidanceTips.
  ///
  /// In en, this message translates to:
  /// **'Custom categories'**
  String get paywallExpertGuidanceTips;

  /// No description provided for @paywallCommunitySupportAccess.
  ///
  /// In en, this message translates to:
  /// **'Community support access'**
  String get paywallCommunitySupportAccess;

  /// No description provided for @paywallSaveYourFinances.
  ///
  /// In en, this message translates to:
  /// **'Save your finances and future'**
  String get paywallSaveYourFinances;

  /// No description provided for @paywallAverageUserSaves.
  ///
  /// In en, this message translates to:
  /// **'Average user saves ~£2,500 per year by budgeting effectively'**
  String get paywallAverageUserSaves;

  /// No description provided for @paywallSubscribeYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Your Plan'**
  String get paywallSubscribeYourPlan;

  /// No description provided for @paywallPleaseSelectPlan.
  ///
  /// In en, this message translates to:
  /// **'Please select a plan.'**
  String get paywallPleaseSelectPlan;

  /// No description provided for @paywallSubscriptionActivated.
  ///
  /// In en, this message translates to:
  /// **'Subscription activated! You now have access to premium features.'**
  String get paywallSubscriptionActivated;

  /// No description provided for @paywallFailedToPurchase.
  ///
  /// In en, this message translates to:
  /// **'Failed to purchase: {message}'**
  String paywallFailedToPurchase(Object message);

  /// No description provided for @paywallUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}'**
  String paywallUnexpectedError(Object error);

  /// No description provided for @paywallRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestorePurchases;

  /// No description provided for @paywallManageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get paywallManageSubscription;

  /// No description provided for @paywallPurchasesRestoredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully!'**
  String get paywallPurchasesRestoredSuccessfully;

  /// No description provided for @paywallNoActiveSubscriptionFound.
  ///
  /// In en, this message translates to:
  /// **'No active subscription found. You are now on the free plan.'**
  String get paywallNoActiveSubscriptionFound;

  /// No description provided for @paywallPerMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get paywallPerMonth;

  /// No description provided for @paywallPerYear.
  ///
  /// In en, this message translates to:
  /// **'per year'**
  String get paywallPerYear;

  /// No description provided for @paywallBestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get paywallBestValue;

  /// No description provided for @paywallMostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get paywallMostPopular;

  /// No description provided for @mainScreenHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get mainScreenHome;

  /// No description provided for @mainScreenBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get mainScreenBudget;

  /// No description provided for @mainScreenBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get mainScreenBalance;

  /// No description provided for @mainScreenGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get mainScreenGoals;

  /// No description provided for @mainScreenPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get mainScreenPersonal;

  /// No description provided for @mainScreenIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get mainScreenIncome;

  /// No description provided for @mainScreenExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get mainScreenExpense;

  /// No description provided for @balanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceTitle;

  /// No description provided for @balanceAddAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get balanceAddAccount;

  /// No description provided for @addAVacation.
  ///
  /// In en, this message translates to:
  /// **'Add A Vacation'**
  String get addAVacation;

  /// No description provided for @balanceMyAccounts.
  ///
  /// In en, this message translates to:
  /// **'MY ACCOUNTS'**
  String get balanceMyAccounts;

  /// No description provided for @balanceVacation.
  ///
  /// In en, this message translates to:
  /// **'VACATION'**
  String get balanceVacation;

  /// No description provided for @balanceAccountBalance.
  ///
  /// In en, this message translates to:
  /// **'Account Balance'**
  String get balanceAccountBalance;

  /// No description provided for @balanceNoAccountsFound.
  ///
  /// In en, this message translates to:
  /// **'No accounts found.'**
  String get balanceNoAccountsFound;

  /// No description provided for @balanceNoAccountsCreated.
  ///
  /// In en, this message translates to:
  /// **'No accounts created'**
  String get balanceNoAccountsCreated;

  /// No description provided for @balanceCreateFirstAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your first account to start tracking balances'**
  String get balanceCreateFirstAccount;

  /// No description provided for @balanceCreateFirstAccountFinances.
  ///
  /// In en, this message translates to:
  /// **'Create your first account to start tracking your finances'**
  String get balanceCreateFirstAccountFinances;

  /// No description provided for @balanceNoVacationsYet.
  ///
  /// In en, this message translates to:
  /// **'No vacations yet'**
  String get balanceNoVacationsYet;

  /// No description provided for @balanceCreateFirstVacation.
  ///
  /// In en, this message translates to:
  /// **'Create your first vacation account to start planning your trips'**
  String get balanceCreateFirstVacation;

  /// No description provided for @balanceCreateVacationAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Vacation Account'**
  String get balanceCreateVacationAccount;

  /// No description provided for @balanceSingleAccountView.
  ///
  /// In en, this message translates to:
  /// **'Single Account View'**
  String get balanceSingleAccountView;

  /// No description provided for @balanceAddMoreAccounts.
  ///
  /// In en, this message translates to:
  /// **'Add more accounts to see charts'**
  String get balanceAddMoreAccounts;

  /// No description provided for @balanceNoAccountsForCurrency.
  ///
  /// In en, this message translates to:
  /// **'No accounts found for selected currency'**
  String get balanceNoAccountsForCurrency;

  /// No description provided for @balanceCreditLimit.
  ///
  /// In en, this message translates to:
  /// **'Credit Limit: {value}'**
  String balanceCreditLimit(Object value);

  /// No description provided for @balanceBalanceLimit.
  ///
  /// In en, this message translates to:
  /// **'Balance Limit: {value}'**
  String balanceBalanceLimit(Object value);

  /// No description provided for @budgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetTitle;

  /// No description provided for @budgetAddBudget.
  ///
  /// In en, this message translates to:
  /// **'Add Budget'**
  String get budgetAddBudget;

  /// No description provided for @budgetDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get budgetDaily;

  /// No description provided for @budgetWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get budgetWeekly;

  /// No description provided for @budgetMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get budgetMonthly;

  /// No description provided for @budgetSelectWeek.
  ///
  /// In en, this message translates to:
  /// **'Select Week'**
  String get budgetSelectWeek;

  /// No description provided for @budgetSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get budgetSelectDate;

  /// No description provided for @budgetSelectDay.
  ///
  /// In en, this message translates to:
  /// **'Select Day'**
  String get budgetSelectDay;

  /// No description provided for @budgetCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get budgetCancel;

  /// No description provided for @budgetApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get budgetApply;

  /// No description provided for @budgetTotalSpending.
  ///
  /// In en, this message translates to:
  /// **'Total Spending'**
  String get budgetTotalSpending;

  /// No description provided for @budgetCategoryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Category Breakdown'**
  String get budgetCategoryBreakdown;

  /// No description provided for @budgetViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get budgetViewAll;

  /// No description provided for @budgetBudgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetBudgets;

  /// No description provided for @budgetNoBudgetCreated.
  ///
  /// In en, this message translates to:
  /// **'No budget created'**
  String get budgetNoBudgetCreated;

  /// No description provided for @budgetStartCreatingBudget.
  ///
  /// In en, this message translates to:
  /// **'Start by creating a budget to see your spending breakdown here.'**
  String get budgetStartCreatingBudget;

  /// No description provided for @budgetSetSpendingLimit.
  ///
  /// In en, this message translates to:
  /// **'Set spending limit'**
  String get budgetSetSpendingLimit;

  /// No description provided for @budgetEnterLimitAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter limit amount'**
  String get budgetEnterLimitAmount;

  /// No description provided for @budgetSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get budgetSave;

  /// No description provided for @budgetEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get budgetEnterValidNumber;

  /// No description provided for @budgetLimitSaved.
  ///
  /// In en, this message translates to:
  /// **'Budget limit saved'**
  String get budgetLimitSaved;

  /// No description provided for @budgetCreated.
  ///
  /// In en, this message translates to:
  /// **'Budget created'**
  String get budgetCreated;

  /// No description provided for @budgetTransactions.
  ///
  /// In en, this message translates to:
  /// **'transactions'**
  String get budgetTransactions;

  /// No description provided for @budgetOverBudget.
  ///
  /// In en, this message translates to:
  /// **'{amount} over budget'**
  String budgetOverBudget(Object amount);

  /// No description provided for @budgetRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining'**
  String budgetRemaining(Object amount);

  /// No description provided for @homeNoMoreTransactions.
  ///
  /// In en, this message translates to:
  /// **'No more transactions'**
  String get homeNoMoreTransactions;

  /// No description provided for @homeErrorLoadingMoreTransactions.
  ///
  /// In en, this message translates to:
  /// **'Error loading more transactions'**
  String get homeErrorLoadingMoreTransactions;

  /// No description provided for @homeRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get homeRetry;

  /// No description provided for @homeErrorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get homeErrorLoadingData;

  /// No description provided for @homeNoTransactionsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No transactions recorded'**
  String get homeNoTransactionsRecorded;

  /// No description provided for @homeStartAddingTransactions.
  ///
  /// In en, this message translates to:
  /// **'Start by adding transactions to see your spending breakdown here.'**
  String get homeStartAddingTransactions;

  /// No description provided for @homeCurrencyChange.
  ///
  /// In en, this message translates to:
  /// **'Currency Change'**
  String get homeCurrencyChange;

  /// No description provided for @homeCurrencyChangeMessage.
  ///
  /// In en, this message translates to:
  /// **'Changing your currency will convert all existing amounts. This action cannot be undone. Do you want to continue?'**
  String get homeCurrencyChangeMessage;

  /// No description provided for @homeNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get homeNo;

  /// No description provided for @homeYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get homeYes;

  /// No description provided for @homeVacationBudgetBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Vacation Budget Breakdown'**
  String get homeVacationBudgetBreakdown;

  /// No description provided for @homeBalanceBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Balance Breakdown'**
  String get homeBalanceBreakdown;

  /// No description provided for @homeClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get homeClose;

  /// No description provided for @transactionPickColor.
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get transactionPickColor;

  /// No description provided for @transactionSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get transactionSelectDate;

  /// No description provided for @transactionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get transactionCancel;

  /// No description provided for @transactionApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get transactionApply;

  /// No description provided for @transactionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get transactionAmount;

  /// No description provided for @transactionSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get transactionSelect;

  /// No description provided for @transactionPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get transactionPaid;

  /// No description provided for @transactionAddTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get transactionAddTransaction;

  /// No description provided for @transactionEditTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get transactionEditTransaction;

  /// No description provided for @transactionIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get transactionIncome;

  /// No description provided for @transactionExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get transactionExpense;

  /// No description provided for @transactionDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get transactionDescription;

  /// No description provided for @transactionCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get transactionCategory;

  /// No description provided for @transactionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get transactionAccount;

  /// No description provided for @transactionDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get transactionDate;

  /// No description provided for @transactionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get transactionSave;

  /// No description provided for @transactionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get transactionDelete;

  /// No description provided for @transactionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved successfully'**
  String get transactionSuccess;

  /// No description provided for @transactionError.
  ///
  /// In en, this message translates to:
  /// **'Error saving transaction'**
  String get transactionError;

  /// No description provided for @transactionDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get transactionDeleteConfirm;

  /// No description provided for @transactionDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted successfully'**
  String get transactionDeleteSuccess;

  /// No description provided for @goalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsTitle;

  /// No description provided for @goalsAddGoal.
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get goalsAddGoal;

  /// No description provided for @goalsNoGoalsCreated.
  ///
  /// In en, this message translates to:
  /// **'No goals created'**
  String get goalsNoGoalsCreated;

  /// No description provided for @goalsStartCreatingGoal.
  ///
  /// In en, this message translates to:
  /// **'Start by creating a goal to track your financial progress'**
  String get goalsStartCreatingGoal;

  /// No description provided for @goalsCreateGoal.
  ///
  /// In en, this message translates to:
  /// **'Create Goal'**
  String get goalsCreateGoal;

  /// No description provided for @goalsEditGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get goalsEditGoal;

  /// No description provided for @goalsGoalName.
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get goalsGoalName;

  /// No description provided for @goalsTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get goalsTargetAmount;

  /// No description provided for @goalsCurrentAmount.
  ///
  /// In en, this message translates to:
  /// **'Current Amount'**
  String get goalsCurrentAmount;

  /// No description provided for @goalsDeadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get goalsDeadline;

  /// No description provided for @goalsDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get goalsDescription;

  /// No description provided for @goalsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get goalsSave;

  /// No description provided for @goalsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get goalsCancel;

  /// No description provided for @goalsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get goalsDelete;

  /// No description provided for @goalsGoalCreated.
  ///
  /// In en, this message translates to:
  /// **'Goal created successfully'**
  String get goalsGoalCreated;

  /// No description provided for @goalsGoalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Goal updated successfully'**
  String get goalsGoalUpdated;

  /// No description provided for @goalsGoalDeleted.
  ///
  /// In en, this message translates to:
  /// **'Goal deleted successfully'**
  String get goalsGoalDeleted;

  /// No description provided for @goalsErrorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving goal'**
  String get goalsErrorSaving;

  /// No description provided for @goalsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this goal?'**
  String get goalsDeleteConfirm;

  /// No description provided for @goalsProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get goalsProgress;

  /// No description provided for @goalsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get goalsCompleted;

  /// No description provided for @goalsInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get goalsInProgress;

  /// No description provided for @goalsNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get goalsNotStarted;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profilePremiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium Active'**
  String get profilePremiumActive;

  /// No description provided for @profilePremiumDescription.
  ///
  /// In en, this message translates to:
  /// **'You have access to all premium features'**
  String get profilePremiumDescription;

  /// No description provided for @profileFreePlan.
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get profileFreePlan;

  /// No description provided for @profileUpgradeDescription.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to premium for advanced features'**
  String get profileUpgradeDescription;

  /// No description provided for @profileRenewalDate.
  ///
  /// In en, this message translates to:
  /// **'Renews on {date}'**
  String profileRenewalDate(Object date);

  /// No description provided for @profileExpiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires on {date}'**
  String profileExpiresOn(Object date);

  /// No description provided for @profileErrorSigningOut.
  ///
  /// In en, this message translates to:
  /// **'Error signing out: {error}'**
  String profileErrorSigningOut(Object error);

  /// No description provided for @profileUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get profileUserNotFound;

  /// No description provided for @profileEditDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Edit display name'**
  String get profileEditDisplayName;

  /// No description provided for @profileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @profileDisplayNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Display name updated successfully'**
  String get profileDisplayNameUpdated;

  /// No description provided for @profileErrorUpdatingName.
  ///
  /// In en, this message translates to:
  /// **'Error updating display name'**
  String get profileErrorUpdatingName;

  /// No description provided for @profileManageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get profileManageSubscription;

  /// No description provided for @profileRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get profileRestorePurchases;

  /// No description provided for @profileRefreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get profileRefreshStatus;

  /// No description provided for @profileSubscriptionRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Subscription status refreshed'**
  String get profileSubscriptionRefreshed;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @profileSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get profileSignOutConfirm;

  /// No description provided for @profileCurrencyRates.
  ///
  /// In en, this message translates to:
  /// **'Currency Rates'**
  String get profileCurrencyRates;

  /// No description provided for @profileCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get profileCategories;

  /// No description provided for @profileFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get profileFeedback;

  /// No description provided for @profileExportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get profileExportData;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get profileDisplayName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get profileSubscription;

  /// No description provided for @profileVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get profileVersion;

  /// No description provided for @personalTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personalTitle;

  /// No description provided for @personalSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get personalSubscriptions;

  /// No description provided for @personalBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get personalBorrowed;

  /// No description provided for @personalAddSubscription.
  ///
  /// In en, this message translates to:
  /// **'Add Subscription'**
  String get personalAddSubscription;

  /// No description provided for @personalAddLent.
  ///
  /// In en, this message translates to:
  /// **'Add Lent'**
  String get personalAddLent;

  /// No description provided for @personalAddBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Add Borrowed'**
  String get personalAddBorrowed;

  /// No description provided for @personalNoSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions found'**
  String get personalNoSubscriptions;

  /// No description provided for @personalNoLent.
  ///
  /// In en, this message translates to:
  /// **'No lent items found'**
  String get personalNoLent;

  /// No description provided for @personalNoBorrowed.
  ///
  /// In en, this message translates to:
  /// **'No borrowed items found'**
  String get personalNoBorrowed;

  /// No description provided for @personalStartAddingSubscription.
  ///
  /// In en, this message translates to:
  /// **'Start by adding a subscription to track your recurring payments'**
  String get personalStartAddingSubscription;

  /// No description provided for @personalStartAddingLent.
  ///
  /// In en, this message translates to:
  /// **'Start by adding lent items to track money you\'ve lent'**
  String get personalStartAddingLent;

  /// No description provided for @personalStartAddingBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Start by adding borrowed items to track money you\'ve borrowed'**
  String get personalStartAddingBorrowed;

  /// No description provided for @personalEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get personalEdit;

  /// No description provided for @personalDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get personalDelete;

  /// No description provided for @personalMarkAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get personalMarkAsPaid;

  /// No description provided for @personalMarkAsUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Unpaid'**
  String get personalMarkAsUnpaid;

  /// No description provided for @personalAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get personalAmount;

  /// No description provided for @personalDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get personalDescription;

  /// No description provided for @personalDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get personalDueDate;

  /// No description provided for @personalRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get personalRecurring;

  /// No description provided for @personalOneTime.
  ///
  /// In en, this message translates to:
  /// **'One Time'**
  String get personalOneTime;

  /// No description provided for @personalMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get personalMonthly;

  /// No description provided for @personalYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get personalYearly;

  /// No description provided for @personalWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get personalWeekly;

  /// No description provided for @personalDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get personalDaily;

  /// No description provided for @personalName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get personalName;

  /// No description provided for @personalCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get personalCategory;

  /// No description provided for @personalNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get personalNotes;

  /// No description provided for @personalSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get personalSave;

  /// No description provided for @personalCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get personalCancel;

  /// No description provided for @personalDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get personalDeleteConfirm;

  /// No description provided for @personalItemSaved.
  ///
  /// In en, this message translates to:
  /// **'Item saved successfully'**
  String get personalItemSaved;

  /// No description provided for @personalItemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted successfully'**
  String get personalItemDeleted;

  /// No description provided for @personalErrorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving item'**
  String get personalErrorSaving;

  /// No description provided for @personalErrorDeleting.
  ///
  /// In en, this message translates to:
  /// **'Error deleting item'**
  String get personalErrorDeleting;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get analyticsOverview;

  /// No description provided for @analyticsIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get analyticsIncome;

  /// No description provided for @analyticsExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get analyticsExpenses;

  /// No description provided for @analyticsSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get analyticsSavings;

  /// No description provided for @analyticsCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get analyticsCategories;

  /// No description provided for @analyticsTrends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get analyticsTrends;

  /// No description provided for @analyticsMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get analyticsMonthly;

  /// No description provided for @analyticsWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get analyticsWeekly;

  /// No description provided for @analyticsDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get analyticsDaily;

  /// No description provided for @analyticsYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get analyticsYearly;

  /// No description provided for @analyticsNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get analyticsNoData;

  /// No description provided for @analyticsStartTracking.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your finances to see analytics here'**
  String get analyticsStartTracking;

  /// No description provided for @analyticsTotalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get analyticsTotalIncome;

  /// No description provided for @analyticsTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get analyticsTotalExpenses;

  /// No description provided for @analyticsNetSavings.
  ///
  /// In en, this message translates to:
  /// **'Net Savings'**
  String get analyticsNetSavings;

  /// No description provided for @analyticsTopCategories.
  ///
  /// In en, this message translates to:
  /// **'Top Categories'**
  String get analyticsTopCategories;

  /// No description provided for @analyticsSpendingTrends.
  ///
  /// In en, this message translates to:
  /// **'Spending Trends'**
  String get analyticsSpendingTrends;

  /// No description provided for @analyticsIncomeTrends.
  ///
  /// In en, this message translates to:
  /// **'Income Trends'**
  String get analyticsIncomeTrends;

  /// No description provided for @analyticsSavingsRate.
  ///
  /// In en, this message translates to:
  /// **'Savings Rate'**
  String get analyticsSavingsRate;

  /// No description provided for @analyticsAverageDaily.
  ///
  /// In en, this message translates to:
  /// **'Average Daily'**
  String get analyticsAverageDaily;

  /// No description provided for @analyticsAverageWeekly.
  ///
  /// In en, this message translates to:
  /// **'Average Weekly'**
  String get analyticsAverageWeekly;

  /// No description provided for @analyticsAverageMonthly.
  ///
  /// In en, this message translates to:
  /// **'Average Monthly'**
  String get analyticsAverageMonthly;

  /// No description provided for @analyticsSelectPeriod.
  ///
  /// In en, this message translates to:
  /// **'Select Period'**
  String get analyticsSelectPeriod;

  /// No description provided for @analyticsExportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get analyticsExportData;

  /// No description provided for @analyticsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get analyticsRefresh;

  /// No description provided for @analyticsErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading analytics data'**
  String get analyticsErrorLoading;

  /// No description provided for @analyticsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get analyticsRetry;

  /// No description provided for @goalsSelectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get goalsSelectColor;

  /// No description provided for @goalsMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get goalsMore;

  /// No description provided for @goalsName.
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get goalsName;

  /// No description provided for @goalsColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get goalsColor;

  /// No description provided for @goalsNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Goal name is required'**
  String get goalsNameRequired;

  /// No description provided for @goalsAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Target amount is required'**
  String get goalsAmountRequired;

  /// No description provided for @goalsAmountMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Target amount must be greater than 0'**
  String get goalsAmountMustBePositive;

  /// No description provided for @goalsDeadlineRequired.
  ///
  /// In en, this message translates to:
  /// **'Deadline is required'**
  String get goalsDeadlineRequired;

  /// No description provided for @goalsDeadlineMustBeFuture.
  ///
  /// In en, this message translates to:
  /// **'Deadline must be in the future'**
  String get goalsDeadlineMustBeFuture;

  /// No description provided for @goalsNameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'A goal with this name already exists'**
  String get goalsNameAlreadyExists;

  /// No description provided for @goalsErrorCreating.
  ///
  /// In en, this message translates to:
  /// **'Error creating goal: {error}'**
  String goalsErrorCreating(Object error);

  /// No description provided for @goalsErrorUpdating.
  ///
  /// In en, this message translates to:
  /// **'Error updating goal: {error}'**
  String goalsErrorUpdating(Object error);

  /// No description provided for @goalsErrorDeleting.
  ///
  /// In en, this message translates to:
  /// **'Error deleting goal: {error}'**
  String goalsErrorDeleting(Object error);

  /// No description provided for @expenseDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense Detail'**
  String get expenseDetailTitle;

  /// No description provided for @expenseDetailEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get expenseDetailEdit;

  /// No description provided for @expenseDetailDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get expenseDetailDelete;

  /// No description provided for @expenseDetailAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseDetailAmount;

  /// No description provided for @expenseDetailCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseDetailCategory;

  /// No description provided for @expenseDetailAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get expenseDetailAccount;

  /// No description provided for @expenseDetailDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get expenseDetailDate;

  /// No description provided for @expenseDetailDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get expenseDetailDescription;

  /// No description provided for @expenseDetailNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get expenseDetailNotes;

  /// No description provided for @expenseDetailSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get expenseDetailSave;

  /// No description provided for @expenseDetailCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get expenseDetailCancel;

  /// No description provided for @expenseDetailDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense?'**
  String get expenseDetailDeleteConfirm;

  /// No description provided for @expenseDetailUpdated.
  ///
  /// In en, this message translates to:
  /// **'Expense updated successfully'**
  String get expenseDetailUpdated;

  /// No description provided for @expenseDetailDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted successfully'**
  String get expenseDetailDeleted;

  /// No description provided for @expenseDetailErrorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving expense'**
  String get expenseDetailErrorSaving;

  /// No description provided for @expenseDetailErrorDeleting.
  ///
  /// In en, this message translates to:
  /// **'Error deleting expense'**
  String get expenseDetailErrorDeleting;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get calendarSelectDate;

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarToday;

  /// No description provided for @calendarThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get calendarThisWeek;

  /// No description provided for @calendarThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get calendarThisMonth;

  /// No description provided for @calendarThisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get calendarThisYear;

  /// No description provided for @calendarNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions on this date'**
  String get calendarNoTransactions;

  /// No description provided for @calendarStartAddingTransactions.
  ///
  /// In en, this message translates to:
  /// **'Start adding transactions to see them on the calendar'**
  String get calendarStartAddingTransactions;

  /// No description provided for @vacationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Vacation Mode'**
  String get vacationDialogTitle;

  /// No description provided for @vacationDialogEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable Vacation Mode'**
  String get vacationDialogEnable;

  /// No description provided for @vacationDialogDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable Vacation Mode'**
  String get vacationDialogDisable;

  /// No description provided for @vacationDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Vacation mode helps you track expenses during trips and holidays'**
  String get vacationDialogDescription;

  /// No description provided for @vacationDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get vacationDialogCancel;

  /// No description provided for @vacationDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get vacationDialogConfirm;

  /// No description provided for @vacationDialogEnabled.
  ///
  /// In en, this message translates to:
  /// **'Vacation mode enabled'**
  String get vacationDialogEnabled;

  /// No description provided for @vacationDialogDisabled.
  ///
  /// In en, this message translates to:
  /// **'Vacation mode disabled'**
  String get vacationDialogDisabled;

  /// No description provided for @balanceDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Detail'**
  String get balanceDetailTitle;

  /// No description provided for @balanceDetailEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get balanceDetailEdit;

  /// No description provided for @balanceDetailDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get balanceDetailDelete;

  /// No description provided for @balanceDetailTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get balanceDetailTransactions;

  /// No description provided for @balanceDetailBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceDetailBalance;

  /// No description provided for @balanceDetailCreditLimit.
  ///
  /// In en, this message translates to:
  /// **'Credit Limit'**
  String get balanceDetailCreditLimit;

  /// No description provided for @balanceDetailBalanceLimit.
  ///
  /// In en, this message translates to:
  /// **'Balance Limit'**
  String get balanceDetailBalanceLimit;

  /// No description provided for @balanceDetailCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get balanceDetailCurrency;

  /// No description provided for @balanceDetailAccountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get balanceDetailAccountType;

  /// No description provided for @balanceDetailAccountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get balanceDetailAccountName;

  /// No description provided for @balanceDetailSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get balanceDetailSave;

  /// No description provided for @balanceDetailCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get balanceDetailCancel;

  /// No description provided for @balanceDetailDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this account?'**
  String get balanceDetailDeleteConfirm;

  /// No description provided for @balanceDetailUpdated.
  ///
  /// In en, this message translates to:
  /// **'Account updated successfully'**
  String get balanceDetailUpdated;

  /// No description provided for @balanceDetailDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get balanceDetailDeleted;

  /// No description provided for @balanceDetailErrorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving account'**
  String get balanceDetailErrorSaving;

  /// No description provided for @balanceDetailErrorDeleting.
  ///
  /// In en, this message translates to:
  /// **'Error deleting account'**
  String get balanceDetailErrorDeleting;

  /// No description provided for @addAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccountTitle;

  /// No description provided for @addAccountEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get addAccountEditTitle;

  /// No description provided for @addAccountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get addAccountName;

  /// No description provided for @addAccountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get addAccountType;

  /// No description provided for @addAccountCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get addAccountCurrency;

  /// No description provided for @addAccountInitialBalance.
  ///
  /// In en, this message translates to:
  /// **'Initial Balance'**
  String get addAccountInitialBalance;

  /// No description provided for @addAccountCreditLimit.
  ///
  /// In en, this message translates to:
  /// **'Credit Limit'**
  String get addAccountCreditLimit;

  /// No description provided for @addAccountBalanceLimit.
  ///
  /// In en, this message translates to:
  /// **'Balance Limit'**
  String get addAccountBalanceLimit;

  /// No description provided for @addAccountColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get addAccountColor;

  /// No description provided for @addAccountIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get addAccountIcon;

  /// No description provided for @addAccountSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get addAccountSave;

  /// No description provided for @addAccountCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get addAccountCancel;

  /// No description provided for @addAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get addAccountCreated;

  /// No description provided for @addAccountUpdated.
  ///
  /// In en, this message translates to:
  /// **'Account updated successfully'**
  String get addAccountUpdated;

  /// No description provided for @addAccountErrorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving account'**
  String get addAccountErrorSaving;

  /// No description provided for @addAccountNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Account name is required'**
  String get addAccountNameRequired;

  /// No description provided for @addAccountTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Account type is required'**
  String get addAccountTypeRequired;

  /// No description provided for @addAccountCurrencyRequired.
  ///
  /// In en, this message translates to:
  /// **'Currency is required'**
  String get addAccountCurrencyRequired;

  /// No description provided for @budgetDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget Detail'**
  String get budgetDetailTitle;

  /// No description provided for @budgetDetailEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get budgetDetailEdit;

  /// No description provided for @budgetDetailDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get budgetDetailDelete;

  /// No description provided for @budgetDetailSpending.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get budgetDetailSpending;

  /// No description provided for @budgetDetailLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get budgetDetailLimit;

  /// No description provided for @budgetDetailRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get budgetDetailRemaining;

  /// No description provided for @budgetDetailOverBudget.
  ///
  /// In en, this message translates to:
  /// **'Over Budget'**
  String get budgetDetailOverBudget;

  /// No description provided for @budgetDetailCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get budgetDetailCategories;

  /// No description provided for @budgetDetailTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get budgetDetailTransactions;

  /// No description provided for @budgetDetailSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get budgetDetailSave;

  /// No description provided for @budgetDetailCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get budgetDetailCancel;

  /// No description provided for @budgetDetailDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this budget?'**
  String get budgetDetailDeleteConfirm;

  /// No description provided for @budgetDetailUpdated.
  ///
  /// In en, this message translates to:
  /// **'Budget updated successfully'**
  String get budgetDetailUpdated;

  /// No description provided for @budgetDetailDeleted.
  ///
  /// In en, this message translates to:
  /// **'Budget deleted successfully'**
  String get budgetDetailDeleted;

  /// No description provided for @budgetDetailErrorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving budget'**
  String get budgetDetailErrorSaving;

  /// No description provided for @budgetDetailErrorDeleting.
  ///
  /// In en, this message translates to:
  /// **'Error deleting budget'**
  String get budgetDetailErrorDeleting;

  /// No description provided for @addBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Budget'**
  String get addBudgetTitle;

  /// No description provided for @addBudgetEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get addBudgetEditTitle;

  /// No description provided for @addBudgetName.
  ///
  /// In en, this message translates to:
  /// **'Budget Name'**
  String get addBudgetName;

  /// No description provided for @addBudgetType.
  ///
  /// In en, this message translates to:
  /// **'Budget Type'**
  String get addBudgetType;

  /// No description provided for @addBudgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get addBudgetAmount;

  /// No description provided for @addBudgetCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get addBudgetCurrency;

  /// No description provided for @addBudgetPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get addBudgetPeriod;

  /// No description provided for @addBudgetCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get addBudgetCategories;

  /// No description provided for @addBudgetColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get addBudgetColor;

  /// No description provided for @addBudgetSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get addBudgetSave;

  /// No description provided for @addBudgetSaveBudget.
  ///
  /// In en, this message translates to:
  /// **'Save Budget'**
  String get addBudgetSaveBudget;

  /// No description provided for @addBudgetCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get addBudgetCancel;

  /// No description provided for @addBudgetCreated.
  ///
  /// In en, this message translates to:
  /// **'Budget created successfully'**
  String get addBudgetCreated;

  /// No description provided for @addBudgetUpdated.
  ///
  /// In en, this message translates to:
  /// **'Budget updated successfully'**
  String get addBudgetUpdated;

  /// No description provided for @addBudgetErrorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving budget'**
  String get addBudgetErrorSaving;

  /// No description provided for @addBudgetNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Budget name is required'**
  String get addBudgetNameRequired;

  /// No description provided for @addBudgetAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Budget amount is required'**
  String get addBudgetAmountRequired;

  /// No description provided for @addBudgetAmountMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Budget amount must be greater than 0'**
  String get addBudgetAmountMustBePositive;

  /// No description provided for @addBudgetCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get addBudgetCategoryRequired;

  /// No description provided for @budgetDetailNoBudgetToDelete.
  ///
  /// In en, this message translates to:
  /// **'No budget to delete. This is just a placeholder for transactions.'**
  String get budgetDetailNoBudgetToDelete;

  /// No description provided for @personalItemDetails.
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get personalItemDetails;

  /// No description provided for @personalStartDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a start date'**
  String get personalStartDateRequired;

  /// No description provided for @profileMainCurrency.
  ///
  /// In en, this message translates to:
  /// **'MAIN CURRENCY'**
  String get profileMainCurrency;

  /// No description provided for @profileFeedbackThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get profileFeedbackThankYou;

  /// No description provided for @profileFeedbackEmailError.
  ///
  /// In en, this message translates to:
  /// **'Could not open email client.'**
  String get profileFeedbackEmailError;

  /// No description provided for @feedbackModalTitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoying the app?'**
  String get feedbackModalTitle;

  /// No description provided for @feedbackModalDescription.
  ///
  /// In en, this message translates to:
  /// **'Your feedback keeps us motivated and helps us improve.'**
  String get feedbackModalDescription;

  /// No description provided for @goalNameAlreadyExistsSnackbar.
  ///
  /// In en, this message translates to:
  /// **'A goal with this name already exists'**
  String get goalNameAlreadyExistsSnackbar;

  /// No description provided for @lentSelectBothDates.
  ///
  /// In en, this message translates to:
  /// **'Please select both date and due date'**
  String get lentSelectBothDates;

  /// No description provided for @lentDueDateBeforeLentDate.
  ///
  /// In en, this message translates to:
  /// **'Due date cannot be before the lent date'**
  String get lentDueDateBeforeLentDate;

  /// No description provided for @lentItemAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Lent item added successfully'**
  String get lentItemAddedSuccessfully;

  /// No description provided for @lentItemError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String lentItemError(Object error);

  /// No description provided for @borrowedSelectBothDates.
  ///
  /// In en, this message translates to:
  /// **'Please select both date and due date'**
  String get borrowedSelectBothDates;

  /// No description provided for @borrowedDueDateBeforeBorrowedDate.
  ///
  /// In en, this message translates to:
  /// **'Due date cannot be before the borrowed date'**
  String get borrowedDueDateBeforeBorrowedDate;

  /// No description provided for @borrowedItemAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Borrowed item added successfully'**
  String get borrowedItemAddedSuccessfully;

  /// No description provided for @borrowedItemError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String borrowedItemError(Object error);

  /// No description provided for @subscriptionCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Subscription created successfully'**
  String get subscriptionCreatedSuccessfully;

  /// No description provided for @subscriptionError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String subscriptionError(Object error);

  /// No description provided for @paymentMarkedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Payment marked successfully'**
  String get paymentMarkedSuccessfully;

  /// No description provided for @subscriptionContinued.
  ///
  /// In en, this message translates to:
  /// **'Subscription continued successfully'**
  String get subscriptionContinued;

  /// No description provided for @subscriptionPaused.
  ///
  /// In en, this message translates to:
  /// **'Subscription paused successfully'**
  String get subscriptionPaused;

  /// No description provided for @itemMarkedAsReturnedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Item marked as returned successfully'**
  String get itemMarkedAsReturnedSuccessfully;

  /// No description provided for @itemDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Item deleted successfully'**
  String get itemDeletedSuccessfully;

  /// No description provided for @failedToDeleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete budget'**
  String get failedToDeleteBudget;

  /// No description provided for @failedToDeleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete goal'**
  String get failedToDeleteGoal;

  /// No description provided for @failedToSaveTransaction.
  ///
  /// In en, this message translates to:
  /// **'Failed to save transaction: {error}'**
  String failedToSaveTransaction(Object error);

  /// No description provided for @failedToReorderCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to reorder categories. Reverting changes.'**
  String get failedToReorderCategories;

  /// No description provided for @categoryAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category added successfully'**
  String get categoryAddedSuccessfully;

  /// No description provided for @failedToAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Failed to add category: {error}'**
  String failedToAddCategory(Object error);

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @errorCreatingGoal.
  ///
  /// In en, this message translates to:
  /// **'Error creating goal: {error}'**
  String errorCreatingGoal(Object error);

  /// No description provided for @hintName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get hintName;

  /// No description provided for @hintDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get hintDescription;

  /// No description provided for @hintSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get hintSelectDate;

  /// No description provided for @hintSelectDueDate.
  ///
  /// In en, this message translates to:
  /// **'Select Due Date'**
  String get hintSelectDueDate;

  /// No description provided for @hintSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get hintSelectCategory;

  /// No description provided for @hintSelectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get hintSelectAccount;

  /// No description provided for @hintSelectGoal.
  ///
  /// In en, this message translates to:
  /// **'Select Goal'**
  String get hintSelectGoal;

  /// No description provided for @hintNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get hintNotes;

  /// No description provided for @hintSelectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get hintSelectColor;

  /// No description provided for @hintEnterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Enter category name'**
  String get hintEnterCategoryName;

  /// No description provided for @hintSelectType.
  ///
  /// In en, this message translates to:
  /// **'Select Type'**
  String get hintSelectType;

  /// No description provided for @hintWriteThoughts.
  ///
  /// In en, this message translates to:
  /// **'Write about your thoughts here......'**
  String get hintWriteThoughts;

  /// No description provided for @hintEnterDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Enter display name'**
  String get hintEnterDisplayName;

  /// No description provided for @hintSelectBudgetType.
  ///
  /// In en, this message translates to:
  /// **'Select Budget Type'**
  String get hintSelectBudgetType;

  /// No description provided for @hintSelectAccountType.
  ///
  /// In en, this message translates to:
  /// **'Select Account Type'**
  String get hintSelectAccountType;

  /// No description provided for @hintEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter Name'**
  String get hintEnterName;

  /// No description provided for @hintSelectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get hintSelectIcon;

  /// No description provided for @hintSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get hintSelect;

  /// No description provided for @hintAmountPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get hintAmountPlaceholder;

  /// No description provided for @labelValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get labelValue;

  /// No description provided for @labelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get labelName;

  /// No description provided for @labelDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get labelDescription;

  /// No description provided for @labelCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get labelCategory;

  /// No description provided for @labelDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get labelDate;

  /// No description provided for @labelDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get labelDueDate;

  /// No description provided for @labelColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get labelColor;

  /// No description provided for @labelNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get labelNotes;

  /// No description provided for @labelAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get labelAccount;

  /// No description provided for @labelMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get labelMore;

  /// No description provided for @labelHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get labelHome;

  /// No description provided for @titlePickColor.
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get titlePickColor;

  /// No description provided for @titleAddLentItem.
  ///
  /// In en, this message translates to:
  /// **'Add Lent Item'**
  String get titleAddLentItem;

  /// No description provided for @titleAddBorrowedItem.
  ///
  /// In en, this message translates to:
  /// **'Add Borrowed Item'**
  String get titleAddBorrowedItem;

  /// No description provided for @titleSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get titleSelectCategory;

  /// No description provided for @titleSelectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get titleSelectAccount;

  /// No description provided for @titleSelectGoal.
  ///
  /// In en, this message translates to:
  /// **'Select Goal'**
  String get titleSelectGoal;

  /// No description provided for @titleSelectType.
  ///
  /// In en, this message translates to:
  /// **'Select Type'**
  String get titleSelectType;

  /// No description provided for @titleSelectAccountType.
  ///
  /// In en, this message translates to:
  /// **'Select Account Type'**
  String get titleSelectAccountType;

  /// No description provided for @titleSelectBudgetType.
  ///
  /// In en, this message translates to:
  /// **'Select Budget Type'**
  String get titleSelectBudgetType;

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get validationNameRequired;

  /// No description provided for @validationAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get validationAmountRequired;

  /// No description provided for @validationPleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get validationPleaseEnterValidNumber;

  /// No description provided for @validationPleaseSelectIcon.
  ///
  /// In en, this message translates to:
  /// **'Please select an icon'**
  String get validationPleaseSelectIcon;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get buttonAdd;

  /// No description provided for @buttonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// No description provided for @switchAddProgress.
  ///
  /// In en, this message translates to:
  /// **'Add Progress'**
  String get switchAddProgress;

  /// No description provided for @pickColor.
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get pickColor;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Please select an icon'**
  String get selectIcon;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @hintAmount.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get hintAmount;

  /// No description provided for @hintItemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get hintItemName;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get amountRequired;

  /// No description provided for @validNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get validNumber;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @addLentItem.
  ///
  /// In en, this message translates to:
  /// **'Add Lent Item'**
  String get addLentItem;

  /// No description provided for @addBorrowedItem.
  ///
  /// In en, this message translates to:
  /// **'Add Borrowed Item'**
  String get addBorrowedItem;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @buttonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get buttonOk;

  /// No description provided for @vacationNoAccountsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No vacation accounts available.'**
  String get vacationNoAccountsAvailable;

  /// No description provided for @exportFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get exportFormat;

  /// No description provided for @exportOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get exportOptions;

  /// No description provided for @exportAccountData.
  ///
  /// In en, this message translates to:
  /// **'Export Account Data'**
  String get exportAccountData;

  /// No description provided for @exportGoalsData.
  ///
  /// In en, this message translates to:
  /// **'Export Goals Data'**
  String get exportGoalsData;

  /// No description provided for @exportCurrentMonth.
  ///
  /// In en, this message translates to:
  /// **'Current Month'**
  String get exportCurrentMonth;

  /// No description provided for @exportLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get exportLast30Days;

  /// No description provided for @exportLast90Days.
  ///
  /// In en, this message translates to:
  /// **'Last 90 Days'**
  String get exportLast90Days;

  /// No description provided for @exportLast365Days.
  ///
  /// In en, this message translates to:
  /// **'Last 365 Days'**
  String get exportLast365Days;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get exportCsv;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'JSON'**
  String get exportJson;

  /// No description provided for @exportImportInstructions.
  ///
  /// In en, this message translates to:
  /// **'You can import your data from a CSV file into the app.'**
  String get exportImportInstructions;

  /// No description provided for @exportInstructions1.
  ///
  /// In en, this message translates to:
  /// **'Save the example file to see the required data format;'**
  String get exportInstructions1;

  /// No description provided for @exportInstructions2.
  ///
  /// In en, this message translates to:
  /// **'Format your data according to the template. Make sure that the columns, their order and names are exactly the same as in the template. The names of columns should be in English;'**
  String get exportInstructions2;

  /// No description provided for @exportInstructions3.
  ///
  /// In en, this message translates to:
  /// **'Press Import and select your file;'**
  String get exportInstructions3;

  /// No description provided for @exportInstructions4.
  ///
  /// In en, this message translates to:
  /// **'Choose whether to override existing data or add imported data to the existing data. When choosing the override option, existing data will be permanently deleted;'**
  String get exportInstructions4;

  /// No description provided for @exportButtonExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportButtonExport;

  /// No description provided for @exportButtonImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get exportButtonImport;

  /// No description provided for @exportTabExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportTabExport;

  /// No description provided for @exportTabImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get exportTabImport;

  /// No description provided for @enableVacationMode.
  ///
  /// In en, this message translates to:
  /// **'Enable Vacation Mode'**
  String get enableVacationMode;

  /// No description provided for @addProgress.
  ///
  /// In en, this message translates to:
  /// **'Add Progress'**
  String get addProgress;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @pleaseSelectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Please select a currency'**
  String get pleaseSelectCurrency;

  /// No description provided for @pleaseSelectAccount.
  ///
  /// In en, this message translates to:
  /// **'Please select an account'**
  String get pleaseSelectAccount;

  /// No description provided for @pleaseSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get pleaseSelectDate;

  /// No description provided for @pleaseSelectIcon.
  ///
  /// In en, this message translates to:
  /// **'Please select an icon'**
  String get pleaseSelectIcon;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @markAsReturned.
  ///
  /// In en, this message translates to:
  /// **'Mark as Returned'**
  String get markAsReturned;

  /// No description provided for @markPayment.
  ///
  /// In en, this message translates to:
  /// **'Mark Payment'**
  String get markPayment;

  /// No description provided for @markPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark Paid'**
  String get markPaid;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItem;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAllAssociatedTransactions.
  ///
  /// In en, this message translates to:
  /// **'Delete all associated transactions'**
  String get deleteAllAssociatedTransactions;

  /// No description provided for @normalMode.
  ///
  /// In en, this message translates to:
  /// **'Normal Mode'**
  String get normalMode;

  /// No description provided for @normalModeWithCurrency.
  ///
  /// In en, this message translates to:
  /// **'You are now in Normal Mode with currency: {currency}'**
  String normalModeWithCurrency(String currency);

  /// No description provided for @changeCurrency.
  ///
  /// In en, this message translates to:
  /// **'Change Currency'**
  String get changeCurrency;

  /// No description provided for @vacationModeDialog.
  ///
  /// In en, this message translates to:
  /// **'Vacation Mode Dialog'**
  String get vacationModeDialog;

  /// No description provided for @categoryAndTransactionsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category and associated transactions deleted successfully'**
  String get categoryAndTransactionsDeleted;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yourData.
  ///
  /// In en, this message translates to:
  /// **'Your Data'**
  String get yourData;

  /// No description provided for @profileMenuAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get profileMenuAccount;

  /// No description provided for @profileMenuCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get profileMenuCurrency;

  /// No description provided for @profileSectionLegal.
  ///
  /// In en, this message translates to:
  /// **'LEGAL'**
  String get profileSectionLegal;

  /// No description provided for @profileTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get profileTermsConditions;

  /// No description provided for @profilePrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profilePrivacyPolicy;

  /// No description provided for @profileSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get profileSectionSupport;

  /// No description provided for @profileHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profileHelpSupport;

  /// No description provided for @profileSectionDanger.
  ///
  /// In en, this message translates to:
  /// **'DANGER ZONE'**
  String get profileSectionDanger;

  /// No description provided for @currencyPageChange.
  ///
  /// In en, this message translates to:
  /// **'CHANGE'**
  String get currencyPageChange;

  /// No description provided for @addTransactionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get addTransactionNotes;

  /// No description provided for @addTransactionMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get addTransactionMore;

  /// No description provided for @addTransactionDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get addTransactionDate;

  /// No description provided for @addTransactionTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get addTransactionTime;

  /// No description provided for @addTransactionPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get addTransactionPaid;

  /// No description provided for @addTransactionColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get addTransactionColor;

  /// No description provided for @addTransactionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get addTransactionCancel;

  /// No description provided for @addTransactionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get addTransactionCreate;

  /// No description provided for @addTransactionUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get addTransactionUpdate;

  /// No description provided for @addBudgetLimitAmount.
  ///
  /// In en, this message translates to:
  /// **'Limit Amount'**
  String get addBudgetLimitAmount;

  /// No description provided for @addBudgetSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get addBudgetSelectCategory;

  /// No description provided for @addBudgetBudgetType.
  ///
  /// In en, this message translates to:
  /// **'Budget Type'**
  String get addBudgetBudgetType;

  /// No description provided for @addBudgetRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring Budget'**
  String get addBudgetRecurring;

  /// No description provided for @addBudgetRecurringSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically renew this budget for each period'**
  String get addBudgetRecurringSubtitle;

  /// No description provided for @addBudgetRecurringDailySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Applies to every day'**
  String get addBudgetRecurringDailySubtitle;

  /// No description provided for @addBudgetRecurringPremiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Premium feature - Subscribe to enable'**
  String get addBudgetRecurringPremiumSubtitle;

  /// No description provided for @addBudget.
  ///
  /// In en, this message translates to:
  /// **'Add Budget'**
  String get addBudget;

  /// No description provided for @addAccountTransactionLimit.
  ///
  /// In en, this message translates to:
  /// **'Transaction Limit'**
  String get addAccountTransactionLimit;

  /// No description provided for @addAccountAccountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get addAccountAccountType;

  /// No description provided for @addAccountAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAccountAdd;

  /// No description provided for @addAccountBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get addAccountBalance;

  /// No description provided for @addAccountCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get addAccountCredit;

  /// No description provided for @homeIncomeCard.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get homeIncomeCard;

  /// No description provided for @homeExpenseCard.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get homeExpenseCard;

  /// No description provided for @homeTotalBudget.
  ///
  /// In en, this message translates to:
  /// **'Total Budget'**
  String get homeTotalBudget;

  /// No description provided for @balanceDetailInitialBalance.
  ///
  /// In en, this message translates to:
  /// **'Initial Balance'**
  String get balanceDetailInitialBalance;

  /// No description provided for @balanceDetailCurrentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get balanceDetailCurrentBalance;

  /// No description provided for @expenseDetailTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get expenseDetailTotal;

  /// No description provided for @expenseDetailAccumulatedAmount.
  ///
  /// In en, this message translates to:
  /// **'Accumulated Amount'**
  String get expenseDetailAccumulatedAmount;

  /// No description provided for @expenseDetailPaidStatus.
  ///
  /// In en, this message translates to:
  /// **'PAID/UNPAID'**
  String get expenseDetailPaidStatus;

  /// No description provided for @expenseDetailVacation.
  ///
  /// In en, this message translates to:
  /// **'Vacation'**
  String get expenseDetailVacation;

  /// No description provided for @expenseDetailMarkPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get expenseDetailMarkPaid;

  /// No description provided for @expenseDetailMarkUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Unpaid'**
  String get expenseDetailMarkUnpaid;

  /// No description provided for @goalsScreenPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Goals'**
  String get goalsScreenPending;

  /// No description provided for @goalsScreenFulfilled.
  ///
  /// In en, this message translates to:
  /// **'Fulfilled Goals'**
  String get goalsScreenFulfilled;

  /// No description provided for @createGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a pending goal'**
  String get createGoalTitle;

  /// No description provided for @createGoalAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get createGoalAmount;

  /// No description provided for @createGoalName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get createGoalName;

  /// No description provided for @createGoalCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get createGoalCurrency;

  /// No description provided for @createGoalMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get createGoalMore;

  /// No description provided for @createGoalNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get createGoalNotes;

  /// No description provided for @createGoalDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get createGoalDate;

  /// No description provided for @createGoalColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get createGoalColor;

  /// No description provided for @createGoalLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the goal limit. Upgrade to premium to create unlimited goals.'**
  String get createGoalLimitReached;

  /// No description provided for @personalScreenSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get personalScreenSubscriptions;

  /// No description provided for @personalScreenBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get personalScreenBorrowed;

  /// No description provided for @personalScreenLent.
  ///
  /// In en, this message translates to:
  /// **'Lent'**
  String get personalScreenLent;

  /// No description provided for @personalScreenTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get personalScreenTotal;

  /// No description provided for @personalScreenActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get personalScreenActive;

  /// No description provided for @personalScreenNoSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions yet'**
  String get personalScreenNoSubscriptions;

  /// No description provided for @personalScreenNoBorrowed.
  ///
  /// In en, this message translates to:
  /// **'No Borrowed Items yet'**
  String get personalScreenNoBorrowed;

  /// No description provided for @personalScreenBorrowedItems.
  ///
  /// In en, this message translates to:
  /// **'Borrowed items'**
  String get personalScreenBorrowedItems;

  /// No description provided for @personalScreenLentItems.
  ///
  /// In en, this message translates to:
  /// **'Lent items'**
  String get personalScreenLentItems;

  /// No description provided for @personalScreenNoLent.
  ///
  /// In en, this message translates to:
  /// **'No lent items yet'**
  String get personalScreenNoLent;

  /// No description provided for @addBorrowedTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Borrowed Item'**
  String get addBorrowedTitle;

  /// No description provided for @addLentTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Lent Item'**
  String get addLentTitle;

  /// No description provided for @addBorrowedName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addBorrowedName;

  /// No description provided for @addBorrowedAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get addBorrowedAmount;

  /// No description provided for @addBorrowedNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get addBorrowedNotes;

  /// No description provided for @addBorrowedMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get addBorrowedMore;

  /// No description provided for @addBorrowedDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get addBorrowedDate;

  /// No description provided for @addBorrowedDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get addBorrowedDueDate;

  /// No description provided for @addBorrowedReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get addBorrowedReturned;

  /// No description provided for @addBorrowedMarkReturned.
  ///
  /// In en, this message translates to:
  /// **'Mark as Returned'**
  String get addBorrowedMarkReturned;

  /// No description provided for @addSubscriptionPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get addSubscriptionPrice;

  /// No description provided for @addSubscriptionName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addSubscriptionName;

  /// No description provided for @addSubscriptionRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get addSubscriptionRecurrence;

  /// No description provided for @addSubscriptionMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get addSubscriptionMore;

  /// No description provided for @addSubscriptionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get addSubscriptionNotes;

  /// No description provided for @addSubscriptionStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get addSubscriptionStartDate;

  /// No description provided for @addLentName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addLentName;

  /// No description provided for @addLentAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get addLentAmount;

  /// No description provided for @addLentNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get addLentNotes;

  /// No description provided for @addLentMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get addLentMore;

  /// No description provided for @addLentDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get addLentDate;

  /// No description provided for @addLentDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get addLentDueDate;

  /// No description provided for @addLentReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get addLentReturned;

  /// No description provided for @addLentMarkReturned.
  ///
  /// In en, this message translates to:
  /// **'Mark as Returned'**
  String get addLentMarkReturned;

  /// No description provided for @currencyPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency Rates'**
  String get currencyPageTitle;

  /// No description provided for @profileVacationMode.
  ///
  /// In en, this message translates to:
  /// **'Vacation Mode'**
  String get profileVacationMode;

  /// No description provided for @profileCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get profileCurrency;

  /// No description provided for @profileLegal.
  ///
  /// In en, this message translates to:
  /// **'LEGAL'**
  String get profileLegal;

  /// No description provided for @profileSupport.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get profileSupport;

  /// No description provided for @profileDangerZone.
  ///
  /// In en, this message translates to:
  /// **'DANGER ZONE'**
  String get profileDangerZone;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccountTitle;

  /// No description provided for @profileDeleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone. All your data including accounts, transactions, budgets, and goals will be permanently deleted.'**
  String get profileDeleteAccountMessage;

  /// No description provided for @profileDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profileDeleteAccountConfirm;

  /// No description provided for @profileDeleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get profileDeleteAccountSuccess;

  /// No description provided for @profileDeleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting account: {error}'**
  String profileDeleteAccountError(String error);

  /// No description provided for @homeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get homeIncome;

  /// No description provided for @homeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get homeExpense;

  /// No description provided for @expenseDetailPaidUnpaid.
  ///
  /// In en, this message translates to:
  /// **'PAID/UNPAID'**
  String get expenseDetailPaidUnpaid;

  /// No description provided for @goalsScreenPendingGoals.
  ///
  /// In en, this message translates to:
  /// **'Pending Goals'**
  String get goalsScreenPendingGoals;

  /// No description provided for @goalsScreenFulfilledGoals.
  ///
  /// In en, this message translates to:
  /// **'Fulfilled Goals'**
  String get goalsScreenFulfilledGoals;

  /// No description provided for @transactionEditIncome.
  ///
  /// In en, this message translates to:
  /// **'Edit Income'**
  String get transactionEditIncome;

  /// No description provided for @transactionEditExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get transactionEditExpense;

  /// No description provided for @transactionPlanIncome.
  ///
  /// In en, this message translates to:
  /// **'Plan an Income'**
  String get transactionPlanIncome;

  /// No description provided for @transactionPlanExpense.
  ///
  /// In en, this message translates to:
  /// **'Plan an Expense'**
  String get transactionPlanExpense;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @unnamedCategory.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Category'**
  String get unnamedCategory;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get languageSelectLanguage;

  /// No description provided for @vacationCurrencyDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Vacation Currency'**
  String get vacationCurrencyDialogTitle;

  /// No description provided for @vacationCurrencyDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'You can change currencies for your vacation transactions. Would you like to change the currency now?\n\nYour previous currency was {previousCurrency}.'**
  String vacationCurrencyDialogMessage(Object previousCurrency);

  /// No description provided for @vacationCurrencyDialogKeepCurrent.
  ///
  /// In en, this message translates to:
  /// **'Keep Current ({previousCurrency})'**
  String vacationCurrencyDialogKeepCurrent(Object previousCurrency);

  /// No description provided for @includeVacationTransaction.
  ///
  /// In en, this message translates to:
  /// **'Include Vacation Transactions'**
  String get includeVacationTransaction;

  /// No description provided for @showVacationTransactions.
  ///
  /// In en, this message translates to:
  /// **'Show vacation transactions in normal mode'**
  String get showVacationTransactions;

  /// No description provided for @balanceDetailTransactionsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Transactions for this account will appear here'**
  String get balanceDetailTransactionsWillAppear;

  /// No description provided for @personalNextBilling.
  ///
  /// In en, this message translates to:
  /// **'Next billing'**
  String get personalNextBilling;

  /// No description provided for @personalActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get personalActive;

  /// No description provided for @personalInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get personalInactive;

  /// No description provided for @personalReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get personalReturned;

  /// No description provided for @personalLent.
  ///
  /// In en, this message translates to:
  /// **'Lent'**
  String get personalLent;

  /// No description provided for @personalDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get personalDue;

  /// No description provided for @personalItems.
  ///
  /// In en, this message translates to:
  /// **'Item(s)'**
  String get personalItems;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @notReturned.
  ///
  /// In en, this message translates to:
  /// **'Not Returned'**
  String get notReturned;

  /// No description provided for @borrowedOn.
  ///
  /// In en, this message translates to:
  /// **'Borrowed On'**
  String get borrowedOn;

  /// No description provided for @lentOn.
  ///
  /// In en, this message translates to:
  /// **'Lent On'**
  String get lentOn;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get resume;

  /// No description provided for @upcomingBills.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Bills'**
  String get upcomingBills;

  /// No description provided for @upcomingCharge.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Charge'**
  String get upcomingCharge;

  /// No description provided for @pastHistory.
  ///
  /// In en, this message translates to:
  /// **'Past History'**
  String get pastHistory;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @budgetShowcaseAddBudget.
  ///
  /// In en, this message translates to:
  /// **'Add Budget'**
  String get budgetShowcaseAddBudget;

  /// No description provided for @budgetShowcaseAddBudgetDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap here to create a new budget and set spending limits for your categories.'**
  String get budgetShowcaseAddBudgetDesc;

  /// No description provided for @budgetShowcaseTypeSelector.
  ///
  /// In en, this message translates to:
  /// **'Budget Type'**
  String get budgetShowcaseTypeSelector;

  /// No description provided for @budgetShowcaseTypeSelectorDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch between Daily, Weekly, and Monthly budgets to track your spending over different time periods.'**
  String get budgetShowcaseTypeSelectorDesc;

  /// No description provided for @budgetShowcasePeriodSelector.
  ///
  /// In en, this message translates to:
  /// **'Period Selector'**
  String get budgetShowcasePeriodSelector;

  /// No description provided for @budgetShowcasePeriodSelectorDesc.
  ///
  /// In en, this message translates to:
  /// **'Navigate between different time periods to view your budget history.'**
  String get budgetShowcasePeriodSelectorDesc;

  /// No description provided for @budgetShowcasePieChart.
  ///
  /// In en, this message translates to:
  /// **'Spending Overview'**
  String get budgetShowcasePieChart;

  /// No description provided for @budgetShowcasePieChartDesc.
  ///
  /// In en, this message translates to:
  /// **'View your spending breakdown by category in this visual chart.'**
  String get budgetShowcasePieChartDesc;

  /// No description provided for @budgetShowcaseCategoryList.
  ///
  /// In en, this message translates to:
  /// **'Budget Categories'**
  String get budgetShowcaseCategoryList;

  /// No description provided for @budgetShowcaseCategoryListDesc.
  ///
  /// In en, this message translates to:
  /// **'See all your budgets organized by category. Tap any budget to view details and edit limits.'**
  String get budgetShowcaseCategoryListDesc;

  /// No description provided for @balanceShowcaseAddAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get balanceShowcaseAddAccount;

  /// No description provided for @balanceShowcaseAddAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap here to create a new account and start tracking your balances.'**
  String get balanceShowcaseAddAccountDesc;

  /// No description provided for @balanceShowcasePieChart.
  ///
  /// In en, this message translates to:
  /// **'Account Balance'**
  String get balanceShowcasePieChart;

  /// No description provided for @balanceShowcasePieChartDesc.
  ///
  /// In en, this message translates to:
  /// **'Visual overview of your account balances across different currencies.'**
  String get balanceShowcasePieChartDesc;

  /// No description provided for @balanceShowcaseAccountCard.
  ///
  /// In en, this message translates to:
  /// **'Account Cards'**
  String get balanceShowcaseAccountCard;

  /// No description provided for @balanceShowcaseAccountCardDesc.
  ///
  /// In en, this message translates to:
  /// **'View and manage all your accounts. Tap any account to see detailed transactions.'**
  String get balanceShowcaseAccountCardDesc;

  /// No description provided for @goalsShowcaseAddGoal.
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get goalsShowcaseAddGoal;

  /// No description provided for @goalsShowcaseAddGoalDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap here to create a new financial goal and track your progress.'**
  String get goalsShowcaseAddGoalDesc;

  /// No description provided for @goalsShowcaseToggle.
  ///
  /// In en, this message translates to:
  /// **'Goal Filter'**
  String get goalsShowcaseToggle;

  /// No description provided for @goalsShowcaseToggleDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch between Pending and Fulfilled goals to see your progress.'**
  String get goalsShowcaseToggleDesc;

  /// No description provided for @goalsShowcaseGoalItem.
  ///
  /// In en, this message translates to:
  /// **'Goal Cards'**
  String get goalsShowcaseGoalItem;

  /// No description provided for @goalsShowcaseGoalItemDesc.
  ///
  /// In en, this message translates to:
  /// **'View all your goals with progress tracking. Tap any goal to see details and add progress.'**
  String get goalsShowcaseGoalItemDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ko',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
