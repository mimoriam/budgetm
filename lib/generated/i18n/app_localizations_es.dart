// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get loginTitle => 'Iniciar Sesión';

  @override
  String get loginSubtitle =>
      'Ingresa tu correo y contraseña para iniciar sesión';

  @override
  String get emailHint => 'Correo electrónico';

  @override
  String get passwordHint => 'Contraseña';

  @override
  String get rememberMe => 'Recordarme';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginButton => 'Iniciar Sesión';

  @override
  String get orLoginWith => 'O inicia sesión con';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta?';

  @override
  String get signUp => 'Regístrate';

  @override
  String get forgotPasswordTitle => 'Contraseña Olvidada';

  @override
  String get forgotPasswordSubtitle =>
      'Ingresa tu dirección de correo para recuperar tu contraseña';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get confirmButton => 'Confirmar';

  @override
  String get passwordResetEmailSent =>
      'Correo de restablecimiento de contraseña enviado. Por favor revisa tu bandeja de entrada.';

  @override
  String get getStartedTitle => 'Comenzar';

  @override
  String get createAccountSubtitle => 'Crea una cuenta para continuar';

  @override
  String get nameHint => 'Nombre';

  @override
  String get confirmPasswordHint => 'Confirmar Contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get orContinueWith => 'O continúa con';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get selectCurrencyTitle => 'Seleccionar Moneda';

  @override
  String get selectCurrencySubtitle => 'Selecciona tu moneda preferida';

  @override
  String get selectCurrencyLabel => 'Seleccionar Moneda';

  @override
  String get continueButton => 'Continuar';

  @override
  String errorDuringSetup(Object error) {
    return 'Error durante la configuración: $error';
  }

  @override
  String get backButton => 'Atrás';

  @override
  String get onboardingPage1Title => 'Ahorra Inteligentemente';

  @override
  String get onboardingPage1Description =>
      'Aparta dinero sin esfuerzo y mira crecer tus ahorros con cada paso.';

  @override
  String get onboardingPage2Title => 'Alcanza Tus Metas';

  @override
  String get onboardingPage2Description =>
      'Crea metas financieras, desde un nuevo gadget hasta el viaje de tus sueños, y sigue tu progreso.';

  @override
  String get onboardingPage3Title => 'Mantente en Camino';

  @override
  String get onboardingPage3Description =>
      'Monitorea tus gastos, ingresos y ahorros, todo en un simple panel.';

  @override
  String get paywallCouldNotLoadPlans =>
      'No se pudieron cargar los planes.\nPor favor, inténtalo de nuevo más tarde.';

  @override
  String get paywallChooseYourPlan => 'Elige Tu Plan';

  @override
  String get paywallInvestInFinancialFreedom =>
      'Invierte en tu libertad financiera hoy';

  @override
  String paywallPricePerDay(Object price) {
    return '$price/día';
  }

  @override
  String paywallSaveAmount(Object amount) {
    return 'Ahorra $amount';
  }

  @override
  String get paywallEverythingIncluded => 'Todo incluido:';

  @override
  String get paywallPersonalizedBudgetInsights =>
      'Información personalizada del presupuesto';

  @override
  String get paywallDailyProgressTracking => 'Seguimiento diario del progreso';

  @override
  String get paywallExpenseManagementTools =>
      'Herramientas de gestión de gastos';

  @override
  String get paywallFinancialHealthTimeline =>
      'Cronología de la salud financiera';

  @override
  String get paywallExpertGuidanceTips => 'Consejos y guía de expertos';

  @override
  String get paywallCommunitySupportAccess => 'Acceso a soporte comunitario';

  @override
  String get paywallSaveYourFinances => 'Salva tus finanzas y tu futuro';

  @override
  String get paywallAverageUserSaves =>
      'El usuario promedio ahorra ~£2,500 al año presupuestando eficazmente';

  @override
  String get paywallSubscribeYourPlan => 'Suscribir Tu Plan';

  @override
  String get paywallPleaseSelectPlan => 'Por favor selecciona un plan.';

  @override
  String get paywallSubscriptionActivated =>
      '¡Suscripción activada! Ahora tienes acceso a las funciones premium.';

  @override
  String paywallFailedToPurchase(Object message) {
    return 'Error al comprar: $message';
  }

  @override
  String paywallUnexpectedError(Object error) {
    return 'Ocurrió un error inesperado: $error';
  }

  @override
  String get paywallRestorePurchases => 'Restaurar compras';

  @override
  String get paywallManageSubscription => 'Administrar suscripción';

  @override
  String get paywallPurchasesRestoredSuccessfully =>
      '¡Compras restauradas exitosamente!';

  @override
  String get paywallNoActiveSubscriptionFound =>
      'No se encontró ninguna suscripción activa. Ahora estás en el plan gratuito.';

  @override
  String get paywallPerMonth => 'por mes';

  @override
  String get paywallPerYear => 'por año';

  @override
  String get paywallBestValue => 'Mejor Valor';

  @override
  String get paywallMostPopular => 'Más Popular';

  @override
  String get mainScreenHome => 'Inicio';

  @override
  String get mainScreenBudget => 'Presupuesto';

  @override
  String get mainScreenBalance => 'Saldo';

  @override
  String get mainScreenGoals => 'Metas';

  @override
  String get mainScreenPersonal => 'Personal';

  @override
  String get mainScreenIncome => 'Ingresos';

  @override
  String get mainScreenExpense => 'Gastos';

  @override
  String get balanceTitle => 'Saldo';

  @override
  String get balanceAddAccount => 'Añadir Cuenta';

  @override
  String get balanceMyAccounts => 'MIS CUENTAS';

  @override
  String get balanceVacation => 'VACACIONES';

  @override
  String get balanceAccountBalance => 'Saldo de Cuenta';

  @override
  String get balanceNoAccountsFound => 'No se encontraron cuentas.';

  @override
  String get balanceNoAccountsCreated => 'No hay cuentas creadas';

  @override
  String get balanceCreateFirstAccount =>
      'Crea tu primera cuenta para empezar a seguir tus saldos';

  @override
  String get balanceCreateFirstAccountFinances =>
      'Crea tu primera cuenta para empezar a seguir tus finanzas';

  @override
  String get balanceNoVacationsYet => 'Aún no hay vacaciones';

  @override
  String get balanceCreateFirstVacation =>
      'Crea tu primera cuenta de vacaciones para empezar a planificar tus viajes';

  @override
  String get balanceSingleAccountView => 'Vista de Cuenta Única';

  @override
  String get balanceAddMoreAccounts => 'Añade más cuentas para ver gráficos';

  @override
  String get balanceNoAccountsForCurrency =>
      'No se encontraron cuentas para la moneda seleccionada';

  @override
  String balanceCreditLimit(Object value) {
    return 'Límite de Crédito: $value';
  }

  @override
  String balanceBalanceLimit(Object value) {
    return 'Límite de Saldo: $value';
  }

  @override
  String get budgetTitle => 'Presupuesto';

  @override
  String get budgetAddBudget => 'Añadir Presupuesto';

  @override
  String get budgetDaily => 'Diario';

  @override
  String get budgetWeekly => 'Semanal';

  @override
  String get budgetMonthly => 'Mensual';

  @override
  String get budgetSelectWeek => 'Seleccionar Semana';

  @override
  String get budgetSelectDate => 'Seleccionar Fecha';

  @override
  String get budgetSelectDay => 'Seleccionar Día';

  @override
  String get budgetCancel => 'Cancelar';

  @override
  String get budgetApply => 'Aplicar';

  @override
  String get budgetTotalSpending => 'Gasto Total';

  @override
  String get budgetCategoryBreakdown => 'Desglose por Categoría';

  @override
  String get budgetViewAll => 'Ver Todo';

  @override
  String get budgetBudgets => 'Presupuestos';

  @override
  String get budgetNoBudgetCreated => 'No hay presupuesto creado';

  @override
  String get budgetStartCreatingBudget =>
      'Empieza creando un presupuesto para ver tu desglose de gastos aquí.';

  @override
  String get budgetSetSpendingLimit => 'Establecer límite de gasto';

  @override
  String get budgetEnterLimitAmount => 'Ingresar monto límite';

  @override
  String get budgetSave => 'Guardar';

  @override
  String get budgetEnterValidNumber => 'Ingresa un número válido';

  @override
  String get budgetLimitSaved => 'Límite de presupuesto guardado';

  @override
  String get budgetCreated => 'Presupuesto creado';

  @override
  String get budgetTransactions => 'transacciones';

  @override
  String budgetOverBudget(Object amount) {
    return '$amount sobre el presupuesto';
  }

  @override
  String budgetRemaining(Object amount) {
    return '$amount restante';
  }

  @override
  String get homeNoMoreTransactions => 'No hay más transacciones';

  @override
  String get homeErrorLoadingMoreTransactions =>
      'Error al cargar más transacciones';

  @override
  String get homeRetry => 'Reintentar';

  @override
  String get homeErrorLoadingData => 'Error al cargar datos';

  @override
  String get homeNoTransactionsRecorded => 'No hay transacciones registradas';

  @override
  String get homeStartAddingTransactions =>
      'Empieza añadiendo transacciones para ver tu desglose de gastos aquí.';

  @override
  String get homeCurrencyChange => 'Cambio de Moneda';

  @override
  String get homeCurrencyChangeMessage =>
      'Cambiar tu moneda convertirá todos los montos existentes. Esta acción no se puede deshacer. ¿Deseas continuar?';

  @override
  String get homeNo => 'No';

  @override
  String get homeYes => 'Sí';

  @override
  String get homeVacationBudgetBreakdown =>
      'Desglose del Presupuesto de Vacaciones';

  @override
  String get homeBalanceBreakdown => 'Desglose del Saldo';

  @override
  String get homeClose => 'Cerrar';

  @override
  String get transactionPickColor => 'Elige un color';

  @override
  String get transactionSelectDate => 'Seleccionar Fecha';

  @override
  String get transactionCancel => 'Cancelar';

  @override
  String get transactionApply => 'Aplicar';

  @override
  String get transactionAmount => 'Monto';

  @override
  String get transactionSelect => 'Seleccionar';

  @override
  String get transactionPaid => 'Pagado';

  @override
  String get transactionAddTransaction => 'Añadir Transacción';

  @override
  String get transactionEditTransaction => 'Editar Transacción';

  @override
  String get transactionIncome => 'Ingreso';

  @override
  String get transactionExpense => 'Gasto';

  @override
  String get transactionDescription => 'Descripción';

  @override
  String get transactionCategory => 'Categoría';

  @override
  String get transactionAccount => 'Cuenta';

  @override
  String get transactionDate => 'Fecha';

  @override
  String get transactionSave => 'Guardar';

  @override
  String get transactionDelete => 'Eliminar';

  @override
  String get transactionSuccess => 'Transacción guardada exitosamente';

  @override
  String get transactionError => 'Error al guardar la transacción';

  @override
  String get transactionDeleteConfirm =>
      '¿Estás seguro de que quieres eliminar esta transacción?';

  @override
  String get transactionDeleteSuccess => 'Transacción eliminada exitosamente';

  @override
  String get goalsTitle => 'Metas';

  @override
  String get goalsAddGoal => 'Añadir Meta';

  @override
  String get goalsNoGoalsCreated => 'No hay metas creadas';

  @override
  String get goalsStartCreatingGoal =>
      'Empieza creando una meta para seguir tu progreso financiero';

  @override
  String get goalsCreateGoal => 'Crear Meta';

  @override
  String get goalsEditGoal => 'Editar Meta';

  @override
  String get goalsGoalName => 'Nombre de la Meta';

  @override
  String get goalsTargetAmount => 'Monto Objetivo';

  @override
  String get goalsCurrentAmount => 'Monto Actual';

  @override
  String get goalsDeadline => 'Fecha Límite';

  @override
  String get goalsDescription => 'Descripción';

  @override
  String get goalsSave => 'Guardar';

  @override
  String get goalsCancel => 'Cancelar';

  @override
  String get goalsDelete => 'Eliminar';

  @override
  String get goalsGoalCreated => 'Meta creada exitosamente';

  @override
  String get goalsGoalUpdated => 'Meta actualizada exitosamente';

  @override
  String get goalsGoalDeleted => 'Meta eliminada exitosamente';

  @override
  String get goalsErrorSaving => 'Error al guardar la meta';

  @override
  String get goalsDeleteConfirm =>
      '¿Estás seguro de que quieres eliminar esta meta?';

  @override
  String get goalsProgress => 'Progreso';

  @override
  String get goalsCompleted => 'Completada';

  @override
  String get goalsInProgress => 'En Progreso';

  @override
  String get goalsNotStarted => 'No Iniciada';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profilePremiumActive => 'Premium Activo';

  @override
  String get profilePremiumDescription =>
      'Tienes acceso a todas las funciones premium';

  @override
  String get profileFreePlan => 'Plan Gratuito';

  @override
  String get profileUpgradeDescription =>
      'Actualiza a premium para funciones avanzadas';

  @override
  String profileRenewalDate(Object date) {
    return 'Se renueva el $date';
  }

  @override
  String profileExpiresOn(Object date) {
    return 'Expira el $date';
  }

  @override
  String profileErrorSigningOut(Object error) {
    return 'Error al cerrar sesión: $error';
  }

  @override
  String get profileUserNotFound => 'Usuario no encontrado';

  @override
  String get profileEditDisplayName => 'Editar nombre de usuario';

  @override
  String get profileCancel => 'Cancelar';

  @override
  String get profileSave => 'Guardar';

  @override
  String get profileDisplayNameUpdated =>
      'Nombre de usuario actualizado exitosamente';

  @override
  String get profileErrorUpdatingName =>
      'Error al actualizar el nombre de usuario';

  @override
  String get profileManageSubscription => 'Administrar suscripción';

  @override
  String get profileRestorePurchases => 'Restaurar compras';

  @override
  String get profileRefreshStatus => 'Actualizar estado';

  @override
  String get profileSubscriptionRefreshed =>
      'Estado de la suscripción actualizado';

  @override
  String get profileSignOut => 'Cerrar Sesión';

  @override
  String get profileSignOutConfirm =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get profileCurrencyRates => 'Tasas de Cambio';

  @override
  String get profileCategories => 'Categorías';

  @override
  String get profileFeedback => 'Comentarios';

  @override
  String get profileExportData => 'Exportar Datos';

  @override
  String get profileSettings => 'Configuración';

  @override
  String get profileAccount => 'Cuenta';

  @override
  String get profileDisplayName => 'Nombre de Usuario';

  @override
  String get profileEmail => 'Correo electrónico';

  @override
  String get profileSubscription => 'Suscripción';

  @override
  String get profileVersion => 'Versión';

  @override
  String get personalTitle => 'Personal';

  @override
  String get personalSubscriptions => 'Suscripciones';

  @override
  String get personalLent => 'Prestado';

  @override
  String get personalBorrowed => 'Recibido';

  @override
  String get personalAddSubscription => 'Añadir Suscripción';

  @override
  String get personalAddLent => 'Añadir Préstamo';

  @override
  String get personalAddBorrowed => 'Añadir Deuda';

  @override
  String get personalNoSubscriptions => 'No se encontraron suscripciones';

  @override
  String get personalNoLent => 'No se encontraron préstamos';

  @override
  String get personalNoBorrowed => 'No se encontraron deudas';

  @override
  String get personalStartAddingSubscription =>
      'Empieza añadiendo una suscripción para seguir tus pagos recurrentes';

  @override
  String get personalStartAddingLent =>
      'Empieza añadiendo préstamos para seguir el dinero que has prestado';

  @override
  String get personalStartAddingBorrowed =>
      'Empieza añadiendo deudas para seguir el dinero que has pedido prestado';

  @override
  String get personalEdit => 'Editar';

  @override
  String get personalDelete => 'Eliminar';

  @override
  String get personalMarkAsPaid => 'Marcar como Pagado';

  @override
  String get personalMarkAsUnpaid => 'Marcar como No Pagado';

  @override
  String get personalAmount => 'Monto';

  @override
  String get personalDescription => 'Descripción';

  @override
  String get personalDueDate => 'Fecha de Vencimiento';

  @override
  String get personalRecurring => 'Recurrente';

  @override
  String get personalOneTime => 'Una Sola Vez';

  @override
  String get personalMonthly => 'Mensual';

  @override
  String get personalYearly => 'Anual';

  @override
  String get personalWeekly => 'Semanal';

  @override
  String get personalDaily => 'Diario';

  @override
  String get personalName => 'Nombre';

  @override
  String get personalCategory => 'Categoría';

  @override
  String get personalNotes => 'Notas';

  @override
  String get personalSave => 'Guardar';

  @override
  String get personalCancel => 'Cancelar';

  @override
  String get personalDeleteConfirm =>
      '¿Estás seguro de que quieres eliminar este ítem?';

  @override
  String get personalItemSaved => 'Ítem guardado exitosamente';

  @override
  String get personalItemDeleted => 'Ítem eliminado exitosamente';

  @override
  String get personalErrorSaving => 'Error al guardar el ítem';

  @override
  String get personalErrorDeleting => 'Error al eliminar el ítem';

  @override
  String get analyticsTitle => 'Analíticas';

  @override
  String get analyticsOverview => 'Resumen';

  @override
  String get analyticsIncome => 'Ingresos';

  @override
  String get analyticsExpenses => 'Gastos';

  @override
  String get analyticsSavings => 'Ahorros';

  @override
  String get analyticsCategories => 'Categorías';

  @override
  String get analyticsTrends => 'Tendencias';

  @override
  String get analyticsMonthly => 'Mensual';

  @override
  String get analyticsWeekly => 'Semanal';

  @override
  String get analyticsDaily => 'Diario';

  @override
  String get analyticsYearly => 'Anual';

  @override
  String get analyticsNoData => 'No hay datos disponibles';

  @override
  String get analyticsStartTracking =>
      'Empieza a seguir tus finanzas para ver analíticas aquí';

  @override
  String get analyticsTotalIncome => 'Ingresos Totales';

  @override
  String get analyticsTotalExpenses => 'Gastos Totales';

  @override
  String get analyticsNetSavings => 'Ahorros Netos';

  @override
  String get analyticsTopCategories => 'Categorías Principales';

  @override
  String get analyticsSpendingTrends => 'Tendencias de Gasto';

  @override
  String get analyticsIncomeTrends => 'Tendencias de Ingresos';

  @override
  String get analyticsSavingsRate => 'Tasa de Ahorro';

  @override
  String get analyticsAverageDaily => 'Promedio Diario';

  @override
  String get analyticsAverageWeekly => 'Promedio Semanal';

  @override
  String get analyticsAverageMonthly => 'Promedio Mensual';

  @override
  String get analyticsSelectPeriod => 'Seleccionar Período';

  @override
  String get analyticsExportData => 'Exportar Datos';

  @override
  String get analyticsRefresh => 'Actualizar';

  @override
  String get analyticsErrorLoading => 'Error al cargar las analíticas';

  @override
  String get analyticsRetry => 'Reintentar';

  @override
  String get goalsSelectColor => 'Seleccionar Color';

  @override
  String get goalsMore => 'Más';

  @override
  String get goalsName => 'Nombre de la Meta';

  @override
  String get goalsColor => 'Color';

  @override
  String get goalsNameRequired => 'El nombre de la meta es obligatorio';

  @override
  String get goalsAmountRequired => 'El monto objetivo es obligatorio';

  @override
  String get goalsAmountMustBePositive =>
      'El monto objetivo debe ser mayor que 0';

  @override
  String get goalsDeadlineRequired => 'La fecha límite es obligatoria';

  @override
  String get goalsDeadlineMustBeFuture =>
      'La fecha límite debe ser en el futuro';

  @override
  String get goalsNameAlreadyExists => 'Ya existe una meta con este nombre';

  @override
  String goalsErrorCreating(Object error) {
    return 'Error al crear la meta: $error';
  }

  @override
  String goalsErrorUpdating(Object error) {
    return 'Error al actualizar la meta: $error';
  }

  @override
  String goalsErrorDeleting(Object error) {
    return 'Error al eliminar la meta: $error';
  }

  @override
  String get expenseDetailTitle => 'Detalle del Gasto';

  @override
  String get expenseDetailEdit => 'Editar';

  @override
  String get expenseDetailDelete => 'Eliminar';

  @override
  String get expenseDetailAmount => 'Monto';

  @override
  String get expenseDetailCategory => 'Categoría';

  @override
  String get expenseDetailAccount => 'Cuenta';

  @override
  String get expenseDetailDate => 'Fecha';

  @override
  String get expenseDetailDescription => 'Descripción';

  @override
  String get expenseDetailNotes => 'Notas';

  @override
  String get expenseDetailSave => 'Guardar';

  @override
  String get expenseDetailCancel => 'Cancelar';

  @override
  String get expenseDetailDeleteConfirm =>
      '¿Estás seguro de que quieres eliminar este gasto?';

  @override
  String get expenseDetailUpdated => 'Gasto actualizado exitosamente';

  @override
  String get expenseDetailDeleted => 'Gasto eliminado exitosamente';

  @override
  String get expenseDetailErrorSaving => 'Error al guardar el gasto';

  @override
  String get expenseDetailErrorDeleting => 'Error al eliminar el gasto';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get calendarSelectDate => 'Seleccionar Fecha';

  @override
  String get calendarToday => 'Hoy';

  @override
  String get calendarThisWeek => 'Esta Semana';

  @override
  String get calendarThisMonth => 'Este Mes';

  @override
  String get calendarThisYear => 'Este Año';

  @override
  String get calendarNoTransactions => 'No hay transacciones en esta fecha';

  @override
  String get calendarStartAddingTransactions =>
      'Empieza a añadir transacciones para verlas en el calendario';

  @override
  String get vacationDialogTitle => 'Modo Vacaciones';

  @override
  String get vacationDialogEnable => 'Activar Modo Vacaciones';

  @override
  String get vacationDialogDisable => 'Desactivar Modo Vacaciones';

  @override
  String get vacationDialogDescription =>
      'El modo vacaciones te ayuda a seguir los gastos durante viajes y festivos';

  @override
  String get vacationDialogCancel => 'Cancelar';

  @override
  String get vacationDialogConfirm => 'Confirmar';

  @override
  String get vacationDialogEnabled => 'Modo vacaciones activado';

  @override
  String get vacationDialogDisabled => 'Modo vacaciones desactivado';

  @override
  String get balanceDetailTitle => 'Detalle de la Cuenta';

  @override
  String get balanceDetailEdit => 'Editar';

  @override
  String get balanceDetailDelete => 'Eliminar';

  @override
  String get balanceDetailTransactions => 'Transacciones';

  @override
  String get balanceDetailBalance => 'Saldo';

  @override
  String get balanceDetailCreditLimit => 'Límite de Crédito';

  @override
  String get balanceDetailBalanceLimit => 'Límite de Saldo';

  @override
  String get balanceDetailCurrency => 'Moneda';

  @override
  String get balanceDetailAccountType => 'Tipo de Cuenta';

  @override
  String get balanceDetailAccountName => 'Nombre de la Cuenta';

  @override
  String get balanceDetailSave => 'Guardar';

  @override
  String get balanceDetailCancel => 'Cancelar';

  @override
  String get balanceDetailDeleteConfirm =>
      '¿Estás seguro de que quieres eliminar esta cuenta?';

  @override
  String get balanceDetailUpdated => 'Cuenta actualizada exitosamente';

  @override
  String get balanceDetailDeleted => 'Cuenta eliminada exitosamente';

  @override
  String get balanceDetailErrorSaving => 'Error al guardar la cuenta';

  @override
  String get balanceDetailErrorDeleting => 'Error al eliminar la cuenta';

  @override
  String get addAccountTitle => 'Añadir Cuenta';

  @override
  String get addAccountEditTitle => 'Editar Cuenta';

  @override
  String get addAccountName => 'Nombre de la Cuenta';

  @override
  String get addAccountType => 'Tipo de Cuenta';

  @override
  String get addAccountCurrency => 'Moneda';

  @override
  String get addAccountInitialBalance => 'Saldo Inicial';

  @override
  String get addAccountCreditLimit => 'Límite de Crédito';

  @override
  String get addAccountBalanceLimit => 'Límite de Saldo';

  @override
  String get addAccountColor => 'Color';

  @override
  String get addAccountIcon => 'Icono';

  @override
  String get addAccountSave => 'Guardar';

  @override
  String get addAccountCancel => 'Cancelar';

  @override
  String get addAccountCreated => 'Cuenta creada exitosamente';

  @override
  String get addAccountUpdated => 'Cuenta actualizada exitosamente';

  @override
  String get addAccountErrorSaving => 'Error al guardar la cuenta';

  @override
  String get addAccountNameRequired => 'El nombre de la cuenta es obligatorio';

  @override
  String get addAccountTypeRequired => 'El tipo de cuenta es obligatorio';

  @override
  String get addAccountCurrencyRequired => 'La moneda es obligatoria';

  @override
  String get budgetDetailTitle => 'Detalle del Presupuesto';

  @override
  String get budgetDetailEdit => 'Editar';

  @override
  String get budgetDetailDelete => 'Eliminar';

  @override
  String get budgetDetailSpending => 'Gasto';

  @override
  String get budgetDetailLimit => 'Límite';

  @override
  String get budgetDetailRemaining => 'Restante';

  @override
  String get budgetDetailOverBudget => 'Sobre el Presupuesto';

  @override
  String get budgetDetailCategories => 'Categorías';

  @override
  String get budgetDetailTransactions => 'Transacciones';

  @override
  String get budgetDetailSave => 'Guardar';

  @override
  String get budgetDetailCancel => 'Cancelar';

  @override
  String get budgetDetailDeleteConfirm =>
      '¿Estás seguro de que quieres eliminar este presupuesto?';

  @override
  String get budgetDetailUpdated => 'Presupuesto actualizado exitosamente';

  @override
  String get budgetDetailDeleted => 'Presupuesto eliminado exitosamente';

  @override
  String get budgetDetailErrorSaving => 'Error al guardar el presupuesto';

  @override
  String get budgetDetailErrorDeleting => 'Error al eliminar el presupuesto';

  @override
  String get addBudgetTitle => 'Añadir Presupuesto';

  @override
  String get addBudgetEditTitle => 'Editar Presupuesto';

  @override
  String get addBudgetName => 'Nombre del Presupuesto';

  @override
  String get addBudgetType => 'Tipo de Presupuesto';

  @override
  String get addBudgetAmount => 'Monto';

  @override
  String get addBudgetCurrency => 'Moneda';

  @override
  String get addBudgetPeriod => 'Período';

  @override
  String get addBudgetCategories => 'Categorías';

  @override
  String get addBudgetColor => 'Color';

  @override
  String get addBudgetSave => 'Guardar';

  @override
  String get addBudgetSaveBudget => 'Guardar Presupuesto';

  @override
  String get addBudgetCancel => 'Cancelar';

  @override
  String get addBudgetCreated => 'Presupuesto creado exitosamente';

  @override
  String get addBudgetUpdated => 'Presupuesto actualizado exitosamente';

  @override
  String get addBudgetErrorSaving => 'Error al guardar el presupuesto';

  @override
  String get addBudgetNameRequired =>
      'El nombre del presupuesto es obligatorio';

  @override
  String get addBudgetAmountRequired =>
      'El monto del presupuesto es obligatorio';

  @override
  String get addBudgetAmountMustBePositive =>
      'El monto del presupuesto debe ser mayor que 0';

  @override
  String get addBudgetCategoryRequired => 'Por favor selecciona una categoría';

  @override
  String get budgetDetailNoBudgetToDelete =>
      'No hay presupuesto para eliminar. Esto es solo un marcador de posición para transacciones.';

  @override
  String get personalItemDetails => 'Detalles del Ítem';

  @override
  String get personalStartDateRequired =>
      'Por favor selecciona una fecha de inicio';

  @override
  String get profileMainCurrency => 'MONEDA PRINCIPAL';

  @override
  String get profileFeedbackThankYou => '¡Gracias por tus comentarios!';

  @override
  String get profileFeedbackEmailError =>
      'No se pudo abrir el cliente de correo.';

  @override
  String get feedbackModalTitle => '¿Disfrutando la app?';

  @override
  String get feedbackModalDescription =>
      'Tus comentarios nos mantienen motivados y nos ayudan a mejorar.';

  @override
  String get goalNameAlreadyExistsSnackbar =>
      'Ya existe una meta con este nombre';

  @override
  String get lentSelectBothDates =>
      'Por favor selecciona ambas fechas (fecha y fecha de vencimiento)';

  @override
  String get lentDueDateBeforeLentDate =>
      'La fecha de vencimiento no puede ser anterior a la fecha del préstamo';

  @override
  String get lentItemAddedSuccessfully => 'Ítem prestado añadido exitosamente';

  @override
  String lentItemError(Object error) {
    return 'Error: $error';
  }

  @override
  String get borrowedSelectBothDates =>
      'Por favor selecciona ambas fechas (fecha y fecha de vencimiento)';

  @override
  String get borrowedDueDateBeforeBorrowedDate =>
      'La fecha de vencimiento no puede ser anterior a la fecha de la deuda';

  @override
  String get borrowedItemAddedSuccessfully =>
      'Ítem de deuda añadido exitosamente';

  @override
  String borrowedItemError(Object error) {
    return 'Error: $error';
  }

  @override
  String get subscriptionCreatedSuccessfully =>
      'Suscripción creada exitosamente';

  @override
  String subscriptionError(Object error) {
    return 'Error: $error';
  }

  @override
  String get paymentMarkedSuccessfully => 'Pago marcado exitosamente';

  @override
  String get subscriptionContinued => 'Suscripción continuada exitosamente';

  @override
  String get subscriptionPaused => 'Suscripción pausada exitosamente';

  @override
  String get itemMarkedAsReturnedSuccessfully =>
      'Ítem marcado como devuelto exitosamente';

  @override
  String get itemDeletedSuccessfully => 'Ítem eliminado exitosamente';

  @override
  String get failedToDeleteBudget => 'Error al eliminar el presupuesto';

  @override
  String get failedToDeleteGoal => 'Error al eliminar la meta';

  @override
  String failedToSaveTransaction(Object error) {
    return 'Error al guardar la transacción: $error';
  }

  @override
  String get failedToReorderCategories =>
      'Error al reordenar las categorías. Revirtiendo cambios.';

  @override
  String get categoryAddedSuccessfully => 'Categoría añadida exitosamente';

  @override
  String failedToAddCategory(Object error) {
    return 'Error al añadir la categoría: $error';
  }

  @override
  String errorCreatingGoal(Object error) {
    return 'Error al crear la meta: $error';
  }

  @override
  String get hintName => 'Nombre';

  @override
  String get hintDescription => 'Descripción';

  @override
  String get hintSelectDate => 'Seleccionar Fecha';

  @override
  String get hintSelectDueDate => 'Seleccionar Fecha de Vencimiento';

  @override
  String get hintSelectCategory => 'Seleccionar Categoría';

  @override
  String get hintSelectAccount => 'Seleccionar Cuenta';

  @override
  String get hintSelectGoal => 'Seleccionar Meta';

  @override
  String get hintNotes => 'Notas';

  @override
  String get hintSelectColor => 'Seleccionar Color';

  @override
  String get hintEnterCategoryName => 'Ingresar nombre de categoría';

  @override
  String get hintSelectType => 'Seleccionar Tipo';

  @override
  String get hintWriteThoughts => 'Escribe tus pensamientos aquí......';

  @override
  String get hintEnterDisplayName => 'Ingresar nombre de usuario';

  @override
  String get hintSelectBudgetType => 'Seleccionar Tipo de Presupuesto';

  @override
  String get hintSelectAccountType => 'Seleccionar Tipo de Cuenta';

  @override
  String get hintEnterName => 'Ingresar Nombre';

  @override
  String get hintSelectIcon => 'Seleccionar Icono';

  @override
  String get hintSelect => 'Seleccionar';

  @override
  String get hintAmountPlaceholder => '0.00';

  @override
  String get labelValue => 'Valor';

  @override
  String get labelName => 'Nombre';

  @override
  String get labelDescription => 'Descripción';

  @override
  String get labelCategory => 'Categoría';

  @override
  String get labelDate => 'Fecha';

  @override
  String get labelDueDate => 'Fecha de Vencimiento';

  @override
  String get labelColor => 'Color';

  @override
  String get labelNotes => 'Notas';

  @override
  String get labelAccount => 'Cuenta';

  @override
  String get labelMore => 'Más';

  @override
  String get labelHome => 'Inicio';

  @override
  String get titlePickColor => 'Elige un color';

  @override
  String get titleAddLentItem => 'Añadir Ítem Prestado';

  @override
  String get titleAddBorrowedItem => 'Añadir Ítem de Deuda';

  @override
  String get titleSelectCategory => 'Seleccionar Categoría';

  @override
  String get titleSelectAccount => 'Seleccionar Cuenta';

  @override
  String get titleSelectGoal => 'Seleccionar Meta';

  @override
  String get titleSelectType => 'Seleccionar Tipo';

  @override
  String get titleSelectAccountType => 'Seleccionar Tipo de Cuenta';

  @override
  String get titleSelectBudgetType => 'Seleccionar Tipo de Presupuesto';

  @override
  String get validationNameRequired => 'El nombre es obligatorio';

  @override
  String get validationAmountRequired => 'El monto es obligatorio';

  @override
  String get validationPleaseEnterValidNumber =>
      'Por favor ingresa un número válido';

  @override
  String get validationPleaseSelectIcon => 'Por favor selecciona un icono';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonAdd => 'Añadir';

  @override
  String get buttonSave => 'Guardar';

  @override
  String get switchAddProgress => 'Añadir Progreso';

  @override
  String get pickColor => 'Elige un color';

  @override
  String get name => 'Nombre';

  @override
  String get itemName => 'Nombre del Ítem';

  @override
  String get account => 'Cuenta';

  @override
  String get selectIcon => 'Por favor selecciona un icono';

  @override
  String get value => 'Valor';

  @override
  String get hintAmount => '0.00';

  @override
  String get hintItemName => 'Nombre del Ítem';

  @override
  String get amountRequired => 'El monto es obligatorio';

  @override
  String get validNumber => 'Por favor ingresa un número válido';

  @override
  String get category => 'Categoría';

  @override
  String get date => 'Fecha';

  @override
  String get dueDate => 'Fecha de Vencimiento';

  @override
  String get color => 'Color';

  @override
  String get notes => 'Notas';

  @override
  String get selectColor => 'Seleccionar Color';

  @override
  String get more => 'Más';

  @override
  String get addLentItem => 'Añadir Ítem Prestado';

  @override
  String get addBorrowedItem => 'Añadir Ítem de Deuda';

  @override
  String get cancel => 'Cancelar';

  @override
  String get add => 'Añadir';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get buttonOk => 'Aceptar';

  @override
  String get vacationNoAccountsAvailable =>
      'No hay cuentas de vacaciones disponibles.';

  @override
  String get exportFormat => 'Formato';

  @override
  String get exportOptions => 'Opciones';

  @override
  String get exportAccountData => 'Exportar Datos de Cuenta';

  @override
  String get exportGoalsData => 'Exportar Datos de Metas';

  @override
  String get exportCurrentMonth => 'Mes Actual';

  @override
  String get exportLast30Days => 'Últimos 30 Días';

  @override
  String get exportLast90Days => 'Últimos 90 Días';

  @override
  String get exportLast365Days => 'Últimos 365 Días';

  @override
  String get exportCsv => 'CSV';

  @override
  String get exportJson => 'JSON';

  @override
  String get exportImportInstructions =>
      'Puedes importar tus datos desde un archivo CSV a la app.';

  @override
  String get exportInstructions1 =>
      'Guarda el archivo de ejemplo para ver el formato de datos requerido;';

  @override
  String get exportInstructions2 =>
      'Formatea tus datos según la plantilla. Asegúrate de que las columnas, su orden y nombres sean exactamente iguales a los de la plantilla. Los nombres de las columnas deben estar en inglés;';

  @override
  String get exportInstructions3 =>
      'Presiona Importar y selecciona tu archivo;';

  @override
  String get exportInstructions4 =>
      'Elige si deseas sobrescribir los datos existentes o añadir los datos importados a los datos existentes. Al elegir la opción de sobrescribir, los datos existentes se eliminarán permanentemente;';

  @override
  String get exportButtonExport => 'Exportar';

  @override
  String get exportButtonImport => 'Importar';

  @override
  String get exportTabExport => 'Exportar';

  @override
  String get exportTabImport => 'Importar';

  @override
  String get enableVacationMode => 'Activar Modo Vacaciones';

  @override
  String get addProgress => 'Añadir Progreso';

  @override
  String get pleaseEnterValidNumber => 'Por favor ingresa un número válido';

  @override
  String get pleaseSelectCategory => 'Por favor selecciona una categoría';

  @override
  String get pleaseSelectCurrency => 'Por favor selecciona una moneda';

  @override
  String get pleaseSelectAccount => 'Por favor selecciona una cuenta';

  @override
  String get pleaseSelectDate => 'Por favor selecciona una fecha';

  @override
  String get pleaseSelectIcon => 'Por favor selecciona un icono';

  @override
  String get deleteCategory => 'Eliminar Categoría';

  @override
  String get markAsReturned => 'Marcar como Devuelto';

  @override
  String get markPayment => 'Marcar Pago';

  @override
  String get markPaid => 'Marcar como Pagado';

  @override
  String get deleteItem => 'Eliminar Ítem';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get deleteAllAssociatedTransactions =>
      'Eliminar todas las transacciones asociadas';

  @override
  String get normalMode => 'Modo Normal';

  @override
  String get changeCurrency => 'Cambiar Moneda';

  @override
  String get vacationModeDialog => 'Diálogo de Modo Vacaciones';

  @override
  String get categoryAndTransactionsDeleted =>
      'Categoría y transacciones asociadas eliminadas exitosamente';

  @override
  String get select => 'Seleccionar';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get yourData => 'Tus Datos';

  @override
  String get profileMenuAccount => 'CUENTA';

  @override
  String get profileMenuCurrency => 'Moneda';

  @override
  String get profileSectionLegal => 'LEGAL';

  @override
  String get profileTermsConditions => 'Términos y Condiciones';

  @override
  String get profilePrivacyPolicy => 'Política de Privacidad';

  @override
  String get profileSectionSupport => 'SOPORTE';

  @override
  String get profileHelpSupport => 'Ayuda y Soporte';

  @override
  String get profileSectionDanger => 'ZONA DE PELIGRO';

  @override
  String get currencyPageChange => 'CAMBIAR';

  @override
  String get addTransactionNotes => 'Notas';

  @override
  String get addTransactionMore => 'Más';

  @override
  String get addTransactionDate => 'Fecha';

  @override
  String get addTransactionTime => 'Hora';

  @override
  String get addTransactionPaid => 'Pagado';

  @override
  String get addTransactionColor => 'Color';

  @override
  String get addTransactionCancel => 'Cancelar';

  @override
  String get addTransactionCreate => 'Crear';

  @override
  String get addTransactionUpdate => 'Actualizar';

  @override
  String get addBudgetLimitAmount => 'Monto Límite';

  @override
  String get addBudgetSelectCategory => 'Seleccionar Categoría';

  @override
  String get addBudgetBudgetType => 'Tipo de Presupuesto';

  @override
  String get addBudgetRecurring => 'Presupuesto Recurrente';

  @override
  String get addBudgetRecurringSubtitle =>
      'Renovar automáticamente este presupuesto cada período';

  @override
  String get addBudgetRecurringDailySubtitle => 'Se aplica a todos los días';

  @override
  String get addBudgetRecurringPremiumSubtitle =>
      'Función Premium - Suscríbete para activar';

  @override
  String get addBudget => 'Añadir Presupuesto';

  @override
  String get addAccountTransactionLimit => 'Límite de Transacción';

  @override
  String get addAccountAccountType => 'Tipo de Cuenta';

  @override
  String get addAccountAdd => 'Añadir';

  @override
  String get addAccountBalance => 'Saldo';

  @override
  String get addAccountCredit => 'Crédito';

  @override
  String get homeIncomeCard => 'Ingresos';

  @override
  String get homeExpenseCard => 'Gastos';

  @override
  String get homeTotalBudget => 'Presupuesto Total';

  @override
  String get balanceDetailInitialBalance => 'Saldo Inicial';

  @override
  String get balanceDetailCurrentBalance => 'Saldo Actual';

  @override
  String get expenseDetailTotal => 'Total';

  @override
  String get expenseDetailAccumulatedAmount => 'Monto Acumulado';

  @override
  String get expenseDetailPaidStatus => 'PAGADO/NO PAGADO';

  @override
  String get expenseDetailVacation => 'Vacaciones';

  @override
  String get expenseDetailMarkPaid => 'Marcar como Pagado';

  @override
  String get goalsScreenPending => 'Metas Pendientes';

  @override
  String get goalsScreenFulfilled => 'Metas Cumplidas';

  @override
  String get createGoalTitle => 'Crear una meta pendiente';

  @override
  String get createGoalAmount => 'Monto';

  @override
  String get createGoalName => 'Nombre';

  @override
  String get createGoalCurrency => 'Moneda';

  @override
  String get createGoalMore => 'Más';

  @override
  String get createGoalNotes => 'Notas';

  @override
  String get createGoalDate => 'Fecha';

  @override
  String get createGoalColor => 'Color';

  @override
  String get personalScreenSubscriptions => 'Suscripciones';

  @override
  String get personalScreenBorrowed => 'Recibido';

  @override
  String get personalScreenLent => 'Prestado';

  @override
  String get personalScreenTotal => 'Total';

  @override
  String get personalScreenActive => 'Activo';

  @override
  String get personalScreenNoSubscriptions => 'Aún no hay suscripciones';

  @override
  String get personalScreenNoBorrowed => 'Aún no hay ítems de deuda';

  @override
  String get personalScreenBorrowedItems => 'Ítems de deuda';

  @override
  String get personalScreenLentItems => 'Ítems prestados';

  @override
  String get personalScreenNoLent => 'Aún no hay ítems prestados';

  @override
  String get addBorrowedTitle => 'Añadir Ítem de Deuda';

  @override
  String get addLentTitle => 'Añadir Ítem Prestado';

  @override
  String get addBorrowedName => 'Nombre';

  @override
  String get addBorrowedAmount => 'Monto';

  @override
  String get addBorrowedNotes => 'Notas';

  @override
  String get addBorrowedMore => 'Más';

  @override
  String get addBorrowedDate => 'Fecha';

  @override
  String get addBorrowedDueDate => 'Fecha de Vencimiento';

  @override
  String get addBorrowedReturned => 'Devuelto';

  @override
  String get addBorrowedMarkReturned => 'Marcar como Devuelto';

  @override
  String get addSubscriptionPrice => 'Precio';

  @override
  String get addSubscriptionName => 'Nombre';

  @override
  String get addSubscriptionRecurrence => 'Recurrencia';

  @override
  String get addSubscriptionMore => 'Más';

  @override
  String get addSubscriptionNotes => 'Notas';

  @override
  String get addSubscriptionStartDate => 'Fecha de Inicio';

  @override
  String get addLentName => 'Nombre';

  @override
  String get addLentAmount => 'Monto';

  @override
  String get addLentNotes => 'Notas';

  @override
  String get addLentMore => 'Más';

  @override
  String get addLentDate => 'Fecha';

  @override
  String get addLentDueDate => 'Fecha de Vencimiento';

  @override
  String get addLentReturned => 'Devuelto';

  @override
  String get addLentMarkReturned => 'Marcar como Devuelto';

  @override
  String get currencyPageTitle => 'Tasas de Cambio';

  @override
  String get profileVacationMode => 'Modo Vacaciones';

  @override
  String get profileCurrency => 'Moneda';

  @override
  String get profileLegal => 'LEGAL';

  @override
  String get profileSupport => 'SOPORTE';

  @override
  String get profileDangerZone => 'ZONA DE PELIGRO';

  @override
  String get profileLogout => 'Cerrar Sesión';

  @override
  String get homeIncome => 'Ingresos';

  @override
  String get homeExpense => 'Gastos';

  @override
  String get expenseDetailPaidUnpaid => 'PAGADO/NO PAGADO';

  @override
  String get goalsScreenPendingGoals => 'Metas Pendientes';

  @override
  String get goalsScreenFulfilledGoals => 'Metas Cumplidas';

  @override
  String get transactionEditIncome => 'Editar Ingreso';

  @override
  String get transactionEditExpense => 'Editar Gasto';

  @override
  String get transactionPlanIncome => 'Planificar un Ingreso';

  @override
  String get transactionPlanExpense => 'Planificar un Gasto';

  @override
  String get goal => 'Meta';

  @override
  String get none => 'Ninguno';

  @override
  String get unnamedCategory => 'Categoría sin nombre';

  @override
  String get month => 'Mes';

  @override
  String get daily => 'Diario';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensual';
}
