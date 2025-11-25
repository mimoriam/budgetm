// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginSubtitle =>
      'Entrez votre e-mail et votre mot de passe pour vous connecter';

  @override
  String get emailHint => 'E-mail';

  @override
  String get passwordHint => 'Mot de passe';

  @override
  String get rememberMe => 'Se souvenir de moi';

  @override
  String get forgotPassword => 'Mot de passe oublié?';

  @override
  String get loginButton => 'Connexion';

  @override
  String get orLoginWith => 'Ou se connecter avec';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte?';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get forgotPasswordSubtitle =>
      'Entrez votre adresse e-mail pour récupérer votre mot de passe';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get confirmButton => 'Confirmer';

  @override
  String get passwordResetEmailSent =>
      'E-mail de réinitialisation de mot de passe envoyé. Veuillez vérifier votre boîte de réception.';

  @override
  String get getStartedTitle => 'Commencer';

  @override
  String get createAccountSubtitle => 'Créer un compte pour continuer';

  @override
  String get nameHint => 'Nom';

  @override
  String get confirmPasswordHint => 'Confirmer le mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get orContinueWith => 'Ou continuer avec';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get continueWithApple => 'Continuer avec Apple';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte?';

  @override
  String get selectCurrencyTitle => 'Sélectionner la devise';

  @override
  String get selectCurrencySubtitle => 'Sélectionnez votre devise préférée';

  @override
  String get selectCurrencyLabel => 'Sélectionner la devise';

  @override
  String get continueButton => 'Continuer';

  @override
  String errorDuringSetup(Object error) {
    return 'Erreur lors de la configuration : $error';
  }

  @override
  String get backButton => 'Retour';

  @override
  String get onboardingPage1Title => 'Épargnez Mieux';

  @override
  String get onboardingPage1Description =>
      'Mettez de l\'argent de côté sans effort et regardez vos économies grandir à chaque pas.';

  @override
  String get onboardingPage2Title => 'Atteignez Vos Objectifs';

  @override
  String get onboardingPage2Description =>
      'Créez des objectifs financiers, d\'un nouveau gadget à votre voyage de rêve, et suivez vos progrès.';

  @override
  String get onboardingPage3Title => 'Restez Sur la Bonne Voie';

  @override
  String get onboardingPage3Description =>
      'Surveillez vos dépenses, revenus et épargnes dans un seul tableau de bord simple.';

  @override
  String get paywallCouldNotLoadPlans =>
      'Impossible de charger les forfaits.\nVeuillez réessayer plus tard.';

  @override
  String get paywallChooseYourPlan => 'Choisissez Votre Forfait';

  @override
  String get paywallInvestInFinancialFreedom =>
      'Investissez dans votre liberté financière aujourd\'hui';

  @override
  String paywallPricePerDay(Object price) {
    return '$price/jour';
  }

  @override
  String paywallSaveAmount(Object amount) {
    return 'Économisez $amount';
  }

  @override
  String get paywallEverythingIncluded => 'Tout inclus:';

  @override
  String get paywallPersonalizedBudgetInsights =>
      'Créer des budgets récurrents';

  @override
  String get paywallDailyProgressTracking => 'Création de plusieurs comptes';

  @override
  String get paywallExpenseManagementTools => 'Mode vacances personnalisé';

  @override
  String get paywallFinancialHealthTimeline => 'Couleurs et personnalisation';

  @override
  String get paywallExpertGuidanceTips => 'Catégories personnalisées';

  @override
  String get paywallCommunitySupportAccess => 'Accès au support communautaire';

  @override
  String get paywallSaveYourFinances =>
      'Sécurisez vos finances et votre avenir';

  @override
  String get paywallAverageUserSaves =>
      'L\'utilisateur moyen économise ~£2,500 par an en budgétisant efficacement';

  @override
  String get paywallSubscribeYourPlan => 'Abonnez-vous à Votre Forfait';

  @override
  String get paywallPleaseSelectPlan => 'Veuillez sélectionner un forfait.';

  @override
  String get paywallSubscriptionActivated =>
      'Abonnement activé ! Vous avez maintenant accès aux fonctionnalités premium.';

  @override
  String paywallFailedToPurchase(Object message) {
    return 'Échec de l\'achat : $message';
  }

  @override
  String paywallUnexpectedError(Object error) {
    return 'Une erreur inattendue est survenue : $error';
  }

  @override
  String get paywallRestorePurchases => 'Restaurer les achats';

  @override
  String get paywallManageSubscription => 'Gérer l\'abonnement';

  @override
  String get paywallPurchasesRestoredSuccessfully =>
      'Achats restaurés avec succès !';

  @override
  String get paywallNoActiveSubscriptionFound =>
      'Aucun abonnement actif trouvé. Vous êtes maintenant sur le plan gratuit.';

  @override
  String get paywallPerMonth => 'par mois';

  @override
  String get paywallPerYear => 'par an';

  @override
  String get paywallBestValue => 'Meilleure Valeur';

  @override
  String get paywallMostPopular => 'Le Plus Populaire';

  @override
  String get mainScreenHome => 'Accueil';

  @override
  String get mainScreenBudget => 'Budget';

  @override
  String get mainScreenBalance => 'Solde';

  @override
  String get mainScreenGoals => 'Objectifs';

  @override
  String get mainScreenPersonal => 'Personnel';

  @override
  String get mainScreenIncome => 'Revenu';

  @override
  String get mainScreenExpense => 'Dépense';

  @override
  String get balanceTitle => 'Solde';

  @override
  String get balanceAddAccount => 'Ajouter un compte';

  @override
  String get addAVacation => 'Ajouter des vacances';

  @override
  String get balanceMyAccounts => 'MES COMPTES';

  @override
  String get balanceVacation => 'VACANCES';

  @override
  String get balanceAccountBalance => 'Solde du compte';

  @override
  String get balanceNoAccountsFound => 'Aucun compte trouvé.';

  @override
  String get balanceNoAccountsCreated => 'Aucun compte créé';

  @override
  String get balanceCreateFirstAccount =>
      'Créez votre premier compte pour commencer à suivre les soldes';

  @override
  String get balanceCreateFirstAccountFinances =>
      'Créez votre premier compte pour commencer à suivre vos finances';

  @override
  String get balanceNoVacationsYet => 'Pas encore de vacances';

  @override
  String get balanceCreateFirstVacation =>
      'Créez votre premier compte vacances pour commencer à planifier vos voyages';

  @override
  String get balanceCreateVacationAccount => 'Créer un compte vacances';

  @override
  String get balanceSingleAccountView => 'Vue de compte unique';

  @override
  String get balanceAddMoreAccounts =>
      'Ajoutez plus de comptes pour voir les graphiques';

  @override
  String get balanceNoAccountsForCurrency =>
      'Aucun compte trouvé pour la devise sélectionnée';

  @override
  String balanceCreditLimit(Object value) {
    return 'Limite de crédit : $value';
  }

  @override
  String balanceBalanceLimit(Object value) {
    return 'Limite de solde : $value';
  }

  @override
  String get budgetTitle => 'Budget';

  @override
  String get budgetAddBudget => 'Ajouter un budget';

  @override
  String get budgetDaily => 'Quotidien';

  @override
  String get budgetWeekly => 'Hebdomadaire';

  @override
  String get budgetMonthly => 'Mensuel';

  @override
  String get budgetSelectWeek => 'Sélectionner la semaine';

  @override
  String get budgetSelectDate => 'Sélectionner la date';

  @override
  String get budgetSelectDay => 'Sélectionner le jour';

  @override
  String get budgetCancel => 'Annuler';

  @override
  String get budgetApply => 'Appliquer';

  @override
  String get budgetTotalSpending => 'Dépenses totales';

  @override
  String get budgetCategoryBreakdown => 'Répartition par catégorie';

  @override
  String get budgetViewAll => 'Tout voir';

  @override
  String get budgetBudgets => 'Budgets';

  @override
  String get budgetNoBudgetCreated => 'Aucun budget créé';

  @override
  String get budgetStartCreatingBudget =>
      'Commencez par créer un budget pour voir votre répartition des dépenses ici.';

  @override
  String get budgetSetSpendingLimit => 'Définir la limite de dépenses';

  @override
  String get budgetEnterLimitAmount => 'Entrer le montant limite';

  @override
  String get budgetSave => 'Sauvegarder';

  @override
  String get budgetEnterValidNumber => 'Entrez un nombre valide';

  @override
  String get budgetLimitSaved => 'Limite de budget sauvegardée';

  @override
  String get budgetCreated => 'Budget créé';

  @override
  String get budgetTransactions => 'transactions';

  @override
  String budgetOverBudget(Object amount) {
    return '$amount au-dessus du budget';
  }

  @override
  String budgetRemaining(Object amount) {
    return '$amount restant';
  }

  @override
  String get homeNoMoreTransactions => 'Plus de transactions';

  @override
  String get homeErrorLoadingMoreTransactions =>
      'Erreur lors du chargement de plus de transactions';

  @override
  String get homeRetry => 'Réessayer';

  @override
  String get homeErrorLoadingData => 'Erreur lors du chargement des données';

  @override
  String get homeNoTransactionsRecorded => 'Aucune transaction enregistrée';

  @override
  String get homeStartAddingTransactions =>
      'Commencez par ajouter des transactions pour voir votre répartition des dépenses ici.';

  @override
  String get homeCurrencyChange => 'Changement de devise';

  @override
  String get homeCurrencyChangeMessage =>
      'Changer votre devise convertira tous les montants existants. Cette action est irréversible. Voulez-vous continuer?';

  @override
  String get homeNo => 'Non';

  @override
  String get homeYes => 'Oui';

  @override
  String get homeVacationBudgetBreakdown => 'Répartition du budget vacances';

  @override
  String get homeBalanceBreakdown => 'Répartition du solde';

  @override
  String get homeClose => 'Fermer';

  @override
  String get transactionPickColor => 'Choisir une couleur';

  @override
  String get transactionSelectDate => 'Sélectionner la date';

  @override
  String get transactionCancel => 'Annuler';

  @override
  String get transactionApply => 'Appliquer';

  @override
  String get transactionAmount => 'Montant';

  @override
  String get transactionSelect => 'Sélectionner';

  @override
  String get transactionPaid => 'Payé';

  @override
  String get transactionAddTransaction => 'Ajouter une transaction';

  @override
  String get transactionEditTransaction => 'Modifier la transaction';

  @override
  String get transactionIncome => 'Revenu';

  @override
  String get transactionExpense => 'Dépense';

  @override
  String get transactionDescription => 'Description';

  @override
  String get transactionCategory => 'Catégorie';

  @override
  String get transactionAccount => 'Compte';

  @override
  String get transactionDate => 'Date';

  @override
  String get transactionSave => 'Sauvegarder';

  @override
  String get transactionDelete => 'Supprimer';

  @override
  String get transactionSuccess => 'Transaction sauvegardée avec succès';

  @override
  String get transactionError =>
      'Erreur lors de la sauvegarde de la transaction';

  @override
  String get transactionDeleteConfirm =>
      'Êtes-vous sûr de vouloir supprimer cette transaction?';

  @override
  String get transactionDeleteSuccess => 'Transaction supprimée avec succès';

  @override
  String get goalsTitle => 'Objectifs';

  @override
  String get goalsAddGoal => 'Ajouter un objectif';

  @override
  String get goalsNoGoalsCreated => 'Aucun objectif créé';

  @override
  String get goalsStartCreatingGoal =>
      'Commencez par créer un objectif pour suivre vos progrès financiers';

  @override
  String get goalsCreateGoal => 'Créer un objectif';

  @override
  String get goalsEditGoal => 'Modifier l\'objectif';

  @override
  String get goalsGoalName => 'Nom de l\'objectif';

  @override
  String get goalsTargetAmount => 'Montant cible';

  @override
  String get goalsCurrentAmount => 'Montant actuel';

  @override
  String get goalsDeadline => 'Échéance';

  @override
  String get goalsDescription => 'Description';

  @override
  String get goalsSave => 'Sauvegarder';

  @override
  String get goalsCancel => 'Annuler';

  @override
  String get goalsDelete => 'Supprimer';

  @override
  String get goalsGoalCreated => 'Objectif créé avec succès';

  @override
  String get goalsGoalUpdated => 'Objectif mis à jour avec succès';

  @override
  String get goalsGoalDeleted => 'Objectif supprimé avec succès';

  @override
  String get goalsErrorSaving => 'Erreur lors de la sauvegarde de l\'objectif';

  @override
  String get goalsDeleteConfirm =>
      'Êtes-vous sûr de vouloir supprimer cet objectif?';

  @override
  String get goalsProgress => 'Progression';

  @override
  String get goalsCompleted => 'Terminé';

  @override
  String get goalsInProgress => 'En cours';

  @override
  String get goalsNotStarted => 'Non commencé';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePremiumActive => 'Premium Actif';

  @override
  String get profilePremiumDescription =>
      'Vous avez accès à toutes les fonctionnalités premium';

  @override
  String get profileFreePlan => 'Plan Gratuit';

  @override
  String get profileUpgradeDescription =>
      'Passez à la version premium pour des fonctionnalités avancées';

  @override
  String profileRenewalDate(Object date) {
    return 'Renouvellement le $date';
  }

  @override
  String profileExpiresOn(Object date) {
    return 'Expire le $date';
  }

  @override
  String profileErrorSigningOut(Object error) {
    return 'Erreur lors de la déconnexion : $error';
  }

  @override
  String get profileUserNotFound => 'Utilisateur non trouvé';

  @override
  String get profileEditDisplayName => 'Modifier le nom d\'affichage';

  @override
  String get profileCancel => 'Annuler';

  @override
  String get profileSave => 'Sauvegarder';

  @override
  String get profileDisplayNameUpdated =>
      'Nom d\'affichage mis à jour avec succès';

  @override
  String get profileErrorUpdatingName =>
      'Erreur lors de la mise à jour du nom d\'affichage';

  @override
  String get profileManageSubscription => 'Gérer l\'abonnement';

  @override
  String get profileRestorePurchases => 'Restaurer les achats';

  @override
  String get profileRefreshStatus => 'Actualiser le statut';

  @override
  String get profileSubscriptionRefreshed =>
      'Statut de l\'abonnement actualisé';

  @override
  String get profileSignOut => 'Se déconnecter';

  @override
  String get profileSignOutConfirm =>
      'Êtes-vous sûr de vouloir vous déconnecter?';

  @override
  String get profileCurrencyRates => 'Taux de change';

  @override
  String get profileCategories => 'Catégories';

  @override
  String get profileFeedback => 'Commentaires';

  @override
  String get profileExportData => 'Exporter les données';

  @override
  String get profileSettings => 'Paramètres';

  @override
  String get profileAccount => 'Compte';

  @override
  String get profileDisplayName => 'Nom d\'affichage';

  @override
  String get profileEmail => 'E-mail';

  @override
  String get profileSubscription => 'Abonnement';

  @override
  String get profileVersion => 'Version';

  @override
  String get personalTitle => 'Personnel';

  @override
  String get personalSubscriptions => 'Abonnements';

  @override
  String get personalBorrowed => 'Emprunté';

  @override
  String get personalAddSubscription => 'Ajouter un abonnement';

  @override
  String get personalAddLent => 'Ajouter un prêt';

  @override
  String get personalAddBorrowed => 'Ajouter un emprunt';

  @override
  String get personalNoSubscriptions => 'Aucun abonnement trouvé';

  @override
  String get personalNoLent => 'Aucun article prêté trouvé';

  @override
  String get personalNoBorrowed => 'Aucun article emprunté trouvé';

  @override
  String get personalStartAddingSubscription =>
      'Commencez par ajouter un abonnement pour suivre vos paiements récurrents';

  @override
  String get personalStartAddingLent =>
      'Commencez par ajouter des articles prêtés pour suivre l\'argent que vous avez prêté';

  @override
  String get personalStartAddingBorrowed =>
      'Commencez par ajouter des articles empruntés pour suivre l\'argent que vous avez emprunté';

  @override
  String get personalEdit => 'Modifier';

  @override
  String get personalDelete => 'Supprimer';

  @override
  String get personalMarkAsPaid => 'Marquer comme payé';

  @override
  String get personalMarkAsUnpaid => 'Marquer comme impayé';

  @override
  String get personalAmount => 'Montant';

  @override
  String get personalDescription => 'Description';

  @override
  String get personalDueDate => 'Date d\'échéance';

  @override
  String get personalRecurring => 'Récurrent';

  @override
  String get personalOneTime => 'Une seule fois';

  @override
  String get personalMonthly => 'Mensuel';

  @override
  String get personalYearly => 'Annuel';

  @override
  String get personalWeekly => 'Hebdomadaire';

  @override
  String get personalDaily => 'Quotidien';

  @override
  String get personalName => 'Nom';

  @override
  String get personalCategory => 'Catégorie';

  @override
  String get personalNotes => 'Notes';

  @override
  String get personalSave => 'Sauvegarder';

  @override
  String get personalCancel => 'Annuler';

  @override
  String get personalDeleteConfirm =>
      'Êtes-vous sûr de vouloir supprimer cet article?';

  @override
  String get personalItemSaved => 'Article sauvegardé avec succès';

  @override
  String get personalItemDeleted => 'Article supprimé avec succès';

  @override
  String get personalErrorSaving =>
      'Erreur lors de la sauvegarde de l\'article';

  @override
  String get personalErrorDeleting =>
      'Erreur lors de la suppression de l\'article';

  @override
  String get analyticsTitle => 'Analytique';

  @override
  String get analyticsOverview => 'Aperçu';

  @override
  String get analyticsIncome => 'Revenu';

  @override
  String get analyticsExpenses => 'Dépenses';

  @override
  String get analyticsSavings => 'Économies';

  @override
  String get analyticsCategories => 'Catégories';

  @override
  String get analyticsTrends => 'Tendances';

  @override
  String get analyticsMonthly => 'Mensuel';

  @override
  String get analyticsWeekly => 'Hebdomadaire';

  @override
  String get analyticsDaily => 'Quotidien';

  @override
  String get analyticsYearly => 'Annuel';

  @override
  String get analyticsNoData => 'Aucune donnée disponible';

  @override
  String get analyticsStartTracking =>
      'Commencez à suivre vos finances pour voir l\'analytique ici';

  @override
  String get analyticsTotalIncome => 'Revenu total';

  @override
  String get analyticsTotalExpenses => 'Dépenses totales';

  @override
  String get analyticsNetSavings => 'Économies nettes';

  @override
  String get analyticsTopCategories => 'Catégories principales';

  @override
  String get analyticsSpendingTrends => 'Tendances des dépenses';

  @override
  String get analyticsIncomeTrends => 'Tendances des revenus';

  @override
  String get analyticsSavingsRate => 'Taux d\'épargne';

  @override
  String get analyticsAverageDaily => 'Moyenne quotidienne';

  @override
  String get analyticsAverageWeekly => 'Moyenne hebdomadaire';

  @override
  String get analyticsAverageMonthly => 'Moyenne mensuelle';

  @override
  String get analyticsSelectPeriod => 'Sélectionner la période';

  @override
  String get analyticsExportData => 'Exporter les données';

  @override
  String get analyticsRefresh => 'Actualiser';

  @override
  String get analyticsErrorLoading =>
      'Erreur lors du chargement des données analytiques';

  @override
  String get analyticsRetry => 'Réessayer';

  @override
  String get goalsSelectColor => 'Sélectionner la couleur';

  @override
  String get goalsMore => 'Plus';

  @override
  String get goalsName => 'Nom de l\'objectif';

  @override
  String get goalsColor => 'Couleur';

  @override
  String get goalsNameRequired => 'Le nom de l\'objectif est requis';

  @override
  String get goalsAmountRequired => 'Le montant cible est requis';

  @override
  String get goalsAmountMustBePositive =>
      'Le montant cible doit être supérieur à 0';

  @override
  String get goalsDeadlineRequired => 'L\'échéance est requise';

  @override
  String get goalsDeadlineMustBeFuture => 'L\'échéance doit être dans le futur';

  @override
  String get goalsNameAlreadyExists => 'Un objectif avec ce nom existe déjà';

  @override
  String goalsErrorCreating(Object error) {
    return 'Erreur lors de la création de l\'objectif : $error';
  }

  @override
  String goalsErrorUpdating(Object error) {
    return 'Erreur lors de la mise à jour de l\'objectif : $error';
  }

  @override
  String goalsErrorDeleting(Object error) {
    return 'Erreur lors de la suppression de l\'objectif : $error';
  }

  @override
  String get expenseDetailTitle => 'Détail de la dépense';

  @override
  String get expenseDetailEdit => 'Modifier';

  @override
  String get expenseDetailDelete => 'Supprimer';

  @override
  String get expenseDetailAmount => 'Montant';

  @override
  String get expenseDetailCategory => 'Catégorie';

  @override
  String get expenseDetailAccount => 'Compte';

  @override
  String get expenseDetailDate => 'Date';

  @override
  String get expenseDetailDescription => 'Description';

  @override
  String get expenseDetailNotes => 'Notes';

  @override
  String get expenseDetailSave => 'Sauvegarder';

  @override
  String get expenseDetailCancel => 'Annuler';

  @override
  String get expenseDetailDeleteConfirm =>
      'Êtes-vous sûr de vouloir supprimer cette dépense?';

  @override
  String get expenseDetailUpdated => 'Dépense mise à jour avec succès';

  @override
  String get expenseDetailDeleted => 'Dépense supprimée avec succès';

  @override
  String get expenseDetailErrorSaving =>
      'Erreur lors de la sauvegarde de la dépense';

  @override
  String get expenseDetailErrorDeleting =>
      'Erreur lors de la suppression de la dépense';

  @override
  String get calendarTitle => 'Calendrier';

  @override
  String get calendarSelectDate => 'Sélectionner la date';

  @override
  String get calendarToday => 'Aujourd\'hui';

  @override
  String get calendarThisWeek => 'Cette semaine';

  @override
  String get calendarThisMonth => 'Ce mois-ci';

  @override
  String get calendarThisYear => 'Cette année';

  @override
  String get calendarNoTransactions => 'Aucune transaction à cette date';

  @override
  String get calendarStartAddingTransactions =>
      'Commencez à ajouter des transactions pour les voir sur le calendrier';

  @override
  String get vacationDialogTitle => 'Mode Vacances';

  @override
  String get vacationDialogEnable => 'Activer le mode Vacances';

  @override
  String get vacationDialogDisable => 'Désactiver le mode Vacances';

  @override
  String get vacationDialogDescription =>
      'Le mode vacances vous aide à suivre les dépenses pendant les voyages et les congés';

  @override
  String get vacationDialogCancel => 'Annuler';

  @override
  String get vacationDialogConfirm => 'Confirmer';

  @override
  String get vacationDialogEnabled => 'Mode vacances activé';

  @override
  String get vacationDialogDisabled => 'Mode vacances désactivé';

  @override
  String get balanceDetailTitle => 'Détail du compte';

  @override
  String get balanceDetailEdit => 'Modifier';

  @override
  String get balanceDetailDelete => 'Supprimer';

  @override
  String get balanceDetailTransactions => 'Transactions';

  @override
  String get balanceDetailBalance => 'Solde';

  @override
  String get balanceDetailCreditLimit => 'Limite de crédit';

  @override
  String get balanceDetailBalanceLimit => 'Limite de solde';

  @override
  String get balanceDetailCurrency => 'Devise';

  @override
  String get balanceDetailAccountType => 'Type de compte';

  @override
  String get balanceDetailAccountName => 'Nom du compte';

  @override
  String get balanceDetailSave => 'Sauvegarder';

  @override
  String get balanceDetailCancel => 'Annuler';

  @override
  String get balanceDetailDeleteConfirm =>
      'Êtes-vous sûr de vouloir supprimer ce compte?';

  @override
  String get balanceDetailUpdated => 'Compte mis à jour avec succès';

  @override
  String get balanceDetailDeleted => 'Compte supprimé avec succès';

  @override
  String get balanceDetailErrorSaving =>
      'Erreur lors de la sauvegarde du compte';

  @override
  String get balanceDetailErrorDeleting =>
      'Erreur lors de la suppression du compte';

  @override
  String get addAccountTitle => 'Ajouter un compte';

  @override
  String get addAccountEditTitle => 'Modifier le compte';

  @override
  String get addAccountName => 'Nom du compte';

  @override
  String get addAccountType => 'Type de compte';

  @override
  String get addAccountCurrency => 'Devise';

  @override
  String get addAccountInitialBalance => 'Solde initial';

  @override
  String get addAccountCreditLimit => 'Limite de crédit';

  @override
  String get addAccountBalanceLimit => 'Limite de solde';

  @override
  String get addAccountColor => 'Couleur';

  @override
  String get addAccountIcon => 'Icône';

  @override
  String get addAccountSave => 'Sauvegarder';

  @override
  String get addAccountCancel => 'Annuler';

  @override
  String get addAccountCreated => 'Compte créé avec succès';

  @override
  String get addAccountUpdated => 'Compte mis à jour avec succès';

  @override
  String get addAccountErrorSaving => 'Erreur lors de la sauvegarde du compte';

  @override
  String get addAccountNameRequired => 'Le nom du compte est requis';

  @override
  String get addAccountTypeRequired => 'Le type de compte est requis';

  @override
  String get addAccountCurrencyRequired => 'La devise est requise';

  @override
  String get budgetDetailTitle => 'Détail du budget';

  @override
  String get budgetDetailEdit => 'Modifier';

  @override
  String get budgetDetailDelete => 'Supprimer';

  @override
  String get budgetDetailSpending => 'Dépenses';

  @override
  String get budgetDetailLimit => 'Limite';

  @override
  String get budgetDetailRemaining => 'Restant';

  @override
  String get budgetDetailOverBudget => 'Dépassement de budget';

  @override
  String get budgetDetailCategories => 'Catégories';

  @override
  String get budgetDetailTransactions => 'Transactions';

  @override
  String get budgetDetailSave => 'Sauvegarder';

  @override
  String get budgetDetailCancel => 'Annuler';

  @override
  String get budgetDetailDeleteConfirm =>
      'Êtes-vous sûr de vouloir supprimer ce budget?';

  @override
  String get budgetDetailUpdated => 'Budget mis à jour avec succès';

  @override
  String get budgetDetailDeleted => 'Budget supprimé avec succès';

  @override
  String get budgetDetailErrorSaving =>
      'Erreur lors de la sauvegarde du budget';

  @override
  String get budgetDetailErrorDeleting =>
      'Erreur lors de la suppression du budget';

  @override
  String get addBudgetTitle => 'Ajouter un budget';

  @override
  String get addBudgetEditTitle => 'Modifier le budget';

  @override
  String get addBudgetName => 'Nom du budget';

  @override
  String get addBudgetType => 'Type de budget';

  @override
  String get addBudgetAmount => 'Montant';

  @override
  String get addBudgetCurrency => 'Devise';

  @override
  String get addBudgetPeriod => 'Période';

  @override
  String get addBudgetCategories => 'Catégories';

  @override
  String get addBudgetColor => 'Couleur';

  @override
  String get addBudgetSave => 'Sauvegarder';

  @override
  String get addBudgetSaveBudget => 'Sauvegarder le budget';

  @override
  String get addBudgetCancel => 'Annuler';

  @override
  String get addBudgetCreated => 'Budget créé avec succès';

  @override
  String get addBudgetUpdated => 'Budget mis à jour avec succès';

  @override
  String get addBudgetErrorSaving => 'Erreur lors de la sauvegarde du budget';

  @override
  String get addBudgetNameRequired => 'Le nom du budget est requis';

  @override
  String get addBudgetAmountRequired => 'Le montant du budget est requis';

  @override
  String get addBudgetAmountMustBePositive =>
      'Le montant du budget doit être supérieur à 0';

  @override
  String get addBudgetCategoryRequired => 'Veuillez sélectionner une catégorie';

  @override
  String get budgetDetailNoBudgetToDelete =>
      'Pas de budget à supprimer. Ceci est juste un espace réservé pour les transactions.';

  @override
  String get personalItemDetails => 'Détails de l\'article';

  @override
  String get personalStartDateRequired =>
      'Veuillez sélectionner une date de début';

  @override
  String get profileMainCurrency => 'DEVISE PRINCIPALE';

  @override
  String get profileFeedbackThankYou => 'Merci pour vos commentaires!';

  @override
  String get profileFeedbackEmailError =>
      'Impossible d\'ouvrir le client de messagerie.';

  @override
  String get feedbackModalTitle => 'Vous appréciez l\'application?';

  @override
  String get feedbackModalDescription =>
      'Vos commentaires nous motivent et nous aident à nous améliorer.';

  @override
  String get goalNameAlreadyExistsSnackbar =>
      'Un objectif avec ce nom existe déjà';

  @override
  String get lentSelectBothDates =>
      'Veuillez sélectionner à la fois la date et la date d\'échéance';

  @override
  String get lentDueDateBeforeLentDate =>
      'La date d\'échéance ne peut pas être antérieure à la date du prêt';

  @override
  String get lentItemAddedSuccessfully => 'Article prêté ajouté avec succès';

  @override
  String lentItemError(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get borrowedSelectBothDates =>
      'Veuillez sélectionner à la fois la date et la date d\'échéance';

  @override
  String get borrowedDueDateBeforeBorrowedDate =>
      'La date d\'échéance ne peut pas être antérieure à la date d\'emprunt';

  @override
  String get borrowedItemAddedSuccessfully =>
      'Article emprunté ajouté avec succès';

  @override
  String borrowedItemError(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get subscriptionCreatedSuccessfully => 'Abonnement créé avec succès';

  @override
  String subscriptionError(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get paymentMarkedSuccessfully => 'Paiement marqué avec succès';

  @override
  String get subscriptionContinued => 'Abonnement poursuivi avec succès';

  @override
  String get subscriptionPaused => 'Abonnement mis en pause avec succès';

  @override
  String get itemMarkedAsReturnedSuccessfully =>
      'Article marqué comme retourné avec succès';

  @override
  String get itemDeletedSuccessfully => 'Article supprimé avec succès';

  @override
  String get failedToDeleteBudget => 'Échec de la suppression du budget';

  @override
  String get failedToDeleteGoal => 'Échec de la suppression de l\'objectif';

  @override
  String failedToSaveTransaction(Object error) {
    return 'Échec de la sauvegarde de la transaction : $error';
  }

  @override
  String get failedToReorderCategories =>
      'Échec de la réorganisation des catégories. Annulation des changements.';

  @override
  String get categoryAddedSuccessfully => 'Catégorie ajoutée avec succès';

  @override
  String failedToAddCategory(Object error) {
    return 'Échec de l\'ajout de la catégorie : $error';
  }

  @override
  String get addCategory => 'Ajouter une catégorie';

  @override
  String errorCreatingGoal(Object error) {
    return 'Erreur lors de la création de l\'objectif : $error';
  }

  @override
  String get hintName => 'Nom';

  @override
  String get hintDescription => 'Description';

  @override
  String get hintSelectDate => 'Sélectionner la date';

  @override
  String get hintSelectDueDate => 'Sélectionner la date d\'échéance';

  @override
  String get hintSelectCategory => 'Sélectionner la catégorie';

  @override
  String get hintSelectAccount => 'Sélectionner le compte';

  @override
  String get hintSelectGoal => 'Sélectionner l\'objectif';

  @override
  String get hintNotes => 'Notes';

  @override
  String get hintSelectColor => 'Sélectionner la couleur';

  @override
  String get hintEnterCategoryName => 'Entrer le nom de la catégorie';

  @override
  String get hintSelectType => 'Sélectionner le type';

  @override
  String get hintWriteThoughts => 'Écrivez vos pensées ici......';

  @override
  String get hintEnterDisplayName => 'Entrer le nom d\'affichage';

  @override
  String get hintSelectBudgetType => 'Sélectionner le type de budget';

  @override
  String get hintSelectAccountType => 'Sélectionner le type de compte';

  @override
  String get hintEnterName => 'Entrer le nom';

  @override
  String get hintSelectIcon => 'Sélectionner l\'icône';

  @override
  String get hintSelect => 'Sélectionner';

  @override
  String get hintAmountPlaceholder => '0,00';

  @override
  String get labelValue => 'Valeur';

  @override
  String get labelName => 'Nom';

  @override
  String get labelDescription => 'Description';

  @override
  String get labelCategory => 'Catégorie';

  @override
  String get labelDate => 'Date';

  @override
  String get labelDueDate => 'Date d\'échéance';

  @override
  String get labelColor => 'Couleur';

  @override
  String get labelNotes => 'Notes';

  @override
  String get labelAccount => 'Compte';

  @override
  String get labelMore => 'Plus';

  @override
  String get labelHome => 'Accueil';

  @override
  String get titlePickColor => 'Choisir une couleur';

  @override
  String get titleAddLentItem => 'Ajouter un article prêté';

  @override
  String get titleAddBorrowedItem => 'Ajouter un article emprunté';

  @override
  String get titleSelectCategory => 'Sélectionner la catégorie';

  @override
  String get titleSelectAccount => 'Sélectionner le compte';

  @override
  String get titleSelectGoal => 'Sélectionner l\'objectif';

  @override
  String get titleSelectType => 'Sélectionner le type';

  @override
  String get titleSelectAccountType => 'Sélectionner le type de compte';

  @override
  String get titleSelectBudgetType => 'Sélectionner le type de budget';

  @override
  String get validationNameRequired => 'Le nom est requis';

  @override
  String get validationAmountRequired => 'Le montant est requis';

  @override
  String get validationPleaseEnterValidNumber =>
      'Veuillez entrer un nombre valide';

  @override
  String get validationPleaseSelectIcon => 'Veuillez sélectionner une icône';

  @override
  String get buttonCancel => 'Annuler';

  @override
  String get buttonAdd => 'Ajouter';

  @override
  String get buttonSave => 'Sauvegarder';

  @override
  String get switchAddProgress => 'Ajouter la progression';

  @override
  String get pickColor => 'Choisir une couleur';

  @override
  String get name => 'Nom';

  @override
  String get itemName => 'Nom de l\'article';

  @override
  String get account => 'Compte';

  @override
  String get selectIcon => 'Veuillez sélectionner une icône';

  @override
  String get value => 'Valeur';

  @override
  String get hintAmount => '0,00';

  @override
  String get hintItemName => 'Nom de l\'article';

  @override
  String get amountRequired => 'Le montant est requis';

  @override
  String get validNumber => 'Veuillez entrer un nombre valide';

  @override
  String get category => 'Catégorie';

  @override
  String get date => 'Date';

  @override
  String get dueDate => 'Date d\'échéance';

  @override
  String get color => 'Couleur';

  @override
  String get notes => 'Notes';

  @override
  String get selectColor => 'Sélectionner la couleur';

  @override
  String get more => 'Plus';

  @override
  String get addLentItem => 'Ajouter un article prêté';

  @override
  String get addBorrowedItem => 'Ajouter un article emprunté';

  @override
  String get cancel => 'Annuler';

  @override
  String get add => 'Ajouter';

  @override
  String get nameRequired => 'Le nom est requis';

  @override
  String get buttonOk => 'OK';

  @override
  String get vacationNoAccountsAvailable => 'Aucun compte vacances disponible.';

  @override
  String get exportFormat => 'Format';

  @override
  String get exportOptions => 'Options';

  @override
  String get exportAccountData => 'Exporter les données du compte';

  @override
  String get exportGoalsData => 'Exporter les données des objectifs';

  @override
  String get exportCurrentMonth => 'Mois actuel';

  @override
  String get exportLast30Days => '30 derniers jours';

  @override
  String get exportLast90Days => '90 derniers jours';

  @override
  String get exportLast365Days => '365 derniers jours';

  @override
  String get exportCsv => 'CSV';

  @override
  String get exportJson => 'JSON';

  @override
  String get exportImportInstructions =>
      'Vous pouvez importer vos données dans l\'application à partir d\'un fichier CSV.';

  @override
  String get exportInstructions1 =>
      'Sauvegardez l\'exemple de fichier pour voir le format de données requis;';

  @override
  String get exportInstructions2 =>
      'Formatez vos données selon le modèle. Assurez-vous que les colonnes, leur ordre et leurs noms sont exactement les mêmes que dans le modèle. Les noms des colonnes doivent être en anglais;';

  @override
  String get exportInstructions3 =>
      'Appuyez sur Importer et sélectionnez votre fichier;';

  @override
  String get exportInstructions4 =>
      'Choisissez d\'écraser les données existantes ou d\'ajouter les données importées aux données existantes. En choisissant l\'option d\'écrasement, les données existantes seront définitivement supprimées;';

  @override
  String get exportButtonExport => 'Exporter';

  @override
  String get exportButtonImport => 'Importer';

  @override
  String get exportTabExport => 'Exportation';

  @override
  String get exportTabImport => 'Importation';

  @override
  String get enableVacationMode => 'Activer le mode Vacances';

  @override
  String get addProgress => 'Ajouter la progression';

  @override
  String get pleaseEnterValidNumber => 'Veuillez entrer un nombre valide';

  @override
  String get pleaseSelectCategory => 'Veuillez sélectionner une catégorie';

  @override
  String get pleaseSelectCurrency => 'Veuillez sélectionner une devise';

  @override
  String get pleaseSelectAccount => 'Veuillez sélectionner un compte';

  @override
  String get pleaseSelectDate => 'Veuillez sélectionner une date';

  @override
  String get pleaseSelectIcon => 'Veuillez sélectionner une icône';

  @override
  String get deleteCategory => 'Supprimer la catégorie';

  @override
  String get markAsReturned => 'Marquer comme retourné';

  @override
  String get markPayment => 'Marquer le paiement';

  @override
  String get markPaid => 'Marquer comme payé';

  @override
  String get deleteItem => 'Supprimer l\'article';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAllAssociatedTransactions =>
      'Supprimer toutes les transactions associées';

  @override
  String get normalMode => 'Mode Normal';

  @override
  String normalModeWithCurrency(String currency) {
    return 'Vous êtes maintenant en Mode Normal avec la devise : $currency';
  }

  @override
  String get changeCurrency => 'Changer la devise';

  @override
  String get vacationModeDialog => 'Dialogue Mode Vacances';

  @override
  String get categoryAndTransactionsDeleted =>
      'Catégorie et transactions associées supprimées avec succès';

  @override
  String get select => 'Sélectionner';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get yourData => 'Vos Données';

  @override
  String get profileMenuAccount => 'COMPTE';

  @override
  String get profileMenuCurrency => 'Devise';

  @override
  String get profileSectionLegal => 'LÉGAL';

  @override
  String get profileTermsConditions => 'Conditions Générales';

  @override
  String get profilePrivacyPolicy => 'Politique de Confidentialité';

  @override
  String get profileSectionSupport => 'SUPPORT';

  @override
  String get profileHelpSupport => 'Aide & Support';

  @override
  String get profileSectionDanger => 'ZONE DE DANGER';

  @override
  String get currencyPageChange => 'CHANGER';

  @override
  String get addTransactionNotes => 'Notes';

  @override
  String get addTransactionMore => 'Plus';

  @override
  String get addTransactionDate => 'Date';

  @override
  String get addTransactionTime => 'Heure';

  @override
  String get addTransactionPaid => 'Payé';

  @override
  String get addTransactionColor => 'Couleur';

  @override
  String get addTransactionCancel => 'Annuler';

  @override
  String get addTransactionCreate => 'Créer';

  @override
  String get addTransactionUpdate => 'Mettre à jour';

  @override
  String get addBudgetLimitAmount => 'Montant limite';

  @override
  String get addBudgetSelectCategory => 'Sélectionner la catégorie';

  @override
  String get addBudgetBudgetType => 'Type de budget';

  @override
  String get addBudgetRecurring => 'Budget récurrent';

  @override
  String get addBudgetRecurringSubtitle =>
      'Renouveler automatiquement ce budget pour chaque période';

  @override
  String get addBudgetRecurringDailySubtitle => 'S\'applique à chaque jour';

  @override
  String get addBudgetRecurringPremiumSubtitle =>
      'Fonctionnalité Premium - Abonnez-vous pour l\'activer';

  @override
  String get addBudget => 'Ajouter un budget';

  @override
  String get addAccountTransactionLimit => 'Limite de transaction';

  @override
  String get addAccountAccountType => 'Type de compte';

  @override
  String get addAccountAdd => 'Ajouter';

  @override
  String get addAccountBalance => 'Solde';

  @override
  String get addAccountCredit => 'Crédit';

  @override
  String get homeIncomeCard => 'Revenu';

  @override
  String get homeExpenseCard => 'Dépense';

  @override
  String get homeTotalBudget => 'Budget total';

  @override
  String get balanceDetailInitialBalance => 'Solde initial';

  @override
  String get balanceDetailCurrentBalance => 'Solde actuel';

  @override
  String get expenseDetailTotal => 'Total';

  @override
  String get expenseDetailAccumulatedAmount => 'Montant accumulé';

  @override
  String get expenseDetailPaidStatus => 'PAYÉ/IMPAYÉ';

  @override
  String get expenseDetailVacation => 'Vacances';

  @override
  String get expenseDetailMarkPaid => 'Marquer comme payé';

  @override
  String get expenseDetailMarkUnpaid => 'Marquer comme impayé';

  @override
  String get goalsScreenPending => 'Objectifs en attente';

  @override
  String get goalsScreenFulfilled => 'Objectifs réalisés';

  @override
  String get createGoalTitle => 'Créer un objectif en attente';

  @override
  String get createGoalAmount => 'Montant';

  @override
  String get createGoalName => 'Nom';

  @override
  String get createGoalCurrency => 'Devise';

  @override
  String get createGoalMore => 'Plus';

  @override
  String get createGoalNotes => 'Notes';

  @override
  String get createGoalDate => 'Date';

  @override
  String get createGoalColor => 'Couleur';

  @override
  String get createGoalLimitReached =>
      'Vous avez atteint la limite d\'objectifs. Passez au premium pour créer des objectifs illimités.';

  @override
  String get personalScreenSubscriptions => 'Abonnements';

  @override
  String get personalScreenBorrowed => 'Emprunté';

  @override
  String get personalScreenLent => 'Prêté';

  @override
  String get personalScreenTotal => 'Total';

  @override
  String get personalScreenActive => 'Actif';

  @override
  String get personalScreenNoSubscriptions => 'Pas encore d\'abonnements';

  @override
  String get personalScreenNoBorrowed => 'Pas encore d\'articles empruntés';

  @override
  String get personalScreenBorrowedItems => 'Articles empruntés';

  @override
  String get personalScreenLentItems => 'Articles prêtés';

  @override
  String get personalScreenNoLent => 'Pas encore d\'articles prêtés';

  @override
  String get addBorrowedTitle => 'Ajouter un article emprunté';

  @override
  String get addLentTitle => 'Ajouter un article prêté';

  @override
  String get addBorrowedName => 'Nom';

  @override
  String get addBorrowedAmount => 'Montant';

  @override
  String get addBorrowedNotes => 'Notes';

  @override
  String get addBorrowedMore => 'Plus';

  @override
  String get addBorrowedDate => 'Date';

  @override
  String get addBorrowedDueDate => 'Date d\'échéance';

  @override
  String get addBorrowedReturned => 'Retourné';

  @override
  String get addBorrowedMarkReturned => 'Marquer comme retourné';

  @override
  String get addSubscriptionPrice => 'Prix';

  @override
  String get addSubscriptionName => 'Nom';

  @override
  String get addSubscriptionRecurrence => 'Récurrence';

  @override
  String get addSubscriptionMore => 'Plus';

  @override
  String get addSubscriptionNotes => 'Notes';

  @override
  String get addSubscriptionStartDate => 'Date de début';

  @override
  String get addLentName => 'Nom';

  @override
  String get addLentAmount => 'Montant';

  @override
  String get addLentNotes => 'Notes';

  @override
  String get addLentMore => 'Plus';

  @override
  String get addLentDate => 'Date';

  @override
  String get addLentDueDate => 'Date d\'échéance';

  @override
  String get addLentReturned => 'Retourné';

  @override
  String get addLentMarkReturned => 'Marquer comme retourné';

  @override
  String get currencyPageTitle => 'Taux de change';

  @override
  String get profileVacationMode => 'Mode Vacances';

  @override
  String get profileCurrency => 'Devise';

  @override
  String get profileLegal => 'LÉGAL';

  @override
  String get profileSupport => 'SUPPORT';

  @override
  String get profileDangerZone => 'ZONE DE DANGER';

  @override
  String get profileLogout => 'Déconnexion';

  @override
  String get profileDeleteAccount => 'Supprimer le compte';

  @override
  String get profileDeleteAccountTitle => 'Supprimer le compte';

  @override
  String get profileDeleteAccountMessage =>
      'Êtes-vous sûr de vouloir supprimer votre compte? Cette action est irréversible. Toutes vos données, y compris les comptes, transactions, budgets et objectifs, seront définitivement supprimées.';

  @override
  String get profileDeleteAccountConfirm => 'Supprimer';

  @override
  String get profileDeleteAccountSuccess => 'Compte supprimé avec succès';

  @override
  String profileDeleteAccountError(String error) {
    return 'Erreur lors de la suppression du compte : $error';
  }

  @override
  String get homeIncome => 'Revenu';

  @override
  String get homeExpense => 'Dépense';

  @override
  String get expenseDetailPaidUnpaid => 'PAYÉ/IMPAYÉ';

  @override
  String get goalsScreenPendingGoals => 'Objectifs en attente';

  @override
  String get goalsScreenFulfilledGoals => 'Objectifs réalisés';

  @override
  String get transactionEditIncome => 'Modifier le revenu';

  @override
  String get transactionEditExpense => 'Modifier la dépense';

  @override
  String get transactionPlanIncome => 'Planifier un revenu';

  @override
  String get transactionPlanExpense => 'Planifier une dépense';

  @override
  String get goal => 'Objectif';

  @override
  String get none => 'Aucun';

  @override
  String get unnamedCategory => 'Catégorie sans nom';

  @override
  String get month => 'Mois';

  @override
  String get daily => 'Quotidien';

  @override
  String get weekly => 'Hebdomadaire';

  @override
  String get monthly => 'Mensuel';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languageArabic => 'Arabe';

  @override
  String get languageSelectLanguage => 'Sélectionner la langue';

  @override
  String get vacationCurrencyDialogTitle => 'Devise Vacances';

  @override
  String vacationCurrencyDialogMessage(Object previousCurrency) {
    return 'Vous pouvez changer les devises pour vos transactions de vacances. Souhaitez-vous changer la devise maintenant?\n\nVotre devise précédente était $previousCurrency.';
  }

  @override
  String vacationCurrencyDialogKeepCurrent(Object previousCurrency) {
    return 'Garder l\'actuelle ($previousCurrency)';
  }

  @override
  String get includeVacationTransaction =>
      'Inclure les transactions de vacances';

  @override
  String get showVacationTransactions =>
      'Afficher les transactions de vacances en mode normal';

  @override
  String get balanceDetailTransactionsWillAppear =>
      'Les transactions pour ce compte apparaîtront ici';

  @override
  String get personalNextBilling => 'Prochaine facturation';

  @override
  String get personalActive => 'Actif';

  @override
  String get personalInactive => 'Inactif';

  @override
  String get personalReturned => 'Retourné';

  @override
  String get personalLent => 'Prêté';

  @override
  String get personalDue => 'Dû';

  @override
  String get personalItems => 'Article(s)';

  @override
  String get status => 'Statut';

  @override
  String get notReturned => 'Non retourné';

  @override
  String get borrowedOn => 'Emprunté le';

  @override
  String get lentOn => 'Prêté le';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Reprendre';

  @override
  String get upcomingBills => 'Factures à venir';

  @override
  String get upcomingCharge => 'Charge à venir';

  @override
  String get pastHistory => 'Historique passé';

  @override
  String get noHistoryYet => 'Pas encore d\'historique';

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
