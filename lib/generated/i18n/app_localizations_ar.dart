// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitle =>
      'أدخل بريدك الإلكتروني وكلمة المرور لتسجيل الدخول';

  @override
  String get emailHint => 'البريد الإلكتروني';

  @override
  String get passwordHint => 'كلمة المرور';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get orLoginWith => 'أو سجل الدخول باستخدام';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل عنوان بريدك الإلكتروني لاستعادة كلمة المرور';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get confirmButton => 'تأكيد';

  @override
  String get passwordResetEmailSent =>
      'تم إرسال بريد إعادة تعيين كلمة المرور. يرجى التحقق من بريدك الوارد.';

  @override
  String get getStartedTitle => 'ابدأ الآن';

  @override
  String get createAccountSubtitle => 'أنشئ حسابًا للمتابعة';

  @override
  String get nameHint => 'الاسم';

  @override
  String get confirmPasswordHint => 'تأكيد كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get orContinueWith => 'أو المتابعة باستخدام';

  @override
  String get continueWithGoogle => 'المتابعة باستخدام جوجل';

  @override
  String get continueWithApple => 'المتابعة باستخدام آبل';

  @override
  String get alreadyHaveAccount => 'هل لديك حساب بالفعل؟';

  @override
  String get selectCurrencyTitle => 'اختر العملة';

  @override
  String get selectCurrencySubtitle => 'اختر عملتك المفضلة';

  @override
  String get selectCurrencyLabel => 'اختر العملة';

  @override
  String get continueButton => 'متابعة';

  @override
  String errorDuringSetup(Object error) {
    return 'خطأ أثناء الإعداد: $error';
  }

  @override
  String get backButton => 'رجوع';

  @override
  String get onboardingPage1Title => 'ادخر بذكاء';

  @override
  String get onboardingPage1Description =>
      'ضع المال جانباً دون عناء وشاهد مدخراتك تنمو مع كل خطوة.';

  @override
  String get onboardingPage2Title => 'حقق أهدافك';

  @override
  String get onboardingPage2Description =>
      'أنشئ أهدافًا مالية، من أداة جديدة إلى رحلة أحلامك، وتتبع تقدمك.';

  @override
  String get onboardingPage3Title => 'ابق على المسار الصحيح';

  @override
  String get onboardingPage3Description =>
      'راقب إنفاقك ودخلك ومدخراتك، كل ذلك في لوحة تحكم واحدة بسيطة.';

  @override
  String get paywallCouldNotLoadPlans =>
      'تعذر تحميل الخطط.\nيرجى المحاولة مرة أخرى لاحقًا.';

  @override
  String get paywallChooseYourPlan => 'اختر خطتك';

  @override
  String get paywallInvestInFinancialFreedom => 'استثمر في حريتك المالية اليوم';

  @override
  String paywallPricePerDay(Object price) {
    return '$price/يوم';
  }

  @override
  String paywallSaveAmount(Object amount) {
    return 'وفر $amount';
  }

  @override
  String get paywallEverythingIncluded => 'كل شيء مشمول:';

  @override
  String get paywallPersonalizedBudgetInsights => 'رؤى مخصصة للميزانية';

  @override
  String get paywallDailyProgressTracking => 'تتبع التقدم اليومي';

  @override
  String get paywallExpenseManagementTools => 'أدوات إدارة النفقات';

  @override
  String get paywallFinancialHealthTimeline => 'الجدول الزمني للصحة المالية';

  @override
  String get paywallExpertGuidanceTips => 'إرشادات ونصائح الخبراء';

  @override
  String get paywallCommunitySupportAccess => 'الوصول إلى دعم المجتمع';

  @override
  String get paywallSaveYourFinances => 'حافظ على أموالك ومستقبلك';

  @override
  String get paywallAverageUserSaves =>
      'يوفر المستخدم العادي حوالي 2500 جنيه إسترليني سنويًا عن طريق الميزانية الفعالة';

  @override
  String get paywallSubscribeYourPlan => 'اشترك في خطتك';

  @override
  String get paywallPleaseSelectPlan => 'يرجى اختيار خطة.';

  @override
  String get paywallSubscriptionActivated =>
      'تم تفعيل الاشتراك! لديك الآن حق الوصول إلى الميزات المميزة.';

  @override
  String paywallFailedToPurchase(Object message) {
    return 'فشل الشراء: $message';
  }

  @override
  String paywallUnexpectedError(Object error) {
    return 'حدث خطأ غير متوقع: $error';
  }

  @override
  String get paywallRestorePurchases => 'استعادة المشتريات';

  @override
  String get paywallManageSubscription => 'إدارة الاشتراك';

  @override
  String get paywallPurchasesRestoredSuccessfully =>
      'تم استعادة المشتريات بنجاح!';

  @override
  String get paywallNoActiveSubscriptionFound =>
      'لم يتم العثور على اشتراك نشط. أنت الآن على الخطة المجانية.';

  @override
  String get paywallPerMonth => 'شهريًا';

  @override
  String get paywallPerYear => 'سنويًا';

  @override
  String get paywallBestValue => 'القيمة الأفضل';

  @override
  String get paywallMostPopular => 'الأكثر شيوعًا';

  @override
  String get mainScreenHome => 'الرئيسية';

  @override
  String get mainScreenBudget => 'الميزانية';

  @override
  String get mainScreenBalance => 'الرصيد';

  @override
  String get mainScreenGoals => 'الأهداف';

  @override
  String get mainScreenPersonal => 'شخصي';

  @override
  String get mainScreenIncome => 'الدخل';

  @override
  String get mainScreenExpense => 'المصروفات';

  @override
  String get balanceTitle => 'الرصيد';

  @override
  String get balanceAddAccount => 'إضافة حساب';

  @override
  String get addAVacation => 'إضافة إجازة';

  @override
  String get balanceMyAccounts => 'حساباتي';

  @override
  String get balanceVacation => 'إجازة';

  @override
  String get balanceAccountBalance => 'رصيد الحساب';

  @override
  String get balanceNoAccountsFound => 'لم يتم العثور على حسابات.';

  @override
  String get balanceNoAccountsCreated => 'لم يتم إنشاء حسابات';

  @override
  String get balanceCreateFirstAccount => 'أنشئ حسابك الأول لبدء تتبع الأرصدة';

  @override
  String get balanceCreateFirstAccountFinances =>
      'أنشئ حسابك الأول لبدء تتبع أموالك';

  @override
  String get balanceNoVacationsYet => 'لا توجد إجازات بعد';

  @override
  String get balanceCreateFirstVacation =>
      'أنشئ حساب الإجازة الأول لبدء التخطيط لرحلاتك';

  @override
  String get balanceCreateVacationAccount => 'إنشاء حساب الإجازة';

  @override
  String get balanceSingleAccountView => 'عرض حساب واحد';

  @override
  String get balanceAddMoreAccounts =>
      'أضف المزيد من الحسابات لرؤية الرسوم البيانية';

  @override
  String get balanceNoAccountsForCurrency =>
      'لم يتم العثور على حسابات للعملة المختارة';

  @override
  String balanceCreditLimit(Object value) {
    return 'الحد الائتماني: $value';
  }

  @override
  String balanceBalanceLimit(Object value) {
    return 'حد الرصيد: $value';
  }

  @override
  String get budgetTitle => 'الميزانية';

  @override
  String get budgetAddBudget => 'إضافة ميزانية';

  @override
  String get budgetDaily => 'يومي';

  @override
  String get budgetWeekly => 'أسبوعي';

  @override
  String get budgetMonthly => 'شهري';

  @override
  String get budgetSelectWeek => 'اختر الأسبوع';

  @override
  String get budgetSelectDate => 'اختر التاريخ';

  @override
  String get budgetSelectDay => 'اختر اليوم';

  @override
  String get budgetCancel => 'إلغاء';

  @override
  String get budgetApply => 'تطبيق';

  @override
  String get budgetTotalSpending => 'إجمالي الإنفاق';

  @override
  String get budgetCategoryBreakdown => 'تفاصيل الفئات';

  @override
  String get budgetViewAll => 'عرض الكل';

  @override
  String get budgetBudgets => 'الميزانيات';

  @override
  String get budgetNoBudgetCreated => 'لم يتم إنشاء ميزانية';

  @override
  String get budgetStartCreatingBudget =>
      'ابدأ بإنشاء ميزانية لرؤية تفاصيل إنفاقك هنا.';

  @override
  String get budgetSetSpendingLimit => 'تحديد حد الإنفاق';

  @override
  String get budgetEnterLimitAmount => 'أدخل مبلغ الحد';

  @override
  String get budgetSave => 'حفظ';

  @override
  String get budgetEnterValidNumber => 'أدخل رقمًا صالحًا';

  @override
  String get budgetLimitSaved => 'تم حفظ حد الميزانية';

  @override
  String get budgetCreated => 'تم إنشاء الميزانية';

  @override
  String get budgetTransactions => 'معاملات';

  @override
  String budgetOverBudget(Object amount) {
    return '$amount فوق الميزانية';
  }

  @override
  String budgetRemaining(Object amount) {
    return '$amount متبقي';
  }

  @override
  String get homeNoMoreTransactions => 'لا مزيد من المعاملات';

  @override
  String get homeErrorLoadingMoreTransactions =>
      'خطأ في تحميل المزيد من المعاملات';

  @override
  String get homeRetry => 'إعادة المحاولة';

  @override
  String get homeErrorLoadingData => 'خطأ في تحميل البيانات';

  @override
  String get homeNoTransactionsRecorded => 'لم يتم تسجيل أي معاملات';

  @override
  String get homeStartAddingTransactions =>
      'ابدأ بإضافة المعاملات لرؤية تفاصيل إنفاقك هنا.';

  @override
  String get homeCurrencyChange => 'تغيير العملة';

  @override
  String get homeCurrencyChangeMessage =>
      'سيؤدي تغيير عملتك إلى تحويل جميع المبالغ الحالية. لا يمكن التراجع عن هذا الإجراء. هل تريد المتابعة؟';

  @override
  String get homeNo => 'لا';

  @override
  String get homeYes => 'نعم';

  @override
  String get homeVacationBudgetBreakdown => 'تفاصيل ميزانية الإجازة';

  @override
  String get homeBalanceBreakdown => 'تفاصيل الرصيد';

  @override
  String get homeClose => 'إغلاق';

  @override
  String get transactionPickColor => 'اختر لونًا';

  @override
  String get transactionSelectDate => 'اختر التاريخ';

  @override
  String get transactionCancel => 'إلغاء';

  @override
  String get transactionApply => 'تطبيق';

  @override
  String get transactionAmount => 'المبلغ';

  @override
  String get transactionSelect => 'اختر';

  @override
  String get transactionPaid => 'مدفوع';

  @override
  String get transactionAddTransaction => 'إضافة معاملة';

  @override
  String get transactionEditTransaction => 'تعديل المعاملة';

  @override
  String get transactionIncome => 'دخل';

  @override
  String get transactionExpense => 'مصروف';

  @override
  String get transactionDescription => 'الوصف';

  @override
  String get transactionCategory => 'الفئة';

  @override
  String get transactionAccount => 'الحساب';

  @override
  String get transactionDate => 'التاريخ';

  @override
  String get transactionSave => 'حفظ';

  @override
  String get transactionDelete => 'حذف';

  @override
  String get transactionSuccess => 'تم حفظ المعاملة بنجاح';

  @override
  String get transactionError => 'خطأ في حفظ المعاملة';

  @override
  String get transactionDeleteConfirm =>
      'هل أنت متأكد أنك تريد حذف هذه المعاملة؟';

  @override
  String get transactionDeleteSuccess => 'تم حذف المعاملة بنجاح';

  @override
  String get goalsTitle => 'الأهداف';

  @override
  String get goalsAddGoal => 'إضافة هدف';

  @override
  String get goalsNoGoalsCreated => 'لم يتم إنشاء أهداف';

  @override
  String get goalsStartCreatingGoal => 'ابدأ بإنشاء هدف لتتبع تقدمك المالي';

  @override
  String get goalsCreateGoal => 'إنشاء هدف';

  @override
  String get goalsEditGoal => 'تعديل الهدف';

  @override
  String get goalsGoalName => 'اسم الهدف';

  @override
  String get goalsTargetAmount => 'المبلغ المستهدف';

  @override
  String get goalsCurrentAmount => 'المبلغ الحالي';

  @override
  String get goalsDeadline => 'الموعد النهائي';

  @override
  String get goalsDescription => 'الوصف';

  @override
  String get goalsSave => 'حفظ';

  @override
  String get goalsCancel => 'إلغاء';

  @override
  String get goalsDelete => 'حذف';

  @override
  String get goalsGoalCreated => 'تم إنشاء الهدف بنجاح';

  @override
  String get goalsGoalUpdated => 'تم تحديث الهدف بنجاح';

  @override
  String get goalsGoalDeleted => 'تم حذف الهدف بنجاح';

  @override
  String get goalsErrorSaving => 'خطأ في حفظ الهدف';

  @override
  String get goalsDeleteConfirm => 'هل أنت متأكد أنك تريد حذف هذا الهدف؟';

  @override
  String get goalsProgress => 'التقدم';

  @override
  String get goalsCompleted => 'مكتمل';

  @override
  String get goalsInProgress => 'قيد التنفيذ';

  @override
  String get goalsNotStarted => 'لم يبدأ';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profilePremiumActive => 'الاشتراك المميز مفعل';

  @override
  String get profilePremiumDescription =>
      'لديك حق الوصول إلى جميع الميزات المميزة';

  @override
  String get profileFreePlan => 'الخطة المجانية';

  @override
  String get profileUpgradeDescription =>
      'قم بالترقية إلى المميز للحصول على ميزات متقدمة';

  @override
  String profileRenewalDate(Object date) {
    return 'يُجدد في $date';
  }

  @override
  String profileExpiresOn(Object date) {
    return 'ينتهي في $date';
  }

  @override
  String profileErrorSigningOut(Object error) {
    return 'خطأ أثناء تسجيل الخروج: $error';
  }

  @override
  String get profileUserNotFound => 'المستخدم غير موجود';

  @override
  String get profileEditDisplayName => 'تعديل اسم العرض';

  @override
  String get profileCancel => 'إلغاء';

  @override
  String get profileSave => 'حفظ';

  @override
  String get profileDisplayNameUpdated => 'تم تحديث اسم العرض بنجاح';

  @override
  String get profileErrorUpdatingName => 'خطأ في تحديث اسم العرض';

  @override
  String get profileManageSubscription => 'إدارة الاشتراك';

  @override
  String get profileRestorePurchases => 'استعادة المشتريات';

  @override
  String get profileRefreshStatus => 'تحديث الحالة';

  @override
  String get profileSubscriptionRefreshed => 'تم تحديث حالة الاشتراك';

  @override
  String get profileSignOut => 'تسجيل الخروج';

  @override
  String get profileSignOutConfirm => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get profileCurrencyRates => 'أسعار العملات';

  @override
  String get profileCategories => 'الفئات';

  @override
  String get profileFeedback => 'رأيك يهمنا';

  @override
  String get profileExportData => 'تصدير البيانات';

  @override
  String get profileSettings => 'الإعدادات';

  @override
  String get profileAccount => 'الحساب';

  @override
  String get profileDisplayName => 'اسم العرض';

  @override
  String get profileEmail => 'البريد الإلكتروني';

  @override
  String get profileSubscription => 'الاشتراك';

  @override
  String get profileVersion => 'الإصدار';

  @override
  String get personalTitle => 'شخصي';

  @override
  String get personalSubscriptions => 'الاشتراكات';

  @override
  String get personalBorrowed => 'اقترضت';

  @override
  String get personalAddSubscription => 'إضافة اشتراك';

  @override
  String get personalAddLent => 'إضافة قرض (أقرضت)';

  @override
  String get personalAddBorrowed => 'إضافة دين (اقترضت)';

  @override
  String get personalNoSubscriptions => 'لم يتم العثور على اشتراكات';

  @override
  String get personalNoLent => 'لم يتم العثور على عناصر مُقرضة';

  @override
  String get personalNoBorrowed => 'لم يتم العثور على عناصر مُقترضة';

  @override
  String get personalStartAddingSubscription =>
      'ابدأ بإضافة اشتراك لتتبع مدفوعاتك المتكررة';

  @override
  String get personalStartAddingLent =>
      'ابدأ بإضافة عناصر مُقرضة لتتبع الأموال التي أقرضتها';

  @override
  String get personalStartAddingBorrowed =>
      'ابدأ بإضافة عناصر مُقترضة لتتبع الأموال التي اقترضتها';

  @override
  String get personalEdit => 'تعديل';

  @override
  String get personalDelete => 'حذف';

  @override
  String get personalMarkAsPaid => 'وضع علامة كمدفوع';

  @override
  String get personalMarkAsUnpaid => 'وضع علامة كغير مدفوع';

  @override
  String get personalAmount => 'المبلغ';

  @override
  String get personalDescription => 'الوصف';

  @override
  String get personalDueDate => 'تاريخ الاستحقاق';

  @override
  String get personalRecurring => 'متكرر';

  @override
  String get personalOneTime => 'مرة واحدة';

  @override
  String get personalMonthly => 'شهري';

  @override
  String get personalYearly => 'سنوي';

  @override
  String get personalWeekly => 'أسبوعي';

  @override
  String get personalDaily => 'يومي';

  @override
  String get personalName => 'الاسم';

  @override
  String get personalCategory => 'الفئة';

  @override
  String get personalNotes => 'ملاحظات';

  @override
  String get personalSave => 'حفظ';

  @override
  String get personalCancel => 'إلغاء';

  @override
  String get personalDeleteConfirm => 'هل أنت متأكد أنك تريد حذف هذا العنصر؟';

  @override
  String get personalItemSaved => 'تم حفظ العنصر بنجاح';

  @override
  String get personalItemDeleted => 'تم حذف العنصر بنجاح';

  @override
  String get personalErrorSaving => 'خطأ في حفظ العنصر';

  @override
  String get personalErrorDeleting => 'خطأ في حذف العنصر';

  @override
  String get analyticsTitle => 'التحليلات';

  @override
  String get analyticsOverview => 'نظرة عامة';

  @override
  String get analyticsIncome => 'الدخل';

  @override
  String get analyticsExpenses => 'المصروفات';

  @override
  String get analyticsSavings => 'المدخرات';

  @override
  String get analyticsCategories => 'الفئات';

  @override
  String get analyticsTrends => 'الاتجاهات';

  @override
  String get analyticsMonthly => 'شهري';

  @override
  String get analyticsWeekly => 'أسبوعي';

  @override
  String get analyticsDaily => 'يومي';

  @override
  String get analyticsYearly => 'سنوي';

  @override
  String get analyticsNoData => 'لا توجد بيانات متاحة';

  @override
  String get analyticsStartTracking => 'ابدأ بتتبع أموالك لرؤية التحليلات هنا';

  @override
  String get analyticsTotalIncome => 'إجمالي الدخل';

  @override
  String get analyticsTotalExpenses => 'إجمالي المصروفات';

  @override
  String get analyticsNetSavings => 'صافي المدخرات';

  @override
  String get analyticsTopCategories => 'أعلى الفئات';

  @override
  String get analyticsSpendingTrends => 'اتجاهات الإنفاق';

  @override
  String get analyticsIncomeTrends => 'اتجاهات الدخل';

  @override
  String get analyticsSavingsRate => 'معدل الادخار';

  @override
  String get analyticsAverageDaily => 'المتوسط اليومي';

  @override
  String get analyticsAverageWeekly => 'المتوسط الأسبوعي';

  @override
  String get analyticsAverageMonthly => 'المتوسط الشهري';

  @override
  String get analyticsSelectPeriod => 'اختر الفترة';

  @override
  String get analyticsExportData => 'تصدير البيانات';

  @override
  String get analyticsRefresh => 'تحديث';

  @override
  String get analyticsErrorLoading => 'خطأ في تحميل بيانات التحليلات';

  @override
  String get analyticsRetry => 'إعادة المحاولة';

  @override
  String get goalsSelectColor => 'اختر لونًا';

  @override
  String get goalsMore => 'المزيد';

  @override
  String get goalsName => 'اسم الهدف';

  @override
  String get goalsColor => 'اللون';

  @override
  String get goalsNameRequired => 'اسم الهدف مطلوب';

  @override
  String get goalsAmountRequired => 'المبلغ المستهدف مطلوب';

  @override
  String get goalsAmountMustBePositive =>
      'يجب أن يكون المبلغ المستهدف أكبر من 0';

  @override
  String get goalsDeadlineRequired => 'الموعد النهائي مطلوب';

  @override
  String get goalsDeadlineMustBeFuture =>
      'يجب أن يكون الموعد النهائي في المستقبل';

  @override
  String get goalsNameAlreadyExists => 'يوجد هدف بهذا الاسم بالفعل';

  @override
  String goalsErrorCreating(Object error) {
    return 'خطأ في إنشاء الهدف: $error';
  }

  @override
  String goalsErrorUpdating(Object error) {
    return 'خطأ في تحديث الهدف: $error';
  }

  @override
  String goalsErrorDeleting(Object error) {
    return 'خطأ في حذف الهدف: $error';
  }

  @override
  String get expenseDetailTitle => 'تفاصيل المصروف';

  @override
  String get expenseDetailEdit => 'تعديل';

  @override
  String get expenseDetailDelete => 'حذف';

  @override
  String get expenseDetailAmount => 'المبلغ';

  @override
  String get expenseDetailCategory => 'الفئة';

  @override
  String get expenseDetailAccount => 'الحساب';

  @override
  String get expenseDetailDate => 'التاريخ';

  @override
  String get expenseDetailDescription => 'الوصف';

  @override
  String get expenseDetailNotes => 'ملاحظات';

  @override
  String get expenseDetailSave => 'حفظ';

  @override
  String get expenseDetailCancel => 'إلغاء';

  @override
  String get expenseDetailDeleteConfirm =>
      'هل أنت متأكد أنك تريد حذف هذا المصروف؟';

  @override
  String get expenseDetailUpdated => 'تم تحديث المصروف بنجاح';

  @override
  String get expenseDetailDeleted => 'تم حذف المصروف بنجاح';

  @override
  String get expenseDetailErrorSaving => 'خطأ في حفظ المصروف';

  @override
  String get expenseDetailErrorDeleting => 'خطأ في حذف المصروف';

  @override
  String get calendarTitle => 'التقويم';

  @override
  String get calendarSelectDate => 'اختر التاريخ';

  @override
  String get calendarToday => 'اليوم';

  @override
  String get calendarThisWeek => 'هذا الأسبوع';

  @override
  String get calendarThisMonth => 'هذا الشهر';

  @override
  String get calendarThisYear => 'هذه السنة';

  @override
  String get calendarNoTransactions => 'لا توجد معاملات في هذا التاريخ';

  @override
  String get calendarStartAddingTransactions =>
      'ابدأ بإضافة المعاملات لرؤيتها في التقويم';

  @override
  String get vacationDialogTitle => 'وضع الإجازة';

  @override
  String get vacationDialogEnable => 'تفعيل وضع الإجازة';

  @override
  String get vacationDialogDisable => 'إلغاء تفعيل وضع الإجازة';

  @override
  String get vacationDialogDescription =>
      'يساعدك وضع الإجازة على تتبع النفقات أثناء الرحلات والعطلات';

  @override
  String get vacationDialogCancel => 'إلغاء';

  @override
  String get vacationDialogConfirm => 'تأكيد';

  @override
  String get vacationDialogEnabled => 'تم تفعيل وضع الإجازة';

  @override
  String get vacationDialogDisabled => 'تم إلغاء تفعيل وضع الإجازة';

  @override
  String get balanceDetailTitle => 'تفاصيل الحساب';

  @override
  String get balanceDetailEdit => 'تعديل';

  @override
  String get balanceDetailDelete => 'حذف';

  @override
  String get balanceDetailTransactions => 'المعاملات';

  @override
  String get balanceDetailBalance => 'الرصيد';

  @override
  String get balanceDetailCreditLimit => 'الحد الائتماني';

  @override
  String get balanceDetailBalanceLimit => 'حد الرصيد';

  @override
  String get balanceDetailCurrency => 'العملة';

  @override
  String get balanceDetailAccountType => 'نوع الحساب';

  @override
  String get balanceDetailAccountName => 'اسم الحساب';

  @override
  String get balanceDetailSave => 'حفظ';

  @override
  String get balanceDetailCancel => 'إلغاء';

  @override
  String get balanceDetailDeleteConfirm =>
      'هل أنت متأكد أنك تريد حذف هذا الحساب؟';

  @override
  String get balanceDetailUpdated => 'تم تحديث الحساب بنجاح';

  @override
  String get balanceDetailDeleted => 'تم حذف الحساب بنجاح';

  @override
  String get balanceDetailErrorSaving => 'خطأ في حفظ الحساب';

  @override
  String get balanceDetailErrorDeleting => 'خطأ في حذف الحساب';

  @override
  String get addAccountTitle => 'إضافة حساب';

  @override
  String get addAccountEditTitle => 'تعديل الحساب';

  @override
  String get addAccountName => 'اسم الحساب';

  @override
  String get addAccountType => 'نوع الحساب';

  @override
  String get addAccountCurrency => 'العملة';

  @override
  String get addAccountInitialBalance => 'الرصيد الأولي';

  @override
  String get addAccountCreditLimit => 'الحد الائتماني';

  @override
  String get addAccountBalanceLimit => 'حد الرصيد';

  @override
  String get addAccountColor => 'اللون';

  @override
  String get addAccountIcon => 'أيقونة';

  @override
  String get addAccountSave => 'حفظ';

  @override
  String get addAccountCancel => 'إلغاء';

  @override
  String get addAccountCreated => 'تم إنشاء الحساب بنجاح';

  @override
  String get addAccountUpdated => 'تم تحديث الحساب بنجاح';

  @override
  String get addAccountErrorSaving => 'خطأ في حفظ الحساب';

  @override
  String get addAccountNameRequired => 'اسم الحساب مطلوب';

  @override
  String get addAccountTypeRequired => 'نوع الحساب مطلوب';

  @override
  String get addAccountCurrencyRequired => 'العملة مطلوبة';

  @override
  String get budgetDetailTitle => 'تفاصيل الميزانية';

  @override
  String get budgetDetailEdit => 'تعديل';

  @override
  String get budgetDetailDelete => 'حذف';

  @override
  String get budgetDetailSpending => 'الإنفاق';

  @override
  String get budgetDetailLimit => 'الحد';

  @override
  String get budgetDetailRemaining => 'المتبقي';

  @override
  String get budgetDetailOverBudget => 'تجاوز الميزانية';

  @override
  String get budgetDetailCategories => 'الفئات';

  @override
  String get budgetDetailTransactions => 'المعاملات';

  @override
  String get budgetDetailSave => 'حفظ';

  @override
  String get budgetDetailCancel => 'إلغاء';

  @override
  String get budgetDetailDeleteConfirm =>
      'هل أنت متأكد أنك تريد حذف هذه الميزانية؟';

  @override
  String get budgetDetailUpdated => 'تم تحديث الميزانية بنجاح';

  @override
  String get budgetDetailDeleted => 'تم حذف الميزانية بنجاح';

  @override
  String get budgetDetailErrorSaving => 'خطأ في حفظ الميزانية';

  @override
  String get budgetDetailErrorDeleting => 'خطأ في حذف الميزانية';

  @override
  String get addBudgetTitle => 'إضافة ميزانية';

  @override
  String get addBudgetEditTitle => 'تعديل الميزانية';

  @override
  String get addBudgetName => 'اسم الميزانية';

  @override
  String get addBudgetType => 'نوع الميزانية';

  @override
  String get addBudgetAmount => 'المبلغ';

  @override
  String get addBudgetCurrency => 'العملة';

  @override
  String get addBudgetPeriod => 'الفترة';

  @override
  String get addBudgetCategories => 'الفئات';

  @override
  String get addBudgetColor => 'اللون';

  @override
  String get addBudgetSave => 'حفظ';

  @override
  String get addBudgetSaveBudget => 'حفظ الميزانية';

  @override
  String get addBudgetCancel => 'إلغاء';

  @override
  String get addBudgetCreated => 'تم إنشاء الميزانية بنجاح';

  @override
  String get addBudgetUpdated => 'تم تحديث الميزانية بنجاح';

  @override
  String get addBudgetErrorSaving => 'خطأ في حفظ الميزانية';

  @override
  String get addBudgetNameRequired => 'اسم الميزانية مطلوب';

  @override
  String get addBudgetAmountRequired => 'مبلغ الميزانية مطلوب';

  @override
  String get addBudgetAmountMustBePositive =>
      'يجب أن يكون مبلغ الميزانية أكبر من 0';

  @override
  String get addBudgetCategoryRequired => 'يرجى اختيار فئة';

  @override
  String get budgetDetailNoBudgetToDelete =>
      'لا توجد ميزانية لحذفها. هذا مجرد عنصر نائب للمعاملات.';

  @override
  String get personalItemDetails => 'تفاصيل العنصر';

  @override
  String get personalStartDateRequired => 'يرجى اختيار تاريخ البدء';

  @override
  String get profileMainCurrency => 'العملة الرئيسية';

  @override
  String get profileFeedbackThankYou => 'شكرًا لك على ملاحظاتك!';

  @override
  String get profileFeedbackEmailError => 'تعذر فتح برنامج البريد الإلكتروني.';

  @override
  String get feedbackModalTitle => 'هل تستمتع بالتطبيق؟';

  @override
  String get feedbackModalDescription =>
      'ملاحظاتك تحفزنا وتساعدنا على التحسين.';

  @override
  String get goalNameAlreadyExistsSnackbar => 'يوجد هدف بهذا الاسم بالفعل';

  @override
  String get lentSelectBothDates => 'يرجى اختيار التاريخ وتاريخ الاستحقاق';

  @override
  String get lentDueDateBeforeLentDate =>
      'لا يمكن أن يكون تاريخ الاستحقاق قبل تاريخ الإقراض';

  @override
  String get lentItemAddedSuccessfully => 'تمت إضافة العنصر المُقرض بنجاح';

  @override
  String lentItemError(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get borrowedSelectBothDates => 'يرجى اختيار التاريخ وتاريخ الاستحقاق';

  @override
  String get borrowedDueDateBeforeBorrowedDate =>
      'لا يمكن أن يكون تاريخ الاستحقاق قبل تاريخ الاقتراض';

  @override
  String get borrowedItemAddedSuccessfully => 'تمت إضافة العنصر المُقترض بنجاح';

  @override
  String borrowedItemError(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get subscriptionCreatedSuccessfully => 'تم إنشاء الاشتراك بنجاح';

  @override
  String subscriptionError(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get paymentMarkedSuccessfully => 'تم تمييز الدفع بنجاح';

  @override
  String get subscriptionContinued => 'تم استئناف الاشتراك بنجاح';

  @override
  String get subscriptionPaused => 'تم إيقاف الاشتراك مؤقتًا بنجاح';

  @override
  String get itemMarkedAsReturnedSuccessfully => 'تم تمييز العنصر كمرجع بنجاح';

  @override
  String get itemDeletedSuccessfully => 'تم حذف العنصر بنجاح';

  @override
  String get failedToDeleteBudget => 'فشل حذف الميزانية';

  @override
  String get failedToDeleteGoal => 'فشل حذف الهدف';

  @override
  String failedToSaveTransaction(Object error) {
    return 'فشل حفظ المعاملة: $error';
  }

  @override
  String get failedToReorderCategories =>
      'فشل إعادة ترتيب الفئات. يتم التراجع عن التغييرات.';

  @override
  String get categoryAddedSuccessfully => 'تمت إضافة الفئة بنجاح';

  @override
  String failedToAddCategory(Object error) {
    return 'فشل إضافة الفئة: $error';
  }

  @override
  String get addCategory => 'إضافة فئة';

  @override
  String errorCreatingGoal(Object error) {
    return 'خطأ في إنشاء الهدف: $error';
  }

  @override
  String get hintName => 'الاسم';

  @override
  String get hintDescription => 'الوصف';

  @override
  String get hintSelectDate => 'اختر التاريخ';

  @override
  String get hintSelectDueDate => 'اختر تاريخ الاستحقاق';

  @override
  String get hintSelectCategory => 'اختر الفئة';

  @override
  String get hintSelectAccount => 'اختر الحساب';

  @override
  String get hintSelectGoal => 'اختر الهدف';

  @override
  String get hintNotes => 'ملاحظات';

  @override
  String get hintSelectColor => 'اختر اللون';

  @override
  String get hintEnterCategoryName => 'أدخل اسم الفئة';

  @override
  String get hintSelectType => 'اختر النوع';

  @override
  String get hintWriteThoughts => 'اكتب أفكارك هنا......';

  @override
  String get hintEnterDisplayName => 'أدخل اسم العرض';

  @override
  String get hintSelectBudgetType => 'اختر نوع الميزانية';

  @override
  String get hintSelectAccountType => 'اختر نوع الحساب';

  @override
  String get hintEnterName => 'أدخل الاسم';

  @override
  String get hintSelectIcon => 'اختر أيقونة';

  @override
  String get hintSelect => 'اختر';

  @override
  String get hintAmountPlaceholder => '0.00';

  @override
  String get labelValue => 'القيمة';

  @override
  String get labelName => 'الاسم';

  @override
  String get labelDescription => 'الوصف';

  @override
  String get labelCategory => 'الفئة';

  @override
  String get labelDate => 'التاريخ';

  @override
  String get labelDueDate => 'تاريخ الاستحقاق';

  @override
  String get labelColor => 'اللون';

  @override
  String get labelNotes => 'ملاحظات';

  @override
  String get labelAccount => 'الحساب';

  @override
  String get labelMore => 'المزيد';

  @override
  String get labelHome => 'الرئيسية';

  @override
  String get titlePickColor => 'اختر لونًا';

  @override
  String get titleAddLentItem => 'إضافة عنصر مُقرض';

  @override
  String get titleAddBorrowedItem => 'إضافة عنصر مُقترض';

  @override
  String get titleSelectCategory => 'اختر الفئة';

  @override
  String get titleSelectAccount => 'اختر الحساب';

  @override
  String get titleSelectGoal => 'اختر الهدف';

  @override
  String get titleSelectType => 'اختر النوع';

  @override
  String get titleSelectAccountType => 'اختر نوع الحساب';

  @override
  String get titleSelectBudgetType => 'اختر نوع الميزانية';

  @override
  String get validationNameRequired => 'الاسم مطلوب';

  @override
  String get validationAmountRequired => 'المبلغ مطلوب';

  @override
  String get validationPleaseEnterValidNumber => 'يرجى إدخال رقم صالح';

  @override
  String get validationPleaseSelectIcon => 'يرجى اختيار أيقونة';

  @override
  String get buttonCancel => 'إلغاء';

  @override
  String get buttonAdd => 'إضافة';

  @override
  String get buttonSave => 'حفظ';

  @override
  String get switchAddProgress => 'إضافة تقدم';

  @override
  String get pickColor => 'اختر لونًا';

  @override
  String get name => 'الاسم';

  @override
  String get itemName => 'اسم العنصر';

  @override
  String get account => 'الحساب';

  @override
  String get selectIcon => 'يرجى اختيار أيقونة';

  @override
  String get value => 'القيمة';

  @override
  String get hintAmount => '0.00';

  @override
  String get hintItemName => 'اسم العنصر';

  @override
  String get amountRequired => 'المبلغ مطلوب';

  @override
  String get validNumber => 'يرجى إدخال رقم صالح';

  @override
  String get category => 'الفئة';

  @override
  String get date => 'التاريخ';

  @override
  String get dueDate => 'تاريخ الاستحقاق';

  @override
  String get color => 'اللون';

  @override
  String get notes => 'ملاحظات';

  @override
  String get selectColor => 'اختر اللون';

  @override
  String get more => 'المزيد';

  @override
  String get addLentItem => 'إضافة عنصر مُقرض';

  @override
  String get addBorrowedItem => 'إضافة عنصر مُقترض';

  @override
  String get cancel => 'إلغاء';

  @override
  String get add => 'إضافة';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get buttonOk => 'موافق';

  @override
  String get vacationNoAccountsAvailable => 'لا توجد حسابات إجازة متاحة.';

  @override
  String get exportFormat => 'التنسيق';

  @override
  String get exportOptions => 'الخيارات';

  @override
  String get exportAccountData => 'تصدير بيانات الحساب';

  @override
  String get exportGoalsData => 'تصدير بيانات الأهداف';

  @override
  String get exportCurrentMonth => 'الشهر الحالي';

  @override
  String get exportLast30Days => 'آخر 30 يومًا';

  @override
  String get exportLast90Days => 'آخر 90 يومًا';

  @override
  String get exportLast365Days => 'آخر 365 يومًا';

  @override
  String get exportCsv => 'CSV';

  @override
  String get exportJson => 'JSON';

  @override
  String get exportImportInstructions =>
      'يمكنك استيراد بياناتك من ملف CSV إلى التطبيق.';

  @override
  String get exportInstructions1 =>
      'احفظ ملف المثال لرؤية تنسيق البيانات المطلوب؛';

  @override
  String get exportInstructions2 =>
      'قم بتنسيق بياناتك وفقًا للقالب. تأكد من أن الأعمدة وترتيبها وأسماءها مطابقة تمامًا للقالب. يجب أن تكون أسماء الأعمدة باللغة الإنجليزية؛';

  @override
  String get exportInstructions3 => 'اضغط على استيراد واختر ملفك؛';

  @override
  String get exportInstructions4 =>
      'اختر ما إذا كنت تريد الكتابة فوق البيانات الحالية أو إضافة البيانات المستوردة إلى البيانات الحالية. عند اختيار خيار الكتابة الفوقية، سيتم حذف البيانات الحالية نهائيًا؛';

  @override
  String get exportButtonExport => 'تصدير';

  @override
  String get exportButtonImport => 'استيراد';

  @override
  String get exportTabExport => 'تصدير';

  @override
  String get exportTabImport => 'استيراد';

  @override
  String get enableVacationMode => 'تفعيل وضع الإجازة';

  @override
  String get addProgress => 'إضافة تقدم';

  @override
  String get pleaseEnterValidNumber => 'يرجى إدخال رقم صالح';

  @override
  String get pleaseSelectCategory => 'يرجى اختيار فئة';

  @override
  String get pleaseSelectCurrency => 'يرجى اختيار عملة';

  @override
  String get pleaseSelectAccount => 'يرجى اختيار حساب';

  @override
  String get pleaseSelectDate => 'يرجى اختيار تاريخ';

  @override
  String get pleaseSelectIcon => 'يرجى اختيار أيقونة';

  @override
  String get deleteCategory => 'حذف الفئة';

  @override
  String get markAsReturned => 'وضع علامة كمرجع';

  @override
  String get markPayment => 'تمييز الدفع';

  @override
  String get markPaid => 'وضع علامة كمدفوع';

  @override
  String get deleteItem => 'حذف العنصر';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAllAssociatedTransactions => 'حذف جميع المعاملات المرتبطة';

  @override
  String get normalMode => 'الوضع العادي';

  @override
  String normalModeWithCurrency(String currency) {
    return 'أنت الآن في الوضع العادي بالعملة: $currency';
  }

  @override
  String get changeCurrency => 'تغيير العملة';

  @override
  String get vacationModeDialog => 'مربع حوار وضع الإجازة';

  @override
  String get categoryAndTransactionsDeleted =>
      'تم حذف الفئة والمعاملات المرتبطة بها بنجاح';

  @override
  String get select => 'اختر';

  @override
  String get delete => 'حذف';

  @override
  String get confirm => 'تأكيد';

  @override
  String get yourData => 'بياناتك';

  @override
  String get profileMenuAccount => 'الحساب';

  @override
  String get profileMenuCurrency => 'العملة';

  @override
  String get profileSectionLegal => 'قانوني';

  @override
  String get profileTermsConditions => 'الشروط والأحكام';

  @override
  String get profilePrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get profileSectionSupport => 'الدعم';

  @override
  String get profileHelpSupport => 'المساعدة والدعم';

  @override
  String get profileSectionDanger => 'منطقة الخطر';

  @override
  String get currencyPageChange => 'تغيير';

  @override
  String get addTransactionNotes => 'ملاحظات';

  @override
  String get addTransactionMore => 'المزيد';

  @override
  String get addTransactionDate => 'التاريخ';

  @override
  String get addTransactionTime => 'الوقت';

  @override
  String get addTransactionPaid => 'مدفوع';

  @override
  String get addTransactionColor => 'اللون';

  @override
  String get addTransactionCancel => 'إلغاء';

  @override
  String get addTransactionCreate => 'إنشاء';

  @override
  String get addTransactionUpdate => 'تحديث';

  @override
  String get addBudgetLimitAmount => 'مبلغ الحد';

  @override
  String get addBudgetSelectCategory => 'اختر الفئة';

  @override
  String get addBudgetBudgetType => 'نوع الميزانية';

  @override
  String get addBudgetRecurring => 'ميزانية متكررة';

  @override
  String get addBudgetRecurringSubtitle =>
      'تجديد هذه الميزانية تلقائيًا لكل فترة';

  @override
  String get addBudgetRecurringDailySubtitle => 'ينطبق على كل يوم';

  @override
  String get addBudgetRecurringPremiumSubtitle => 'ميزة مميزة - اشترك للتفعيل';

  @override
  String get addBudget => 'إضافة ميزانية';

  @override
  String get addAccountTransactionLimit => 'حد المعاملة';

  @override
  String get addAccountAccountType => 'نوع الحساب';

  @override
  String get addAccountAdd => 'إضافة';

  @override
  String get addAccountBalance => 'رصيد';

  @override
  String get addAccountCredit => 'ائتمان';

  @override
  String get homeIncomeCard => 'الدخل';

  @override
  String get homeExpenseCard => 'المصروف';

  @override
  String get homeTotalBudget => 'إجمالي الميزانية';

  @override
  String get balanceDetailInitialBalance => 'الرصيد الأولي';

  @override
  String get balanceDetailCurrentBalance => 'الرصيد الحالي';

  @override
  String get expenseDetailTotal => 'الإجمالي';

  @override
  String get expenseDetailAccumulatedAmount => 'المبلغ المتراكم';

  @override
  String get expenseDetailPaidStatus => 'مدفوع/غير مدفوع';

  @override
  String get expenseDetailVacation => 'إجازة';

  @override
  String get expenseDetailMarkPaid => 'وضع علامة كمدفوع';

  @override
  String get expenseDetailMarkUnpaid => 'وضع علامة كغير مدفوع';

  @override
  String get goalsScreenPending => 'الأهداف المعلقة';

  @override
  String get goalsScreenFulfilled => 'الأهداف المحققة';

  @override
  String get createGoalTitle => 'إنشاء هدف معلق';

  @override
  String get createGoalAmount => 'المبلغ';

  @override
  String get createGoalName => 'الاسم';

  @override
  String get createGoalCurrency => 'العملة';

  @override
  String get createGoalMore => 'المزيد';

  @override
  String get createGoalNotes => 'ملاحظات';

  @override
  String get createGoalDate => 'التاريخ';

  @override
  String get createGoalColor => 'اللون';

  @override
  String get createGoalLimitReached =>
      'لقد وصلت إلى حد الأهداف. قم بالترقية إلى المميز لإنشاء أهداف غير محدودة.';

  @override
  String get personalScreenSubscriptions => 'الاشتراكات';

  @override
  String get personalScreenBorrowed => 'مقترض';

  @override
  String get personalScreenLent => 'مُقرض';

  @override
  String get personalScreenTotal => 'الإجمالي';

  @override
  String get personalScreenActive => 'نشط';

  @override
  String get personalScreenNoSubscriptions => 'لا توجد اشتراكات بعد';

  @override
  String get personalScreenNoBorrowed => 'لا توجد عناصر مقترضة بعد';

  @override
  String get personalScreenBorrowedItems => 'عناصر مقترضة';

  @override
  String get personalScreenLentItems => 'عناصر مُقرضة';

  @override
  String get personalScreenNoLent => 'لا توجد عناصر مُقرضة بعد';

  @override
  String get addBorrowedTitle => 'إضافة عنصر مُقترض';

  @override
  String get addLentTitle => 'إضافة عنصر مُقرض';

  @override
  String get addBorrowedName => 'الاسم';

  @override
  String get addBorrowedAmount => 'المبلغ';

  @override
  String get addBorrowedNotes => 'ملاحظات';

  @override
  String get addBorrowedMore => 'المزيد';

  @override
  String get addBorrowedDate => 'التاريخ';

  @override
  String get addBorrowedDueDate => 'تاريخ الاستحقاق';

  @override
  String get addBorrowedReturned => 'تم إرجاعه';

  @override
  String get addBorrowedMarkReturned => 'وضع علامة كمرجع';

  @override
  String get addSubscriptionPrice => 'السعر';

  @override
  String get addSubscriptionName => 'الاسم';

  @override
  String get addSubscriptionRecurrence => 'التكرار';

  @override
  String get addSubscriptionMore => 'المزيد';

  @override
  String get addSubscriptionNotes => 'ملاحظات';

  @override
  String get addSubscriptionStartDate => 'تاريخ البدء';

  @override
  String get addLentName => 'الاسم';

  @override
  String get addLentAmount => 'المبلغ';

  @override
  String get addLentNotes => 'ملاحظات';

  @override
  String get addLentMore => 'المزيد';

  @override
  String get addLentDate => 'التاريخ';

  @override
  String get addLentDueDate => 'تاريخ الاستحقاق';

  @override
  String get addLentReturned => 'تم إرجاعه';

  @override
  String get addLentMarkReturned => 'وضع علامة كمرجع';

  @override
  String get currencyPageTitle => 'أسعار العملات';

  @override
  String get profileVacationMode => 'وضع الإجازة';

  @override
  String get profileCurrency => 'العملة';

  @override
  String get profileLegal => 'قانوني';

  @override
  String get profileSupport => 'الدعم';

  @override
  String get profileDangerZone => 'منطقة الخطر';

  @override
  String get profileLogout => 'تسجيل الخروج';

  @override
  String get profileDeleteAccount => 'حذف الحساب';

  @override
  String get profileDeleteAccountTitle => 'حذف الحساب';

  @override
  String get profileDeleteAccountMessage =>
      'هل أنت متأكد من أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء. سيتم حذف جميع بياناتك بشكل دائم، بما في ذلك الحسابات والمعاملات والميزانيات والأهداف.';

  @override
  String get profileDeleteAccountConfirm => 'حذف';

  @override
  String get profileDeleteAccountSuccess => 'تم حذف الحساب بنجاح';

  @override
  String profileDeleteAccountError(String error) {
    return 'خطأ في حذف الحساب: $error';
  }

  @override
  String get homeIncome => 'الدخل';

  @override
  String get homeExpense => 'المصروف';

  @override
  String get expenseDetailPaidUnpaid => 'مدفوع/غير مدفوع';

  @override
  String get goalsScreenPendingGoals => 'الأهداف المعلقة';

  @override
  String get goalsScreenFulfilledGoals => 'الأهداف المحققة';

  @override
  String get transactionEditIncome => 'تعديل الدخل';

  @override
  String get transactionEditExpense => 'تعديل المصروف';

  @override
  String get transactionPlanIncome => 'تخطيط دخل';

  @override
  String get transactionPlanExpense => 'تخطيط مصروف';

  @override
  String get goal => 'الهدف';

  @override
  String get none => 'لا شيء';

  @override
  String get unnamedCategory => 'فئة غير مسماة';

  @override
  String get month => 'الشهر';

  @override
  String get daily => 'يومي';

  @override
  String get weekly => 'أسبوعي';

  @override
  String get monthly => 'شهري';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageSpanish => 'الإسبانية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageSelectLanguage => 'اختر اللغة';

  @override
  String get vacationCurrencyDialogTitle => 'عملة الإجازة';

  @override
  String vacationCurrencyDialogMessage(Object previousCurrency) {
    return 'يمكنك تغيير العملات لمعاملات إجازتك. هل ترغب في تغيير العملة الآن؟\n\nعملتك السابقة كانت $previousCurrency.';
  }

  @override
  String vacationCurrencyDialogKeepCurrent(Object previousCurrency) {
    return 'الإبقاء على الحالية ($previousCurrency)';
  }

  @override
  String get includeVacationTransaction => 'تضمين معاملات الإجازات';

  @override
  String get showVacationTransactions =>
      'إظهار معاملات الإجازات في الوضع العادي';

  @override
  String get balanceDetailTransactionsWillAppear =>
      'ستظهر معاملات هذا الحساب هنا';

  @override
  String get personalNextBilling => 'الفاتورة التالية';

  @override
  String get personalActive => 'نشط';

  @override
  String get personalInactive => 'غير نشط';

  @override
  String get personalReturned => 'تم إرجاعه';

  @override
  String get personalLent => 'مُقرض';

  @override
  String get personalDue => 'يستحق';

  @override
  String get personalItems => 'عنصر(ات)';

  @override
  String get status => 'الحالة';

  @override
  String get notReturned => 'لم يتم إرجاعه';

  @override
  String get borrowedOn => 'اقترض في';

  @override
  String get lentOn => 'أقرض في';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get resume => 'متابعة';

  @override
  String get upcomingBills => 'الفواتير القادمة';

  @override
  String get upcomingCharge => 'الرسوم القادمة';

  @override
  String get pastHistory => 'التاريخ السابق';

  @override
  String get noHistoryYet => 'لا يوجد تاريخ بعد';
}
