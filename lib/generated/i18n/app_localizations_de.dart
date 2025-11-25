// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get loginTitle => 'Anmelden';

  @override
  String get loginSubtitle =>
      'Geben Sie Ihre E-Mail und Ihr Passwort ein, um sich anzumelden';

  @override
  String get emailHint => 'E-Mail';

  @override
  String get passwordHint => 'Passwort';

  @override
  String get rememberMe => 'Angemeldet bleiben';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get loginButton => 'Anmelden';

  @override
  String get orLoginWith => 'Oder anmelden mit';

  @override
  String get dontHaveAccount => 'Sie haben noch kein Konto?';

  @override
  String get signUp => 'Registrieren';

  @override
  String get forgotPasswordTitle => 'Passwort vergessen';

  @override
  String get forgotPasswordSubtitle =>
      'Geben Sie Ihre E-Mail-Adresse ein, um Ihr Passwort wiederherzustellen';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get confirmButton => 'Bestätigen';

  @override
  String get passwordResetEmailSent =>
      'Passwort-Reset-E-Mail gesendet. Bitte überprüfen Sie Ihren Posteingang.';

  @override
  String get getStartedTitle => 'Loslegen';

  @override
  String get createAccountSubtitle =>
      'Erstellen Sie ein Konto, um fortzufahren';

  @override
  String get nameHint => 'Name';

  @override
  String get confirmPasswordHint => 'Passwort bestätigen';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get orContinueWith => 'Oder fortfahren mit';

  @override
  String get continueWithGoogle => 'Mit Google fortfahren';

  @override
  String get continueWithApple => 'Mit Apple fortfahren';

  @override
  String get alreadyHaveAccount => 'Haben Sie bereits ein Konto?';

  @override
  String get selectCurrencyTitle => 'Währung auswählen';

  @override
  String get selectCurrencySubtitle => 'Wählen Sie Ihre bevorzugte Währung';

  @override
  String get selectCurrencyLabel => 'Währung auswählen';

  @override
  String get continueButton => 'Weiter';

  @override
  String errorDuringSetup(Object error) {
    return 'Fehler bei der Einrichtung: $error';
  }

  @override
  String get backButton => 'Zurück';

  @override
  String get onboardingPage1Title => 'Intelligenter Sparen';

  @override
  String get onboardingPage1Description =>
      'Legen Sie mühelos Geld beiseite und sehen Sie zu, wie Ihre Ersparnisse mit jedem Schritt wachsen.';

  @override
  String get onboardingPage2Title => 'Ziele erreichen';

  @override
  String get onboardingPage2Description =>
      'Erstellen Sie finanzielle Ziele, von einem neuen Gadget bis zu Ihrer Traumreise, und verfolgen Sie Ihren Fortschritt.';

  @override
  String get onboardingPage3Title => 'Auf Kurs bleiben';

  @override
  String get onboardingPage3Description =>
      'Überwachen Sie Ihre Ausgaben, Einnahmen und Ersparnisse in einem einfachen Dashboard.';

  @override
  String get paywallCouldNotLoadPlans =>
      'Pläne konnten nicht geladen werden.\nBitte versuchen Sie es später erneut.';

  @override
  String get paywallChooseYourPlan => 'Wählen Sie Ihren Plan';

  @override
  String get paywallInvestInFinancialFreedom =>
      'Investieren Sie heute in Ihre finanzielle Freiheit';

  @override
  String paywallPricePerDay(Object price) {
    return '$price/Tag';
  }

  @override
  String paywallSaveAmount(Object amount) {
    return 'Sparen Sie $amount';
  }

  @override
  String get paywallEverythingIncluded => 'Alles inklusive:';

  @override
  String get paywallPersonalizedBudgetInsights =>
      'Wiederkehrende Budgets erstellen';

  @override
  String get paywallDailyProgressTracking => 'Erstellung mehrerer Konten';

  @override
  String get paywallExpenseManagementTools => 'Personalisierter Urlaubsmodus';

  @override
  String get paywallFinancialHealthTimeline => 'Farben und Anpassung';

  @override
  String get paywallExpertGuidanceTips => 'Benutzerdefinierte Kategorien';

  @override
  String get paywallCommunitySupportAccess => 'Zugang zum Community-Support';

  @override
  String get paywallSaveYourFinances => 'Sichern Sie Ihre Finanzen und Zukunft';

  @override
  String get paywallAverageUserSaves =>
      'Der durchschnittliche Benutzer spart ~£2.500 pro Jahr durch effektives Budgetieren';

  @override
  String get paywallSubscribeYourPlan => 'Abonnieren Sie Ihren Plan';

  @override
  String get paywallPleaseSelectPlan => 'Bitte wählen Sie einen Plan aus.';

  @override
  String get paywallSubscriptionActivated =>
      'Abonnement aktiviert! Sie haben jetzt Zugriff auf Premium-Funktionen.';

  @override
  String paywallFailedToPurchase(Object message) {
    return 'Kauf fehlgeschlagen: $message';
  }

  @override
  String paywallUnexpectedError(Object error) {
    return 'Ein unerwarteter Fehler ist aufgetreten: $error';
  }

  @override
  String get paywallRestorePurchases => 'Käufe wiederherstellen';

  @override
  String get paywallManageSubscription => 'Abonnement verwalten';

  @override
  String get paywallPurchasesRestoredSuccessfully =>
      'Käufe erfolgreich wiederhergestellt!';

  @override
  String get paywallNoActiveSubscriptionFound =>
      'Kein aktives Abonnement gefunden. Sie sind jetzt im kostenlosen Plan.';

  @override
  String get paywallPerMonth => 'pro Monat';

  @override
  String get paywallPerYear => 'pro Jahr';

  @override
  String get paywallBestValue => 'Bestes Preis-Leistungs-Verhältnis';

  @override
  String get paywallMostPopular => 'Am beliebtesten';

  @override
  String get mainScreenHome => 'Startseite';

  @override
  String get mainScreenBudget => 'Budget';

  @override
  String get mainScreenBalance => 'Kontostand';

  @override
  String get mainScreenGoals => 'Ziele';

  @override
  String get mainScreenPersonal => 'Persönlich';

  @override
  String get mainScreenIncome => 'Einnahmen';

  @override
  String get mainScreenExpense => 'Ausgaben';

  @override
  String get balanceTitle => 'Kontostand';

  @override
  String get balanceAddAccount => 'Konto hinzufügen';

  @override
  String get addAVacation => 'Einen Urlaub hinzufügen';

  @override
  String get balanceMyAccounts => 'MEINE KONTEN';

  @override
  String get balanceVacation => 'URLAUB';

  @override
  String get balanceAccountBalance => 'Kontostand';

  @override
  String get balanceNoAccountsFound => 'Keine Konten gefunden.';

  @override
  String get balanceNoAccountsCreated => 'Keine Konten erstellt';

  @override
  String get balanceCreateFirstAccount =>
      'Erstellen Sie Ihr erstes Konto, um mit der Verfolgung der Kontostände zu beginnen';

  @override
  String get balanceCreateFirstAccountFinances =>
      'Erstellen Sie Ihr erstes Konto, um mit der Verfolgung Ihrer Finanzen zu beginnen';

  @override
  String get balanceNoVacationsYet => 'Noch keine Urlaube';

  @override
  String get balanceCreateFirstVacation =>
      'Erstellen Sie Ihr erstes Urlaubskonto, um mit der Planung Ihrer Reisen zu beginnen';

  @override
  String get balanceCreateVacationAccount => 'Urlaubskonto erstellen';

  @override
  String get balanceSingleAccountView => 'Einzelkontoansicht';

  @override
  String get balanceAddMoreAccounts =>
      'Fügen Sie weitere Konten hinzu, um Diagramme zu sehen';

  @override
  String get balanceNoAccountsForCurrency =>
      'Keine Konten für die ausgewählte Währung gefunden';

  @override
  String balanceCreditLimit(Object value) {
    return 'Kreditlimit: $value';
  }

  @override
  String balanceBalanceLimit(Object value) {
    return 'Kontostandlimit: $value';
  }

  @override
  String get budgetTitle => 'Budget';

  @override
  String get budgetAddBudget => 'Budget hinzufügen';

  @override
  String get budgetDaily => 'Täglich';

  @override
  String get budgetWeekly => 'Wöchentlich';

  @override
  String get budgetMonthly => 'Monatlich';

  @override
  String get budgetSelectWeek => 'Woche auswählen';

  @override
  String get budgetSelectDate => 'Datum auswählen';

  @override
  String get budgetSelectDay => 'Tag auswählen';

  @override
  String get budgetCancel => 'Abbrechen';

  @override
  String get budgetApply => 'Übernehmen';

  @override
  String get budgetTotalSpending => 'Gesamtausgaben';

  @override
  String get budgetCategoryBreakdown => 'Kategorie-Aufschlüsselung';

  @override
  String get budgetViewAll => 'Alle ansehen';

  @override
  String get budgetBudgets => 'Budgets';

  @override
  String get budgetNoBudgetCreated => 'Kein Budget erstellt';

  @override
  String get budgetStartCreatingBudget =>
      'Beginnen Sie mit der Erstellung eines Budgets, um hier Ihre Ausgabenaufschlüsselung zu sehen.';

  @override
  String get budgetSetSpendingLimit => 'Ausgabenlimit festlegen';

  @override
  String get budgetEnterLimitAmount => 'Limitbetrag eingeben';

  @override
  String get budgetSave => 'Speichern';

  @override
  String get budgetEnterValidNumber => 'Geben Sie eine gültige Zahl ein';

  @override
  String get budgetLimitSaved => 'Budgetlimit gespeichert';

  @override
  String get budgetCreated => 'Budget erstellt';

  @override
  String get budgetTransactions => 'Transaktionen';

  @override
  String budgetOverBudget(Object amount) {
    return '$amount über Budget';
  }

  @override
  String budgetRemaining(Object amount) {
    return '$amount verbleibend';
  }

  @override
  String get homeNoMoreTransactions => 'Keine weiteren Transaktionen';

  @override
  String get homeErrorLoadingMoreTransactions =>
      'Fehler beim Laden weiterer Transaktionen';

  @override
  String get homeRetry => 'Wiederholen';

  @override
  String get homeErrorLoadingData => 'Fehler beim Laden der Daten';

  @override
  String get homeNoTransactionsRecorded => 'Keine Transaktionen aufgezeichnet';

  @override
  String get homeStartAddingTransactions =>
      'Beginnen Sie mit dem Hinzufügen von Transaktionen, um hier Ihre Ausgabenaufschlüsselung zu sehen.';

  @override
  String get homeCurrencyChange => 'Währungswechsel';

  @override
  String get homeCurrencyChangeMessage =>
      'Durch das Ändern Ihrer Währung werden alle bestehenden Beträge konvertiert. Diese Aktion kann nicht rückgängig gemacht werden. Möchten Sie fortfahren?';

  @override
  String get homeNo => 'Nein';

  @override
  String get homeYes => 'Ja';

  @override
  String get homeVacationBudgetBreakdown => 'Urlaubsbudget-Aufschlüsselung';

  @override
  String get homeBalanceBreakdown => 'Kontostands-Aufschlüsselung';

  @override
  String get homeClose => 'Schließen';

  @override
  String get transactionPickColor => 'Wählen Sie eine Farbe';

  @override
  String get transactionSelectDate => 'Datum auswählen';

  @override
  String get transactionCancel => 'Abbrechen';

  @override
  String get transactionApply => 'Übernehmen';

  @override
  String get transactionAmount => 'Betrag';

  @override
  String get transactionSelect => 'Auswählen';

  @override
  String get transactionPaid => 'Bezahlt';

  @override
  String get transactionAddTransaction => 'Transaktion hinzufügen';

  @override
  String get transactionEditTransaction => 'Transaktion bearbeiten';

  @override
  String get transactionIncome => 'Einnahmen';

  @override
  String get transactionExpense => 'Ausgaben';

  @override
  String get transactionDescription => 'Beschreibung';

  @override
  String get transactionCategory => 'Kategorie';

  @override
  String get transactionAccount => 'Konto';

  @override
  String get transactionDate => 'Datum';

  @override
  String get transactionSave => 'Speichern';

  @override
  String get transactionDelete => 'Löschen';

  @override
  String get transactionSuccess => 'Transaktion erfolgreich gespeichert';

  @override
  String get transactionError => 'Fehler beim Speichern der Transaktion';

  @override
  String get transactionDeleteConfirm =>
      'Sind Sie sicher, dass Sie diese Transaktion löschen möchten?';

  @override
  String get transactionDeleteSuccess => 'Transaktion erfolgreich gelöscht';

  @override
  String get goalsTitle => 'Ziele';

  @override
  String get goalsAddGoal => 'Ziel hinzufügen';

  @override
  String get goalsNoGoalsCreated => 'Keine Ziele erstellt';

  @override
  String get goalsStartCreatingGoal =>
      'Beginnen Sie mit der Erstellung eines Ziels, um Ihren finanziellen Fortschritt zu verfolgen';

  @override
  String get goalsCreateGoal => 'Ziel erstellen';

  @override
  String get goalsEditGoal => 'Ziel bearbeiten';

  @override
  String get goalsGoalName => 'Zielname';

  @override
  String get goalsTargetAmount => 'Zielbetrag';

  @override
  String get goalsCurrentAmount => 'Aktueller Betrag';

  @override
  String get goalsDeadline => 'Frist';

  @override
  String get goalsDescription => 'Beschreibung';

  @override
  String get goalsSave => 'Speichern';

  @override
  String get goalsCancel => 'Abbrechen';

  @override
  String get goalsDelete => 'Löschen';

  @override
  String get goalsGoalCreated => 'Ziel erfolgreich erstellt';

  @override
  String get goalsGoalUpdated => 'Ziel erfolgreich aktualisiert';

  @override
  String get goalsGoalDeleted => 'Ziel erfolgreich gelöscht';

  @override
  String get goalsErrorSaving => 'Fehler beim Speichern des Ziels';

  @override
  String get goalsDeleteConfirm =>
      'Sind Sie sicher, dass Sie dieses Ziel löschen möchten?';

  @override
  String get goalsProgress => 'Fortschritt';

  @override
  String get goalsCompleted => 'Abgeschlossen';

  @override
  String get goalsInProgress => 'In Bearbeitung';

  @override
  String get goalsNotStarted => 'Nicht begonnen';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePremiumActive => 'Premium Aktiv';

  @override
  String get profilePremiumDescription =>
      'Sie haben Zugriff auf alle Premium-Funktionen';

  @override
  String get profileFreePlan => 'Kostenloser Plan';

  @override
  String get profileUpgradeDescription =>
      'Upgrade auf Premium für erweiterte Funktionen';

  @override
  String profileRenewalDate(Object date) {
    return 'Verlängert sich am $date';
  }

  @override
  String profileExpiresOn(Object date) {
    return 'Läuft ab am $date';
  }

  @override
  String profileErrorSigningOut(Object error) {
    return 'Fehler beim Abmelden: $error';
  }

  @override
  String get profileUserNotFound => 'Benutzer nicht gefunden';

  @override
  String get profileEditDisplayName => 'Anzeigename bearbeiten';

  @override
  String get profileCancel => 'Abbrechen';

  @override
  String get profileSave => 'Speichern';

  @override
  String get profileDisplayNameUpdated =>
      'Anzeigename erfolgreich aktualisiert';

  @override
  String get profileErrorUpdatingName =>
      'Fehler beim Aktualisieren des Anzeigenamens';

  @override
  String get profileManageSubscription => 'Abonnement verwalten';

  @override
  String get profileRestorePurchases => 'Käufe wiederherstellen';

  @override
  String get profileRefreshStatus => 'Status aktualisieren';

  @override
  String get profileSubscriptionRefreshed => 'Abonnementstatus aktualisiert';

  @override
  String get profileSignOut => 'Abmelden';

  @override
  String get profileSignOutConfirm =>
      'Sind Sie sicher, dass Sie sich abmelden möchten?';

  @override
  String get profileCurrencyRates => 'Währungskurse';

  @override
  String get profileCategories => 'Kategorien';

  @override
  String get profileFeedback => 'Feedback';

  @override
  String get profileExportData => 'Daten exportieren';

  @override
  String get profileSettings => 'Einstellungen';

  @override
  String get profileAccount => 'Konto';

  @override
  String get profileDisplayName => 'Anzeigename';

  @override
  String get profileEmail => 'E-Mail';

  @override
  String get profileSubscription => 'Abonnement';

  @override
  String get profileVersion => 'Version';

  @override
  String get personalTitle => 'Persönlich';

  @override
  String get personalSubscriptions => 'Abonnements';

  @override
  String get personalBorrowed => 'Geliehen';

  @override
  String get personalAddSubscription => 'Abonnement hinzufügen';

  @override
  String get personalAddLent => 'Verliehenes hinzufügen';

  @override
  String get personalAddBorrowed => 'Geliehenes hinzufügen';

  @override
  String get personalNoSubscriptions => 'Keine Abonnements gefunden';

  @override
  String get personalNoLent => 'Keine verliehenen Gegenstände gefunden';

  @override
  String get personalNoBorrowed => 'Keine geliehenen Gegenstände gefunden';

  @override
  String get personalStartAddingSubscription =>
      'Beginnen Sie mit dem Hinzufügen eines Abonnements, um Ihre wiederkehrenden Zahlungen zu verfolgen';

  @override
  String get personalStartAddingLent =>
      'Beginnen Sie mit dem Hinzufügen verliehener Gegenstände, um das verliehene Geld zu verfolgen';

  @override
  String get personalStartAddingBorrowed =>
      'Beginnen Sie mit dem Hinzufügen geliehener Gegenstände, um das geliehene Geld zu verfolgen';

  @override
  String get personalEdit => 'Bearbeiten';

  @override
  String get personalDelete => 'Löschen';

  @override
  String get personalMarkAsPaid => 'Als bezahlt markieren';

  @override
  String get personalMarkAsUnpaid => 'Als unbezahlt markieren';

  @override
  String get personalAmount => 'Betrag';

  @override
  String get personalDescription => 'Beschreibung';

  @override
  String get personalDueDate => 'Fälligkeitsdatum';

  @override
  String get personalRecurring => 'Wiederkehrend';

  @override
  String get personalOneTime => 'Einmalig';

  @override
  String get personalMonthly => 'Monatlich';

  @override
  String get personalYearly => 'Jährlich';

  @override
  String get personalWeekly => 'Wöchentlich';

  @override
  String get personalDaily => 'Täglich';

  @override
  String get personalName => 'Name';

  @override
  String get personalCategory => 'Kategorie';

  @override
  String get personalNotes => 'Notizen';

  @override
  String get personalSave => 'Speichern';

  @override
  String get personalCancel => 'Abbrechen';

  @override
  String get personalDeleteConfirm =>
      'Sind Sie sicher, dass Sie diesen Gegenstand löschen möchten?';

  @override
  String get personalItemSaved => 'Gegenstand erfolgreich gespeichert';

  @override
  String get personalItemDeleted => 'Gegenstand erfolgreich gelöscht';

  @override
  String get personalErrorSaving => 'Fehler beim Speichern des Gegenstands';

  @override
  String get personalErrorDeleting => 'Fehler beim Löschen des Gegenstands';

  @override
  String get analyticsTitle => 'Analytik';

  @override
  String get analyticsOverview => 'Übersicht';

  @override
  String get analyticsIncome => 'Einnahmen';

  @override
  String get analyticsExpenses => 'Ausgaben';

  @override
  String get analyticsSavings => 'Ersparnisse';

  @override
  String get analyticsCategories => 'Kategorien';

  @override
  String get analyticsTrends => 'Trends';

  @override
  String get analyticsMonthly => 'Monatlich';

  @override
  String get analyticsWeekly => 'Wöchentlich';

  @override
  String get analyticsDaily => 'Täglich';

  @override
  String get analyticsYearly => 'Jährlich';

  @override
  String get analyticsNoData => 'Keine Daten verfügbar';

  @override
  String get analyticsStartTracking =>
      'Beginnen Sie mit der Verfolgung Ihrer Finanzen, um hier Analysen zu sehen';

  @override
  String get analyticsTotalIncome => 'Gesamteinnahmen';

  @override
  String get analyticsTotalExpenses => 'Gesamtausgaben';

  @override
  String get analyticsNetSavings => 'Nettoersparnisse';

  @override
  String get analyticsTopCategories => 'Top-Kategorien';

  @override
  String get analyticsSpendingTrends => 'Ausgabentrends';

  @override
  String get analyticsIncomeTrends => 'Einnahmentrends';

  @override
  String get analyticsSavingsRate => 'Sparquote';

  @override
  String get analyticsAverageDaily => 'Durchschnittlich Täglich';

  @override
  String get analyticsAverageWeekly => 'Durchschnittlich Wöchentlich';

  @override
  String get analyticsAverageMonthly => 'Durchschnittlich Monatlich';

  @override
  String get analyticsSelectPeriod => 'Zeitraum auswählen';

  @override
  String get analyticsExportData => 'Daten exportieren';

  @override
  String get analyticsRefresh => 'Aktualisieren';

  @override
  String get analyticsErrorLoading => 'Fehler beim Laden der Analysedaten';

  @override
  String get analyticsRetry => 'Wiederholen';

  @override
  String get goalsSelectColor => 'Farbe auswählen';

  @override
  String get goalsMore => 'Mehr';

  @override
  String get goalsName => 'Zielname';

  @override
  String get goalsColor => 'Farbe';

  @override
  String get goalsNameRequired => 'Zielname ist erforderlich';

  @override
  String get goalsAmountRequired => 'Zielbetrag ist erforderlich';

  @override
  String get goalsAmountMustBePositive => 'Zielbetrag muss größer als 0 sein';

  @override
  String get goalsDeadlineRequired => 'Frist ist erforderlich';

  @override
  String get goalsDeadlineMustBeFuture => 'Frist muss in der Zukunft liegen';

  @override
  String get goalsNameAlreadyExists =>
      'Ein Ziel mit diesem Namen existiert bereits';

  @override
  String goalsErrorCreating(Object error) {
    return 'Fehler beim Erstellen des Ziels: $error';
  }

  @override
  String goalsErrorUpdating(Object error) {
    return 'Fehler beim Aktualisieren des Ziels: $error';
  }

  @override
  String goalsErrorDeleting(Object error) {
    return 'Fehler beim Löschen des Ziels: $error';
  }

  @override
  String get expenseDetailTitle => 'Ausgabendetail';

  @override
  String get expenseDetailEdit => 'Bearbeiten';

  @override
  String get expenseDetailDelete => 'Löschen';

  @override
  String get expenseDetailAmount => 'Betrag';

  @override
  String get expenseDetailCategory => 'Kategorie';

  @override
  String get expenseDetailAccount => 'Konto';

  @override
  String get expenseDetailDate => 'Datum';

  @override
  String get expenseDetailDescription => 'Beschreibung';

  @override
  String get expenseDetailNotes => 'Notizen';

  @override
  String get expenseDetailSave => 'Speichern';

  @override
  String get expenseDetailCancel => 'Abbrechen';

  @override
  String get expenseDetailDeleteConfirm =>
      'Sind Sie sicher, dass Sie diese Ausgabe löschen möchten?';

  @override
  String get expenseDetailUpdated => 'Ausgabe erfolgreich aktualisiert';

  @override
  String get expenseDetailDeleted => 'Ausgabe erfolgreich gelöscht';

  @override
  String get expenseDetailErrorSaving => 'Fehler beim Speichern der Ausgabe';

  @override
  String get expenseDetailErrorDeleting => 'Fehler beim Löschen der Ausgabe';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get calendarSelectDate => 'Datum auswählen';

  @override
  String get calendarToday => 'Heute';

  @override
  String get calendarThisWeek => 'Diese Woche';

  @override
  String get calendarThisMonth => 'Diesen Monat';

  @override
  String get calendarThisYear => 'Dieses Jahr';

  @override
  String get calendarNoTransactions => 'Keine Transaktionen an diesem Datum';

  @override
  String get calendarStartAddingTransactions =>
      'Beginnen Sie mit dem Hinzufügen von Transaktionen, um sie im Kalender zu sehen';

  @override
  String get vacationDialogTitle => 'Urlaubsmodus';

  @override
  String get vacationDialogEnable => 'Urlaubsmodus aktivieren';

  @override
  String get vacationDialogDisable => 'Urlaubsmodus deaktivieren';

  @override
  String get vacationDialogDescription =>
      'Der Urlaubsmodus hilft Ihnen, Ausgaben während Reisen und Feiertagen zu verfolgen';

  @override
  String get vacationDialogCancel => 'Abbrechen';

  @override
  String get vacationDialogConfirm => 'Bestätigen';

  @override
  String get vacationDialogEnabled => 'Urlaubsmodus aktiviert';

  @override
  String get vacationDialogDisabled => 'Urlaubsmodus deaktiviert';

  @override
  String get balanceDetailTitle => 'Kontodetail';

  @override
  String get balanceDetailEdit => 'Bearbeiten';

  @override
  String get balanceDetailDelete => 'Löschen';

  @override
  String get balanceDetailTransactions => 'Transaktionen';

  @override
  String get balanceDetailBalance => 'Kontostand';

  @override
  String get balanceDetailCreditLimit => 'Kreditlimit';

  @override
  String get balanceDetailBalanceLimit => 'Kontostandlimit';

  @override
  String get balanceDetailCurrency => 'Währung';

  @override
  String get balanceDetailAccountType => 'Kontotyp';

  @override
  String get balanceDetailAccountName => 'Kontoname';

  @override
  String get balanceDetailSave => 'Speichern';

  @override
  String get balanceDetailCancel => 'Abbrechen';

  @override
  String get balanceDetailDeleteConfirm =>
      'Sind Sie sicher, dass Sie dieses Konto löschen möchten?';

  @override
  String get balanceDetailUpdated => 'Konto erfolgreich aktualisiert';

  @override
  String get balanceDetailDeleted => 'Konto erfolgreich gelöscht';

  @override
  String get balanceDetailErrorSaving => 'Fehler beim Speichern des Kontos';

  @override
  String get balanceDetailErrorDeleting => 'Fehler beim Löschen des Kontos';

  @override
  String get addAccountTitle => 'Konto hinzufügen';

  @override
  String get addAccountEditTitle => 'Konto bearbeiten';

  @override
  String get addAccountName => 'Kontoname';

  @override
  String get addAccountType => 'Kontotyp';

  @override
  String get addAccountCurrency => 'Währung';

  @override
  String get addAccountInitialBalance => 'Anfangsbestand';

  @override
  String get addAccountCreditLimit => 'Kreditlimit';

  @override
  String get addAccountBalanceLimit => 'Kontostandlimit';

  @override
  String get addAccountColor => 'Farbe';

  @override
  String get addAccountIcon => 'Symbol';

  @override
  String get addAccountSave => 'Speichern';

  @override
  String get addAccountCancel => 'Abbrechen';

  @override
  String get addAccountCreated => 'Konto erfolgreich erstellt';

  @override
  String get addAccountUpdated => 'Konto erfolgreich aktualisiert';

  @override
  String get addAccountErrorSaving => 'Fehler beim Speichern des Kontos';

  @override
  String get addAccountNameRequired => 'Kontoname ist erforderlich';

  @override
  String get addAccountTypeRequired => 'Kontotyp ist erforderlich';

  @override
  String get addAccountCurrencyRequired => 'Währung ist erforderlich';

  @override
  String get budgetDetailTitle => 'Budgetdetail';

  @override
  String get budgetDetailEdit => 'Bearbeiten';

  @override
  String get budgetDetailDelete => 'Löschen';

  @override
  String get budgetDetailSpending => 'Ausgaben';

  @override
  String get budgetDetailLimit => 'Limit';

  @override
  String get budgetDetailRemaining => 'Verbleibend';

  @override
  String get budgetDetailOverBudget => 'Über Budget';

  @override
  String get budgetDetailCategories => 'Kategorien';

  @override
  String get budgetDetailTransactions => 'Transaktionen';

  @override
  String get budgetDetailSave => 'Speichern';

  @override
  String get budgetDetailCancel => 'Abbrechen';

  @override
  String get budgetDetailDeleteConfirm =>
      'Sind Sie sicher, dass Sie dieses Budget löschen möchten?';

  @override
  String get budgetDetailUpdated => 'Budget erfolgreich aktualisiert';

  @override
  String get budgetDetailDeleted => 'Budget erfolgreich gelöscht';

  @override
  String get budgetDetailErrorSaving => 'Fehler beim Speichern des Budgets';

  @override
  String get budgetDetailErrorDeleting => 'Fehler beim Löschen des Budgets';

  @override
  String get addBudgetTitle => 'Budget hinzufügen';

  @override
  String get addBudgetEditTitle => 'Budget bearbeiten';

  @override
  String get addBudgetName => 'Budgetname';

  @override
  String get addBudgetType => 'Budgettyp';

  @override
  String get addBudgetAmount => 'Betrag';

  @override
  String get addBudgetCurrency => 'Währung';

  @override
  String get addBudgetPeriod => 'Zeitraum';

  @override
  String get addBudgetCategories => 'Kategorien';

  @override
  String get addBudgetColor => 'Farbe';

  @override
  String get addBudgetSave => 'Speichern';

  @override
  String get addBudgetSaveBudget => 'Budget speichern';

  @override
  String get addBudgetCancel => 'Abbrechen';

  @override
  String get addBudgetCreated => 'Budget erfolgreich erstellt';

  @override
  String get addBudgetUpdated => 'Budget erfolgreich aktualisiert';

  @override
  String get addBudgetErrorSaving => 'Fehler beim Speichern des Budgets';

  @override
  String get addBudgetNameRequired => 'Budgetname ist erforderlich';

  @override
  String get addBudgetAmountRequired => 'Budgetbetrag ist erforderlich';

  @override
  String get addBudgetAmountMustBePositive =>
      'Budgetbetrag muss größer als 0 sein';

  @override
  String get addBudgetCategoryRequired => 'Bitte wählen Sie eine Kategorie aus';

  @override
  String get budgetDetailNoBudgetToDelete =>
      'Kein Budget zum Löschen. Dies ist nur ein Platzhalter für Transaktionen.';

  @override
  String get personalItemDetails => 'Artikeldetails';

  @override
  String get personalStartDateRequired => 'Bitte wählen Sie ein Startdatum aus';

  @override
  String get profileMainCurrency => 'HAUPTWÄHRUNG';

  @override
  String get profileFeedbackThankYou => 'Vielen Dank für Ihr Feedback!';

  @override
  String get profileFeedbackEmailError =>
      'E-Mail-Client konnte nicht geöffnet werden.';

  @override
  String get feedbackModalTitle => 'Gefällt Ihnen die App?';

  @override
  String get feedbackModalDescription =>
      'Ihr Feedback motiviert uns und hilft uns, uns zu verbessern.';

  @override
  String get goalNameAlreadyExistsSnackbar =>
      'Ein Ziel mit diesem Namen existiert bereits';

  @override
  String get lentSelectBothDates =>
      'Bitte wählen Sie sowohl Datum als auch Fälligkeitsdatum aus';

  @override
  String get lentDueDateBeforeLentDate =>
      'Das Fälligkeitsdatum darf nicht vor dem Verleihdatum liegen';

  @override
  String get lentItemAddedSuccessfully =>
      'Verliehener Gegenstand erfolgreich hinzugefügt';

  @override
  String lentItemError(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get borrowedSelectBothDates =>
      'Bitte wählen Sie sowohl Datum als auch Fälligkeitsdatum aus';

  @override
  String get borrowedDueDateBeforeBorrowedDate =>
      'Das Fälligkeitsdatum darf nicht vor dem Leihdatum liegen';

  @override
  String get borrowedItemAddedSuccessfully =>
      'Geliehener Gegenstand erfolgreich hinzugefügt';

  @override
  String borrowedItemError(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get subscriptionCreatedSuccessfully =>
      'Abonnement erfolgreich erstellt';

  @override
  String subscriptionError(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get paymentMarkedSuccessfully => 'Zahlung erfolgreich markiert';

  @override
  String get subscriptionContinued => 'Abonnement erfolgreich fortgesetzt';

  @override
  String get subscriptionPaused => 'Abonnement erfolgreich pausiert';

  @override
  String get itemMarkedAsReturnedSuccessfully =>
      'Gegenstand erfolgreich als zurückgegeben markiert';

  @override
  String get itemDeletedSuccessfully => 'Gegenstand erfolgreich gelöscht';

  @override
  String get failedToDeleteBudget => 'Fehler beim Löschen des Budgets';

  @override
  String get failedToDeleteGoal => 'Fehler beim Löschen des Ziels';

  @override
  String failedToSaveTransaction(Object error) {
    return 'Fehler beim Speichern der Transaktion: $error';
  }

  @override
  String get failedToReorderCategories =>
      'Fehler beim Neuanordnen der Kategorien. Änderungen werden rückgängig gemacht.';

  @override
  String get categoryAddedSuccessfully => 'Kategorie erfolgreich hinzugefügt';

  @override
  String failedToAddCategory(Object error) {
    return 'Fehler beim Hinzufügen der Kategorie: $error';
  }

  @override
  String get addCategory => 'Kategorie hinzufügen';

  @override
  String errorCreatingGoal(Object error) {
    return 'Fehler beim Erstellen des Ziels: $error';
  }

  @override
  String get hintName => 'Name';

  @override
  String get hintDescription => 'Beschreibung';

  @override
  String get hintSelectDate => 'Datum auswählen';

  @override
  String get hintSelectDueDate => 'Fälligkeitsdatum auswählen';

  @override
  String get hintSelectCategory => 'Kategorie auswählen';

  @override
  String get hintSelectAccount => 'Konto auswählen';

  @override
  String get hintSelectGoal => 'Ziel auswählen';

  @override
  String get hintNotes => 'Notizen';

  @override
  String get hintSelectColor => 'Farbe auswählen';

  @override
  String get hintEnterCategoryName => 'Kategorienamen eingeben';

  @override
  String get hintSelectType => 'Typ auswählen';

  @override
  String get hintWriteThoughts => 'Schreiben Sie hier Ihre Gedanken auf......';

  @override
  String get hintEnterDisplayName => 'Anzeigenamen eingeben';

  @override
  String get hintSelectBudgetType => 'Budgettyp auswählen';

  @override
  String get hintSelectAccountType => 'Kontotyp auswählen';

  @override
  String get hintEnterName => 'Namen eingeben';

  @override
  String get hintSelectIcon => 'Symbol auswählen';

  @override
  String get hintSelect => 'Auswählen';

  @override
  String get hintAmountPlaceholder => '0,00';

  @override
  String get labelValue => 'Wert';

  @override
  String get labelName => 'Name';

  @override
  String get labelDescription => 'Beschreibung';

  @override
  String get labelCategory => 'Kategorie';

  @override
  String get labelDate => 'Datum';

  @override
  String get labelDueDate => 'Fälligkeitsdatum';

  @override
  String get labelColor => 'Farbe';

  @override
  String get labelNotes => 'Notizen';

  @override
  String get labelAccount => 'Konto';

  @override
  String get labelMore => 'Mehr';

  @override
  String get labelHome => 'Startseite';

  @override
  String get titlePickColor => 'Farbe auswählen';

  @override
  String get titleAddLentItem => 'Verliehenen Gegenstand hinzufügen';

  @override
  String get titleAddBorrowedItem => 'Geliehenen Gegenstand hinzufügen';

  @override
  String get titleSelectCategory => 'Kategorie auswählen';

  @override
  String get titleSelectAccount => 'Konto auswählen';

  @override
  String get titleSelectGoal => 'Ziel auswählen';

  @override
  String get titleSelectType => 'Typ auswählen';

  @override
  String get titleSelectAccountType => 'Kontotyp auswählen';

  @override
  String get titleSelectBudgetType => 'Budgettyp auswählen';

  @override
  String get validationNameRequired => 'Name ist erforderlich';

  @override
  String get validationAmountRequired => 'Betrag ist erforderlich';

  @override
  String get validationPleaseEnterValidNumber =>
      'Bitte geben Sie eine gültige Zahl ein';

  @override
  String get validationPleaseSelectIcon => 'Bitte wählen Sie ein Symbol aus';

  @override
  String get buttonCancel => 'Abbrechen';

  @override
  String get buttonAdd => 'Hinzufügen';

  @override
  String get buttonSave => 'Speichern';

  @override
  String get switchAddProgress => 'Fortschritt hinzufügen';

  @override
  String get pickColor => 'Farbe auswählen';

  @override
  String get name => 'Name';

  @override
  String get itemName => 'Artikelname';

  @override
  String get account => 'Konto';

  @override
  String get selectIcon => 'Bitte wählen Sie ein Symbol aus';

  @override
  String get value => 'Wert';

  @override
  String get hintAmount => '0,00';

  @override
  String get hintItemName => 'Artikelname';

  @override
  String get amountRequired => 'Betrag ist erforderlich';

  @override
  String get validNumber => 'Bitte geben Sie eine gültige Zahl ein';

  @override
  String get category => 'Kategorie';

  @override
  String get date => 'Datum';

  @override
  String get dueDate => 'Fälligkeitsdatum';

  @override
  String get color => 'Farbe';

  @override
  String get notes => 'Notizen';

  @override
  String get selectColor => 'Farbe auswählen';

  @override
  String get more => 'Mehr';

  @override
  String get addLentItem => 'Verliehenen Gegenstand hinzufügen';

  @override
  String get addBorrowedItem => 'Geliehenen Gegenstand hinzufügen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get nameRequired => 'Name ist erforderlich';

  @override
  String get buttonOk => 'OK';

  @override
  String get vacationNoAccountsAvailable => 'Keine Urlaubskonten verfügbar.';

  @override
  String get exportFormat => 'Format';

  @override
  String get exportOptions => 'Optionen';

  @override
  String get exportAccountData => 'Kontodaten exportieren';

  @override
  String get exportGoalsData => 'Zieldaten exportieren';

  @override
  String get exportCurrentMonth => 'Aktueller Monat';

  @override
  String get exportLast30Days => 'Letzte 30 Tage';

  @override
  String get exportLast90Days => 'Letzte 90 Tage';

  @override
  String get exportLast365Days => 'Letzte 365 Tage';

  @override
  String get exportCsv => 'CSV';

  @override
  String get exportJson => 'JSON';

  @override
  String get exportImportInstructions =>
      'Sie können Ihre Daten aus einer CSV-Datei in die App importieren.';

  @override
  String get exportInstructions1 =>
      'Speichern Sie die Beispieldatei, um das erforderliche Datenformat anzuzeigen;';

  @override
  String get exportInstructions2 =>
      'Formatieren Sie Ihre Daten entsprechend der Vorlage. Stellen Sie sicher, dass die Spalten, ihre Reihenfolge und Namen genau mit denen in der Vorlage übereinstimmen. Die Namen der Spalten sollten in englischer Sprache sein;';

  @override
  String get exportInstructions3 =>
      'Drücken Sie Importieren und wählen Sie Ihre Datei aus;';

  @override
  String get exportInstructions4 =>
      'Wählen Sie, ob Sie bestehende Daten überschreiben oder importierte Daten zu den bestehenden Daten hinzufügen möchten. Bei Auswahl der Überschreibungsoption werden bestehende Daten dauerhaft gelöscht;';

  @override
  String get exportButtonExport => 'Exportieren';

  @override
  String get exportButtonImport => 'Importieren';

  @override
  String get exportTabExport => 'Export';

  @override
  String get exportTabImport => 'Import';

  @override
  String get enableVacationMode => 'Urlaubsmodus aktivieren';

  @override
  String get addProgress => 'Fortschritt hinzufügen';

  @override
  String get pleaseEnterValidNumber => 'Bitte geben Sie eine gültige Zahl ein';

  @override
  String get pleaseSelectCategory => 'Bitte wählen Sie eine Kategorie aus';

  @override
  String get pleaseSelectCurrency => 'Bitte wählen Sie eine Währung aus';

  @override
  String get pleaseSelectAccount => 'Bitte wählen Sie ein Konto aus';

  @override
  String get pleaseSelectDate => 'Bitte wählen Sie ein Datum aus';

  @override
  String get pleaseSelectIcon => 'Bitte wählen Sie ein Symbol aus';

  @override
  String get deleteCategory => 'Kategorie löschen';

  @override
  String get markAsReturned => 'Als zurückgegeben markieren';

  @override
  String get markPayment => 'Zahlung markieren';

  @override
  String get markPaid => 'Als bezahlt markieren';

  @override
  String get deleteItem => 'Gegenstand löschen';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get deleteAllAssociatedTransactions =>
      'Alle zugehörigen Transaktionen löschen';

  @override
  String get normalMode => 'Normaler Modus';

  @override
  String normalModeWithCurrency(String currency) {
    return 'Sie befinden sich jetzt im Normalen Modus mit Währung: $currency';
  }

  @override
  String get changeCurrency => 'Währung ändern';

  @override
  String get vacationModeDialog => 'Urlaubsmodus-Dialog';

  @override
  String get categoryAndTransactionsDeleted =>
      'Kategorie und zugehörige Transaktionen erfolgreich gelöscht';

  @override
  String get select => 'Auswählen';

  @override
  String get delete => 'Löschen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get yourData => 'Ihre Daten';

  @override
  String get profileMenuAccount => 'KONTO';

  @override
  String get profileMenuCurrency => 'Währung';

  @override
  String get profileSectionLegal => 'RECHTLICHES';

  @override
  String get profileTermsConditions => 'Allgemeine Geschäftsbedingungen';

  @override
  String get profilePrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get profileSectionSupport => 'SUPPORT';

  @override
  String get profileHelpSupport => 'Hilfe & Support';

  @override
  String get profileSectionDanger => 'GEFAHRENZONE';

  @override
  String get currencyPageChange => 'ÄNDERN';

  @override
  String get addTransactionNotes => 'Notizen';

  @override
  String get addTransactionMore => 'Mehr';

  @override
  String get addTransactionDate => 'Datum';

  @override
  String get addTransactionTime => 'Zeit';

  @override
  String get addTransactionPaid => 'Bezahlt';

  @override
  String get addTransactionColor => 'Farbe';

  @override
  String get addTransactionCancel => 'Abbrechen';

  @override
  String get addTransactionCreate => 'Erstellen';

  @override
  String get addTransactionUpdate => 'Aktualisieren';

  @override
  String get addBudgetLimitAmount => 'Limitbetrag';

  @override
  String get addBudgetSelectCategory => 'Kategorie auswählen';

  @override
  String get addBudgetBudgetType => 'Budgettyp';

  @override
  String get addBudgetRecurring => 'Wiederkehrendes Budget';

  @override
  String get addBudgetRecurringSubtitle =>
      'Dieses Budget für jeden Zeitraum automatisch erneuern';

  @override
  String get addBudgetRecurringDailySubtitle => 'Gilt für jeden Tag';

  @override
  String get addBudgetRecurringPremiumSubtitle =>
      'Premium-Funktion - Abonnieren Sie, um sie zu aktivieren';

  @override
  String get addBudget => 'Budget hinzufügen';

  @override
  String get addAccountTransactionLimit => 'Transaktionslimit';

  @override
  String get addAccountAccountType => 'Kontotyp';

  @override
  String get addAccountAdd => 'Hinzufügen';

  @override
  String get addAccountBalance => 'Kontostand';

  @override
  String get addAccountCredit => 'Kredit';

  @override
  String get homeIncomeCard => 'Einnahmen';

  @override
  String get homeExpenseCard => 'Ausgaben';

  @override
  String get homeTotalBudget => 'Gesamtbudget';

  @override
  String get balanceDetailInitialBalance => 'Anfangsbestand';

  @override
  String get balanceDetailCurrentBalance => 'Aktueller Kontostand';

  @override
  String get expenseDetailTotal => 'Gesamt';

  @override
  String get expenseDetailAccumulatedAmount => 'Kumulierter Betrag';

  @override
  String get expenseDetailPaidStatus => 'BEZAHLT/UNBEZAHLT';

  @override
  String get expenseDetailVacation => 'Urlaub';

  @override
  String get expenseDetailMarkPaid => 'Als bezahlt markieren';

  @override
  String get expenseDetailMarkUnpaid => 'Als unbezahlt markieren';

  @override
  String get goalsScreenPending => 'Ausstehende Ziele';

  @override
  String get goalsScreenFulfilled => 'Erfüllte Ziele';

  @override
  String get createGoalTitle => 'Ein ausstehendes Ziel erstellen';

  @override
  String get createGoalAmount => 'Betrag';

  @override
  String get createGoalName => 'Name';

  @override
  String get createGoalCurrency => 'Währung';

  @override
  String get createGoalMore => 'Mehr';

  @override
  String get createGoalNotes => 'Notizen';

  @override
  String get createGoalDate => 'Datum';

  @override
  String get createGoalColor => 'Farbe';

  @override
  String get createGoalLimitReached =>
      'Sie haben das Ziellimit erreicht. Upgraden Sie auf Premium, um unbegrenzt Ziele zu erstellen.';

  @override
  String get personalScreenSubscriptions => 'Abonnements';

  @override
  String get personalScreenBorrowed => 'Geliehen';

  @override
  String get personalScreenLent => 'Verliehen';

  @override
  String get personalScreenTotal => 'Gesamt';

  @override
  String get personalScreenActive => 'Aktiv';

  @override
  String get personalScreenNoSubscriptions => 'Noch keine Abonnements';

  @override
  String get personalScreenNoBorrowed => 'Noch keine geliehenen Gegenstände';

  @override
  String get personalScreenBorrowedItems => 'Geliehene Gegenstände';

  @override
  String get personalScreenLentItems => 'Verliehene Gegenstände';

  @override
  String get personalScreenNoLent => 'Noch keine verliehenen Gegenstände';

  @override
  String get addBorrowedTitle => 'Geliehenen Gegenstand hinzufügen';

  @override
  String get addLentTitle => 'Verliehenen Gegenstand hinzufügen';

  @override
  String get addBorrowedName => 'Name';

  @override
  String get addBorrowedAmount => 'Betrag';

  @override
  String get addBorrowedNotes => 'Notizen';

  @override
  String get addBorrowedMore => 'Mehr';

  @override
  String get addBorrowedDate => 'Datum';

  @override
  String get addBorrowedDueDate => 'Fälligkeitsdatum';

  @override
  String get addBorrowedReturned => 'Zurückgegeben';

  @override
  String get addBorrowedMarkReturned => 'Als zurückgegeben markieren';

  @override
  String get addSubscriptionPrice => 'Preis';

  @override
  String get addSubscriptionName => 'Name';

  @override
  String get addSubscriptionRecurrence => 'Wiederholung';

  @override
  String get addSubscriptionMore => 'Mehr';

  @override
  String get addSubscriptionNotes => 'Notizen';

  @override
  String get addSubscriptionStartDate => 'Startdatum';

  @override
  String get addLentName => 'Name';

  @override
  String get addLentAmount => 'Betrag';

  @override
  String get addLentNotes => 'Notizen';

  @override
  String get addLentMore => 'Mehr';

  @override
  String get addLentDate => 'Datum';

  @override
  String get addLentDueDate => 'Fälligkeitsdatum';

  @override
  String get addLentReturned => 'Zurückgegeben';

  @override
  String get addLentMarkReturned => 'Als zurückgegeben markieren';

  @override
  String get currencyPageTitle => 'Währungskurse';

  @override
  String get profileVacationMode => 'Urlaubsmodus';

  @override
  String get profileCurrency => 'Währung';

  @override
  String get profileLegal => 'RECHTLICHES';

  @override
  String get profileSupport => 'SUPPORT';

  @override
  String get profileDangerZone => 'GEFAHRENZONE';

  @override
  String get profileLogout => 'Abmelden';

  @override
  String get profileDeleteAccount => 'Konto löschen';

  @override
  String get profileDeleteAccountTitle => 'Konto löschen';

  @override
  String get profileDeleteAccountMessage =>
      'Sind Sie sicher, dass Sie Ihr Konto löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden. Alle Ihre Daten, einschließlich Konten, Transaktionen, Budgets und Ziele, werden dauerhaft gelöscht.';

  @override
  String get profileDeleteAccountConfirm => 'Löschen';

  @override
  String get profileDeleteAccountSuccess => 'Konto erfolgreich gelöscht';

  @override
  String profileDeleteAccountError(String error) {
    return 'Fehler beim Löschen des Kontos: $error';
  }

  @override
  String get homeIncome => 'Einnahmen';

  @override
  String get homeExpense => 'Ausgaben';

  @override
  String get expenseDetailPaidUnpaid => 'BEZAHLT/UNBEZAHLT';

  @override
  String get goalsScreenPendingGoals => 'Ausstehende Ziele';

  @override
  String get goalsScreenFulfilledGoals => 'Erfüllte Ziele';

  @override
  String get transactionEditIncome => 'Einnahmen bearbeiten';

  @override
  String get transactionEditExpense => 'Ausgaben bearbeiten';

  @override
  String get transactionPlanIncome => 'Einnahmen planen';

  @override
  String get transactionPlanExpense => 'Ausgaben planen';

  @override
  String get goal => 'Ziel';

  @override
  String get none => 'Keine';

  @override
  String get unnamedCategory => 'Unbenannte Kategorie';

  @override
  String get month => 'Monat';

  @override
  String get daily => 'Täglich';

  @override
  String get weekly => 'Wöchentlich';

  @override
  String get monthly => 'Monatlich';

  @override
  String get profileLanguage => 'Sprache';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String get languageArabic => 'Arabisch';

  @override
  String get languageSelectLanguage => 'Sprache auswählen';

  @override
  String get vacationCurrencyDialogTitle => 'Urlaubswährung';

  @override
  String vacationCurrencyDialogMessage(Object previousCurrency) {
    return 'Sie können die Währungen für Ihre Urlaubstransaktionen ändern. Möchten Sie die Währung jetzt ändern?\n\nIhre vorherige Währung war $previousCurrency.';
  }

  @override
  String vacationCurrencyDialogKeepCurrent(Object previousCurrency) {
    return 'Aktuelle beibehalten ($previousCurrency)';
  }

  @override
  String get includeVacationTransaction => 'Urlaubstransaktionen einschließen';

  @override
  String get showVacationTransactions =>
      'Urlaubstransaktionen im normalen Modus anzeigen';

  @override
  String get balanceDetailTransactionsWillAppear =>
      'Transaktionen für dieses Konto werden hier angezeigt';

  @override
  String get personalNextBilling => 'Nächste Abrechnung';

  @override
  String get personalActive => 'Aktiv';

  @override
  String get personalInactive => 'Inaktiv';

  @override
  String get personalReturned => 'Zurückgegeben';

  @override
  String get personalLent => 'Verliehen';

  @override
  String get personalDue => 'Fällig';

  @override
  String get personalItems => 'Gegenstand/Gegenstände';

  @override
  String get status => 'Status';

  @override
  String get notReturned => 'Nicht zurückgegeben';

  @override
  String get borrowedOn => 'Geliehen am';

  @override
  String get lentOn => 'Verliehen am';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Fortsetzen';

  @override
  String get upcomingBills => 'Anstehende Rechnungen';

  @override
  String get upcomingCharge => 'Anstehende Belastung';

  @override
  String get pastHistory => 'Vergangene Historie';

  @override
  String get noHistoryYet => 'Noch keine Historie';

  @override
  String get budgetShowcaseAddBudget => 'Add Budget';

  @override
  String get budgetShowcaseAddBudgetDesc =>
      'Tap here to create a new budget and set spending limits for your categories.';

  @override
  String get budgetShowcaseTypeSelector => 'Budget Type';

  @override
  String get budgetShowcaseTypeSelectorDesc =>
      'Switch between Daily, Weekly, and Monthly budgets to track your spending over different time periods.';

  @override
  String get budgetShowcasePeriodSelector => 'Period Selector';

  @override
  String get budgetShowcasePeriodSelectorDesc =>
      'Navigate between different time periods to view your budget history.';

  @override
  String get budgetShowcasePieChart => 'Spending Overview';

  @override
  String get budgetShowcasePieChartDesc =>
      'View your spending breakdown by category in this visual chart.';

  @override
  String get budgetShowcaseCategoryList => 'Budget Categories';

  @override
  String get budgetShowcaseCategoryListDesc =>
      'See all your budgets organized by category. Tap any budget to view details and edit limits.';

  @override
  String get balanceShowcaseAddAccount => 'Add Account';

  @override
  String get balanceShowcaseAddAccountDesc =>
      'Tap here to create a new account and start tracking your balances.';

  @override
  String get balanceShowcasePieChart => 'Account Balance';

  @override
  String get balanceShowcasePieChartDesc =>
      'Visual overview of your account balances across different currencies.';

  @override
  String get balanceShowcaseAccountCard => 'Account Cards';

  @override
  String get balanceShowcaseAccountCardDesc =>
      'View and manage all your accounts. Tap any account to see detailed transactions.';

  @override
  String get goalsShowcaseAddGoal => 'Add Goal';

  @override
  String get goalsShowcaseAddGoalDesc =>
      'Tap here to create a new financial goal and track your progress.';

  @override
  String get goalsShowcaseToggle => 'Goal Filter';

  @override
  String get goalsShowcaseToggleDesc =>
      'Switch between Pending and Fulfilled goals to see your progress.';

  @override
  String get goalsShowcaseGoalItem => 'Goal Cards';

  @override
  String get goalsShowcaseGoalItemDesc =>
      'View all your goals with progress tracking. Tap any goal to see details and add progress.';
}
