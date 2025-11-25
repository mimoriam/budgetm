// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get loginTitle => '로그인';

  @override
  String get loginSubtitle => '이메일과 비밀번호를 입력하여 로그인하세요';

  @override
  String get emailHint => '이메일';

  @override
  String get passwordHint => '비밀번호';

  @override
  String get rememberMe => '로그인 상태 유지';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get loginButton => '로그인';

  @override
  String get orLoginWith => '또는 다음으로 로그인';

  @override
  String get dontHaveAccount => '계정이 없으신가요?';

  @override
  String get signUp => '회원가입';

  @override
  String get forgotPasswordTitle => '비밀번호 찾기';

  @override
  String get forgotPasswordSubtitle => '비밀번호를 복구하려면 이메일 주소를 입력하세요';

  @override
  String get emailLabel => '이메일';

  @override
  String get confirmButton => '확인';

  @override
  String get passwordResetEmailSent => '비밀번호 재설정 이메일이 전송되었습니다. 받은편지함을 확인하세요.';

  @override
  String get getStartedTitle => '시작하기';

  @override
  String get createAccountSubtitle => '계속하려면 계정을 만드세요';

  @override
  String get nameHint => '이름';

  @override
  String get confirmPasswordHint => '비밀번호 확인';

  @override
  String get passwordsDoNotMatch => '비밀번호가 일치하지 않습니다';

  @override
  String get orContinueWith => '또는 다음으로 계속';

  @override
  String get continueWithGoogle => 'Google로 계속';

  @override
  String get continueWithApple => 'Apple로 계속';

  @override
  String get alreadyHaveAccount => '이미 계정이 있으신가요?';

  @override
  String get selectCurrencyTitle => '통화 선택';

  @override
  String get selectCurrencySubtitle => '선호하는 통화를 선택하세요';

  @override
  String get selectCurrencyLabel => '통화 선택';

  @override
  String get continueButton => '계속';

  @override
  String errorDuringSetup(Object error) {
    return '설정 중 오류: $error';
  }

  @override
  String get backButton => '뒤로';

  @override
  String get onboardingPage1Title => '더 스마트하게 저축하기';

  @override
  String get onboardingPage1Description =>
      '노력 없이 돈을 따로 모으고 매 단계마다 저축이 늘어나는 것을 지켜보세요.';

  @override
  String get onboardingPage2Title => '목표 달성하기';

  @override
  String get onboardingPage2Description =>
      '새로운 가젯부터 꿈의 여행까지 재정 목표를 만들고 진행 상황을 추적하세요.';

  @override
  String get onboardingPage3Title => '궤도 유지하기';

  @override
  String get onboardingPage3Description =>
      '지출, 수입, 저축을 하나의 간단한 대시보드에서 모두 모니터링하세요.';

  @override
  String get paywallCouldNotLoadPlans => '요금제를 불러올 수 없습니다.\n나중에 다시 시도해 주세요.';

  @override
  String get paywallChooseYourPlan => '요금제 선택';

  @override
  String get paywallInvestInFinancialFreedom => '오늘 당신의 재정 자유에 투자하세요';

  @override
  String paywallPricePerDay(Object price) {
    return '$price/일';
  }

  @override
  String paywallSaveAmount(Object amount) {
    return '$amount 절약';
  }

  @override
  String get paywallEverythingIncluded => '모든 것이 포함됩니다:';

  @override
  String get paywallPersonalizedBudgetInsights => '반복 예산 만들기';

  @override
  String get paywallDailyProgressTracking => '다중 계정 생성';

  @override
  String get paywallExpenseManagementTools => '개인화된 휴가 모드';

  @override
  String get paywallFinancialHealthTimeline => '색상 및 사용자 지정';

  @override
  String get paywallExpertGuidanceTips => '사용자 지정 카테고리';

  @override
  String get paywallCommunitySupportAccess => '커뮤니티 지원 액세스';

  @override
  String get paywallSaveYourFinances => '재정과 미래를 절약하세요';

  @override
  String get paywallAverageUserSaves =>
      '평균 사용자는 효과적인 예산 관리로 연간 약 £2,500를 절약합니다';

  @override
  String get paywallSubscribeYourPlan => '요금제 구독';

  @override
  String get paywallPleaseSelectPlan => '요금제를 선택해 주세요.';

  @override
  String get paywallSubscriptionActivated =>
      '구독이 활성화되었습니다! 이제 프리미엄 기능에 액세스할 수 있습니다.';

  @override
  String paywallFailedToPurchase(Object message) {
    return '구매 실패: $message';
  }

  @override
  String paywallUnexpectedError(Object error) {
    return '예기치 않은 오류가 발생했습니다: $error';
  }

  @override
  String get paywallRestorePurchases => '구매 복원';

  @override
  String get paywallManageSubscription => '구독 관리';

  @override
  String get paywallPurchasesRestoredSuccessfully => '구매가 성공적으로 복원되었습니다!';

  @override
  String get paywallNoActiveSubscriptionFound =>
      '활성 구독을 찾을 수 없습니다. 이제 무료 요금제입니다.';

  @override
  String get paywallPerMonth => '월';

  @override
  String get paywallPerYear => '년';

  @override
  String get paywallBestValue => '최고의 가치';

  @override
  String get paywallMostPopular => '가장 인기 있는';

  @override
  String get mainScreenHome => '홈';

  @override
  String get mainScreenBudget => '예산';

  @override
  String get mainScreenBalance => '잔액';

  @override
  String get mainScreenGoals => '목표';

  @override
  String get mainScreenPersonal => '개인';

  @override
  String get mainScreenIncome => '수입';

  @override
  String get mainScreenExpense => '지출';

  @override
  String get balanceTitle => '잔액';

  @override
  String get balanceAddAccount => '계정 추가';

  @override
  String get addAVacation => '휴가 추가';

  @override
  String get balanceMyAccounts => '내 계정';

  @override
  String get balanceVacation => '휴가';

  @override
  String get balanceAccountBalance => '계정 잔액';

  @override
  String get balanceNoAccountsFound => '계정을 찾을 수 없습니다.';

  @override
  String get balanceNoAccountsCreated => '생성된 계정 없음';

  @override
  String get balanceCreateFirstAccount => '잔액 추적을 시작하려면 첫 번째 계정을 만드세요';

  @override
  String get balanceCreateFirstAccountFinances =>
      '재정을 추적하기 시작하려면 첫 번째 계정을 만드세요';

  @override
  String get balanceNoVacationsYet => '아직 휴가 없음';

  @override
  String get balanceCreateFirstVacation => '여행 계획을 시작하려면 첫 번째 휴가 계정을 만드세요';

  @override
  String get balanceCreateVacationAccount => '휴가 계정 만들기';

  @override
  String get balanceSingleAccountView => '단일 계정 보기';

  @override
  String get balanceAddMoreAccounts => '차트를 보려면 더 많은 계정을 추가하세요';

  @override
  String get balanceNoAccountsForCurrency => '선택한 통화에 대한 계정을 찾을 수 없습니다';

  @override
  String balanceCreditLimit(Object value) {
    return '신용 한도: $value';
  }

  @override
  String balanceBalanceLimit(Object value) {
    return '잔액 한도: $value';
  }

  @override
  String get budgetTitle => '예산';

  @override
  String get budgetAddBudget => '예산 추가';

  @override
  String get budgetDaily => '일일';

  @override
  String get budgetWeekly => '주간';

  @override
  String get budgetMonthly => '월간';

  @override
  String get budgetSelectWeek => '주 선택';

  @override
  String get budgetSelectDate => '날짜 선택';

  @override
  String get budgetSelectDay => '일 선택';

  @override
  String get budgetCancel => '취소';

  @override
  String get budgetApply => '적용';

  @override
  String get budgetTotalSpending => '총 지출';

  @override
  String get budgetCategoryBreakdown => '카테고리별 분석';

  @override
  String get budgetViewAll => '전체 보기';

  @override
  String get budgetBudgets => '예산';

  @override
  String get budgetNoBudgetCreated => '생성된 예산 없음';

  @override
  String get budgetStartCreatingBudget => '지출 분석을 보려면 예산 만들기를 시작하세요.';

  @override
  String get budgetSetSpendingLimit => '지출 한도 설정';

  @override
  String get budgetEnterLimitAmount => '한도 금액 입력';

  @override
  String get budgetSave => '저장';

  @override
  String get budgetEnterValidNumber => '유효한 숫자를 입력하세요';

  @override
  String get budgetLimitSaved => '예산 한도가 저장되었습니다';

  @override
  String get budgetCreated => '예산이 생성되었습니다';

  @override
  String get budgetTransactions => '거래';

  @override
  String budgetOverBudget(Object amount) {
    return '예산 초과 $amount';
  }

  @override
  String budgetRemaining(Object amount) {
    return '남은 금액 $amount';
  }

  @override
  String get homeNoMoreTransactions => '더 이상 거래 없음';

  @override
  String get homeErrorLoadingMoreTransactions => '추가 거래를 불러오는 중 오류 발생';

  @override
  String get homeRetry => '다시 시도';

  @override
  String get homeErrorLoadingData => '데이터를 불러오는 중 오류 발생';

  @override
  String get homeNoTransactionsRecorded => '기록된 거래 없음';

  @override
  String get homeStartAddingTransactions => '지출 분석을 보려면 거래 추가를 시작하세요.';

  @override
  String get homeCurrencyChange => '통화 변경';

  @override
  String get homeCurrencyChangeMessage =>
      '통화를 변경하면 모든 기존 금액이 변환됩니다. 이 작업은 취소할 수 없습니다. 계속하시겠습니까?';

  @override
  String get homeNo => '아니오';

  @override
  String get homeYes => '예';

  @override
  String get homeVacationBudgetBreakdown => '휴가 예산 분석';

  @override
  String get homeBalanceBreakdown => '잔액 분석';

  @override
  String get homeClose => '닫기';

  @override
  String get transactionPickColor => '색상 선택';

  @override
  String get transactionSelectDate => '날짜 선택';

  @override
  String get transactionCancel => '취소';

  @override
  String get transactionApply => '적용';

  @override
  String get transactionAmount => '금액';

  @override
  String get transactionSelect => '선택';

  @override
  String get transactionPaid => '지불됨';

  @override
  String get transactionAddTransaction => '거래 추가';

  @override
  String get transactionEditTransaction => '거래 편집';

  @override
  String get transactionIncome => '수입';

  @override
  String get transactionExpense => '지출';

  @override
  String get transactionDescription => '설명';

  @override
  String get transactionCategory => '카테고리';

  @override
  String get transactionAccount => '계정';

  @override
  String get transactionDate => '날짜';

  @override
  String get transactionSave => '저장';

  @override
  String get transactionDelete => '삭제';

  @override
  String get transactionSuccess => '거래가 성공적으로 저장되었습니다';

  @override
  String get transactionError => '거래 저장 중 오류 발생';

  @override
  String get transactionDeleteConfirm => '이 거래를 삭제하시겠습니까?';

  @override
  String get transactionDeleteSuccess => '거래가 성공적으로 삭제되었습니다';

  @override
  String get goalsTitle => '목표';

  @override
  String get goalsAddGoal => '목표 추가';

  @override
  String get goalsNoGoalsCreated => '생성된 목표 없음';

  @override
  String get goalsStartCreatingGoal => '재정 진행 상황을 추적하려면 목표 만들기를 시작하세요';

  @override
  String get goalsCreateGoal => '목표 만들기';

  @override
  String get goalsEditGoal => '목표 편집';

  @override
  String get goalsGoalName => '목표 이름';

  @override
  String get goalsTargetAmount => '목표 금액';

  @override
  String get goalsCurrentAmount => '현재 금액';

  @override
  String get goalsDeadline => '마감일';

  @override
  String get goalsDescription => '설명';

  @override
  String get goalsSave => '저장';

  @override
  String get goalsCancel => '취소';

  @override
  String get goalsDelete => '삭제';

  @override
  String get goalsGoalCreated => '목표가 성공적으로 생성되었습니다';

  @override
  String get goalsGoalUpdated => '목표가 성공적으로 업데이트되었습니다';

  @override
  String get goalsGoalDeleted => '목표가 성공적으로 삭제되었습니다';

  @override
  String get goalsErrorSaving => '목표 저장 중 오류 발생';

  @override
  String get goalsDeleteConfirm => '이 목표를 삭제하시겠습니까?';

  @override
  String get goalsProgress => '진행 상황';

  @override
  String get goalsCompleted => '완료됨';

  @override
  String get goalsInProgress => '진행 중';

  @override
  String get goalsNotStarted => '시작하지 않음';

  @override
  String get profileTitle => '프로필';

  @override
  String get profilePremiumActive => '프리미엄 활성';

  @override
  String get profilePremiumDescription => '모든 프리미엄 기능에 액세스할 수 있습니다';

  @override
  String get profileFreePlan => '무료 요금제';

  @override
  String get profileUpgradeDescription => '고급 기능을 위해 프리미엄으로 업그레이드하세요';

  @override
  String profileRenewalDate(Object date) {
    return '$date에 갱신';
  }

  @override
  String profileExpiresOn(Object date) {
    return '$date에 만료';
  }

  @override
  String profileErrorSigningOut(Object error) {
    return '로그아웃 중 오류: $error';
  }

  @override
  String get profileUserNotFound => '사용자를 찾을 수 없습니다';

  @override
  String get profileEditDisplayName => '표시 이름 편집';

  @override
  String get profileCancel => '취소';

  @override
  String get profileSave => '저장';

  @override
  String get profileDisplayNameUpdated => '표시 이름이 성공적으로 업데이트되었습니다';

  @override
  String get profileErrorUpdatingName => '표시 이름 업데이트 중 오류 발생';

  @override
  String get profileManageSubscription => '구독 관리';

  @override
  String get profileRestorePurchases => '구매 복원';

  @override
  String get profileRefreshStatus => '상태 새로고침';

  @override
  String get profileSubscriptionRefreshed => '구독 상태가 새로고침되었습니다';

  @override
  String get profileSignOut => '로그아웃';

  @override
  String get profileSignOutConfirm => '로그아웃하시겠습니까?';

  @override
  String get profileCurrencyRates => '환율';

  @override
  String get profileCategories => '카테고리';

  @override
  String get profileFeedback => '피드백';

  @override
  String get profileExportData => '데이터 내보내기';

  @override
  String get profileSettings => '설정';

  @override
  String get profileAccount => '계정';

  @override
  String get profileDisplayName => '표시 이름';

  @override
  String get profileEmail => '이메일';

  @override
  String get profileSubscription => '구독';

  @override
  String get profileVersion => '버전';

  @override
  String get personalTitle => '개인';

  @override
  String get personalSubscriptions => '구독';

  @override
  String get personalBorrowed => '빌린 것';

  @override
  String get personalAddSubscription => '구독 추가';

  @override
  String get personalAddLent => '빌려준 것 추가';

  @override
  String get personalAddBorrowed => '빌린 것 추가';

  @override
  String get personalNoSubscriptions => '구독을 찾을 수 없습니다';

  @override
  String get personalNoLent => '빌려준 항목을 찾을 수 없습니다';

  @override
  String get personalNoBorrowed => '빌린 항목을 찾을 수 없습니다';

  @override
  String get personalStartAddingSubscription => '반복 결제를 추적하려면 구독 추가를 시작하세요';

  @override
  String get personalStartAddingLent => '빌려준 돈을 추적하려면 빌려준 항목 추가를 시작하세요';

  @override
  String get personalStartAddingBorrowed => '빌린 돈을 추적하려면 빌린 항목 추가를 시작하세요';

  @override
  String get personalEdit => '편집';

  @override
  String get personalDelete => '삭제';

  @override
  String get personalMarkAsPaid => '지불됨으로 표시';

  @override
  String get personalMarkAsUnpaid => '미지불로 표시';

  @override
  String get personalAmount => '금액';

  @override
  String get personalDescription => '설명';

  @override
  String get personalDueDate => '만기일';

  @override
  String get personalRecurring => '반복';

  @override
  String get personalOneTime => '일회성';

  @override
  String get personalMonthly => '월간';

  @override
  String get personalYearly => '연간';

  @override
  String get personalWeekly => '주간';

  @override
  String get personalDaily => '일일';

  @override
  String get personalName => '이름';

  @override
  String get personalCategory => '카테고리';

  @override
  String get personalNotes => '메모';

  @override
  String get personalSave => '저장';

  @override
  String get personalCancel => '취소';

  @override
  String get personalDeleteConfirm => '이 항목을 삭제하시겠습니까?';

  @override
  String get personalItemSaved => '항목이 성공적으로 저장되었습니다';

  @override
  String get personalItemDeleted => '항목이 성공적으로 삭제되었습니다';

  @override
  String get personalErrorSaving => '항목 저장 중 오류 발생';

  @override
  String get personalErrorDeleting => '항목 삭제 중 오류 발생';

  @override
  String get analyticsTitle => '분석';

  @override
  String get analyticsOverview => '개요';

  @override
  String get analyticsIncome => '수입';

  @override
  String get analyticsExpenses => '지출';

  @override
  String get analyticsSavings => '저축';

  @override
  String get analyticsCategories => '카테고리';

  @override
  String get analyticsTrends => '추세';

  @override
  String get analyticsMonthly => '월간';

  @override
  String get analyticsWeekly => '주간';

  @override
  String get analyticsDaily => '일일';

  @override
  String get analyticsYearly => '연간';

  @override
  String get analyticsNoData => '사용 가능한 데이터 없음';

  @override
  String get analyticsStartTracking => '분석을 보려면 재정 추적을 시작하세요';

  @override
  String get analyticsTotalIncome => '총 수입';

  @override
  String get analyticsTotalExpenses => '총 지출';

  @override
  String get analyticsNetSavings => '순 저축';

  @override
  String get analyticsTopCategories => '상위 카테고리';

  @override
  String get analyticsSpendingTrends => '지출 추세';

  @override
  String get analyticsIncomeTrends => '수입 추세';

  @override
  String get analyticsSavingsRate => '저축률';

  @override
  String get analyticsAverageDaily => '일평균';

  @override
  String get analyticsAverageWeekly => '주평균';

  @override
  String get analyticsAverageMonthly => '월평균';

  @override
  String get analyticsSelectPeriod => '기간 선택';

  @override
  String get analyticsExportData => '데이터 내보내기';

  @override
  String get analyticsRefresh => '새로고침';

  @override
  String get analyticsErrorLoading => '분석 데이터를 불러오는 중 오류 발생';

  @override
  String get analyticsRetry => '다시 시도';

  @override
  String get goalsSelectColor => '색상 선택';

  @override
  String get goalsMore => '더보기';

  @override
  String get goalsName => '목표 이름';

  @override
  String get goalsColor => '색상';

  @override
  String get goalsNameRequired => '목표 이름이 필요합니다';

  @override
  String get goalsAmountRequired => '목표 금액이 필요합니다';

  @override
  String get goalsAmountMustBePositive => '목표 금액은 0보다 커야 합니다';

  @override
  String get goalsDeadlineRequired => '마감일이 필요합니다';

  @override
  String get goalsDeadlineMustBeFuture => '마감일은 미래여야 합니다';

  @override
  String get goalsNameAlreadyExists => '이 이름을 가진 목표가 이미 존재합니다';

  @override
  String goalsErrorCreating(Object error) {
    return '목표 생성 중 오류: $error';
  }

  @override
  String goalsErrorUpdating(Object error) {
    return '목표 업데이트 중 오류: $error';
  }

  @override
  String goalsErrorDeleting(Object error) {
    return '목표 삭제 중 오류: $error';
  }

  @override
  String get expenseDetailTitle => '지출 상세';

  @override
  String get expenseDetailEdit => '편집';

  @override
  String get expenseDetailDelete => '삭제';

  @override
  String get expenseDetailAmount => '금액';

  @override
  String get expenseDetailCategory => '카테고리';

  @override
  String get expenseDetailAccount => '계정';

  @override
  String get expenseDetailDate => '날짜';

  @override
  String get expenseDetailDescription => '설명';

  @override
  String get expenseDetailNotes => '메모';

  @override
  String get expenseDetailSave => '저장';

  @override
  String get expenseDetailCancel => '취소';

  @override
  String get expenseDetailDeleteConfirm => '이 지출을 삭제하시겠습니까?';

  @override
  String get expenseDetailUpdated => '지출이 성공적으로 업데이트되었습니다';

  @override
  String get expenseDetailDeleted => '지출이 성공적으로 삭제되었습니다';

  @override
  String get expenseDetailErrorSaving => '지출 저장 중 오류 발생';

  @override
  String get expenseDetailErrorDeleting => '지출 삭제 중 오류 발생';

  @override
  String get calendarTitle => '캘린더';

  @override
  String get calendarSelectDate => '날짜 선택';

  @override
  String get calendarToday => '오늘';

  @override
  String get calendarThisWeek => '이번 주';

  @override
  String get calendarThisMonth => '이번 달';

  @override
  String get calendarThisYear => '올해';

  @override
  String get calendarNoTransactions => '이 날짜에 거래 없음';

  @override
  String get calendarStartAddingTransactions => '캘린더에서 거래를 보려면 거래 추가를 시작하세요';

  @override
  String get vacationDialogTitle => '휴가 모드';

  @override
  String get vacationDialogEnable => '휴가 모드 활성화';

  @override
  String get vacationDialogDisable => '휴가 모드 비활성화';

  @override
  String get vacationDialogDescription => '휴가 모드는 여행 및 휴일 중 지출을 추적하는 데 도움이 됩니다';

  @override
  String get vacationDialogCancel => '취소';

  @override
  String get vacationDialogConfirm => '확인';

  @override
  String get vacationDialogEnabled => '휴가 모드가 활성화되었습니다';

  @override
  String get vacationDialogDisabled => '휴가 모드가 비활성화되었습니다';

  @override
  String get balanceDetailTitle => '계정 상세';

  @override
  String get balanceDetailEdit => '편집';

  @override
  String get balanceDetailDelete => '삭제';

  @override
  String get balanceDetailTransactions => '거래';

  @override
  String get balanceDetailBalance => '잔액';

  @override
  String get balanceDetailCreditLimit => '신용 한도';

  @override
  String get balanceDetailBalanceLimit => '잔액 한도';

  @override
  String get balanceDetailCurrency => '통화';

  @override
  String get balanceDetailAccountType => '계정 유형';

  @override
  String get balanceDetailAccountName => '계정 이름';

  @override
  String get balanceDetailSave => '저장';

  @override
  String get balanceDetailCancel => '취소';

  @override
  String get balanceDetailDeleteConfirm => '이 계정을 삭제하시겠습니까?';

  @override
  String get balanceDetailUpdated => '계정이 성공적으로 업데이트되었습니다';

  @override
  String get balanceDetailDeleted => '계정이 성공적으로 삭제되었습니다';

  @override
  String get balanceDetailErrorSaving => '계정 저장 중 오류 발생';

  @override
  String get balanceDetailErrorDeleting => '계정 삭제 중 오류 발생';

  @override
  String get addAccountTitle => '계정 추가';

  @override
  String get addAccountEditTitle => '계정 편집';

  @override
  String get addAccountName => '계정 이름';

  @override
  String get addAccountType => '계정 유형';

  @override
  String get addAccountCurrency => '통화';

  @override
  String get addAccountInitialBalance => '초기 잔액';

  @override
  String get addAccountCreditLimit => '신용 한도';

  @override
  String get addAccountBalanceLimit => '잔액 한도';

  @override
  String get addAccountColor => '색상';

  @override
  String get addAccountIcon => '아이콘';

  @override
  String get addAccountSave => '저장';

  @override
  String get addAccountCancel => '취소';

  @override
  String get addAccountCreated => '계정이 성공적으로 생성되었습니다';

  @override
  String get addAccountUpdated => '계정이 성공적으로 업데이트되었습니다';

  @override
  String get addAccountErrorSaving => '계정 저장 중 오류 발생';

  @override
  String get addAccountNameRequired => '계정 이름이 필요합니다';

  @override
  String get addAccountTypeRequired => '계정 유형이 필요합니다';

  @override
  String get addAccountCurrencyRequired => '통화가 필요합니다';

  @override
  String get budgetDetailTitle => '예산 상세';

  @override
  String get budgetDetailEdit => '편집';

  @override
  String get budgetDetailDelete => '삭제';

  @override
  String get budgetDetailSpending => '지출';

  @override
  String get budgetDetailLimit => '한도';

  @override
  String get budgetDetailRemaining => '남은 금액';

  @override
  String get budgetDetailOverBudget => '예산 초과';

  @override
  String get budgetDetailCategories => '카테고리';

  @override
  String get budgetDetailTransactions => '거래';

  @override
  String get budgetDetailSave => '저장';

  @override
  String get budgetDetailCancel => '취소';

  @override
  String get budgetDetailDeleteConfirm => '이 예산을 삭제하시겠습니까?';

  @override
  String get budgetDetailUpdated => '예산이 성공적으로 업데이트되었습니다';

  @override
  String get budgetDetailDeleted => '예산이 성공적으로 삭제되었습니다';

  @override
  String get budgetDetailErrorSaving => '예산 저장 중 오류 발생';

  @override
  String get budgetDetailErrorDeleting => '예산 삭제 중 오류 발생';

  @override
  String get addBudgetTitle => '예산 추가';

  @override
  String get addBudgetEditTitle => '예산 편집';

  @override
  String get addBudgetName => '예산 이름';

  @override
  String get addBudgetType => '예산 유형';

  @override
  String get addBudgetAmount => '금액';

  @override
  String get addBudgetCurrency => '통화';

  @override
  String get addBudgetPeriod => '기간';

  @override
  String get addBudgetCategories => '카테고리';

  @override
  String get addBudgetColor => '색상';

  @override
  String get addBudgetSave => '저장';

  @override
  String get addBudgetSaveBudget => '예산 저장';

  @override
  String get addBudgetCancel => '취소';

  @override
  String get addBudgetCreated => '예산이 성공적으로 생성되었습니다';

  @override
  String get addBudgetUpdated => '예산이 성공적으로 업데이트되었습니다';

  @override
  String get addBudgetErrorSaving => '예산 저장 중 오류 발생';

  @override
  String get addBudgetNameRequired => '예산 이름이 필요합니다';

  @override
  String get addBudgetAmountRequired => '예산 금액이 필요합니다';

  @override
  String get addBudgetAmountMustBePositive => '예산 금액은 0보다 커야 합니다';

  @override
  String get addBudgetCategoryRequired => '카테고리를 선택해 주세요';

  @override
  String get budgetDetailNoBudgetToDelete =>
      '삭제할 예산이 없습니다. 이것은 거래를 위한 플레이스홀더일 뿐입니다.';

  @override
  String get personalItemDetails => '항목 상세';

  @override
  String get personalStartDateRequired => '시작 날짜를 선택해 주세요';

  @override
  String get profileMainCurrency => '주요 통화';

  @override
  String get profileFeedbackThankYou => '피드백을 주셔서 감사합니다!';

  @override
  String get profileFeedbackEmailError => '이메일 클라이언트를 열 수 없습니다.';

  @override
  String get feedbackModalTitle => '앱을 즐기고 계신가요?';

  @override
  String get feedbackModalDescription =>
      '귀하의 피드백은 우리에게 동기를 부여하고 개선하는 데 도움이 됩니다.';

  @override
  String get goalNameAlreadyExistsSnackbar => '이 이름을 가진 목표가 이미 존재합니다';

  @override
  String get lentSelectBothDates => '날짜와 만기일을 모두 선택해 주세요';

  @override
  String get lentDueDateBeforeLentDate => '만기일은 빌려준 날짜보다 이전일 수 없습니다';

  @override
  String get lentItemAddedSuccessfully => '빌려준 항목이 성공적으로 추가되었습니다';

  @override
  String lentItemError(Object error) {
    return '오류: $error';
  }

  @override
  String get borrowedSelectBothDates => '날짜와 만기일을 모두 선택해 주세요';

  @override
  String get borrowedDueDateBeforeBorrowedDate => '만기일은 빌린 날짜보다 이전일 수 없습니다';

  @override
  String get borrowedItemAddedSuccessfully => '빌린 항목이 성공적으로 추가되었습니다';

  @override
  String borrowedItemError(Object error) {
    return '오류: $error';
  }

  @override
  String get subscriptionCreatedSuccessfully => '구독이 성공적으로 생성되었습니다';

  @override
  String subscriptionError(Object error) {
    return '오류: $error';
  }

  @override
  String get paymentMarkedSuccessfully => '결제가 성공적으로 표시되었습니다';

  @override
  String get subscriptionContinued => '구독이 성공적으로 계속되었습니다';

  @override
  String get subscriptionPaused => '구독이 성공적으로 일시 중지되었습니다';

  @override
  String get itemMarkedAsReturnedSuccessfully => '항목이 성공적으로 반환됨으로 표시되었습니다';

  @override
  String get itemDeletedSuccessfully => '항목이 성공적으로 삭제되었습니다';

  @override
  String get failedToDeleteBudget => '예산 삭제 실패';

  @override
  String get failedToDeleteGoal => '목표 삭제 실패';

  @override
  String failedToSaveTransaction(Object error) {
    return '거래 저장 실패: $error';
  }

  @override
  String get failedToReorderCategories => '카테고리 재정렬 실패. 변경 사항을 되돌리는 중입니다.';

  @override
  String get categoryAddedSuccessfully => '카테고리가 성공적으로 추가되었습니다';

  @override
  String failedToAddCategory(Object error) {
    return '카테고리 추가 실패: $error';
  }

  @override
  String get addCategory => '카테고리 추가';

  @override
  String errorCreatingGoal(Object error) {
    return '목표 생성 중 오류: $error';
  }

  @override
  String get hintName => '이름';

  @override
  String get hintDescription => '설명';

  @override
  String get hintSelectDate => '날짜 선택';

  @override
  String get hintSelectDueDate => '만기일 선택';

  @override
  String get hintSelectCategory => '카테고리 선택';

  @override
  String get hintSelectAccount => '계정 선택';

  @override
  String get hintSelectGoal => '목표 선택';

  @override
  String get hintNotes => '메모';

  @override
  String get hintSelectColor => '색상 선택';

  @override
  String get hintEnterCategoryName => '카테고리 이름 입력';

  @override
  String get hintSelectType => '유형 선택';

  @override
  String get hintWriteThoughts => '여기에 생각을 적어보세요......';

  @override
  String get hintEnterDisplayName => '표시 이름 입력';

  @override
  String get hintSelectBudgetType => '예산 유형 선택';

  @override
  String get hintSelectAccountType => '계정 유형 선택';

  @override
  String get hintEnterName => '이름 입력';

  @override
  String get hintSelectIcon => '아이콘 선택';

  @override
  String get hintSelect => '선택';

  @override
  String get hintAmountPlaceholder => '0.00';

  @override
  String get labelValue => '값';

  @override
  String get labelName => '이름';

  @override
  String get labelDescription => '설명';

  @override
  String get labelCategory => '카테고리';

  @override
  String get labelDate => '날짜';

  @override
  String get labelDueDate => '만기일';

  @override
  String get labelColor => '색상';

  @override
  String get labelNotes => '메모';

  @override
  String get labelAccount => '계정';

  @override
  String get labelMore => '더보기';

  @override
  String get labelHome => '홈';

  @override
  String get titlePickColor => '색상 선택';

  @override
  String get titleAddLentItem => '빌려준 항목 추가';

  @override
  String get titleAddBorrowedItem => '빌린 항목 추가';

  @override
  String get titleSelectCategory => '카테고리 선택';

  @override
  String get titleSelectAccount => '계정 선택';

  @override
  String get titleSelectGoal => '목표 선택';

  @override
  String get titleSelectType => '유형 선택';

  @override
  String get titleSelectAccountType => '계정 유형 선택';

  @override
  String get titleSelectBudgetType => '예산 유형 선택';

  @override
  String get validationNameRequired => '이름이 필요합니다';

  @override
  String get validationAmountRequired => '금액이 필요합니다';

  @override
  String get validationPleaseEnterValidNumber => '유효한 숫자를 입력해 주세요';

  @override
  String get validationPleaseSelectIcon => '아이콘을 선택해 주세요';

  @override
  String get buttonCancel => '취소';

  @override
  String get buttonAdd => '추가';

  @override
  String get buttonSave => '저장';

  @override
  String get switchAddProgress => '진행 상황 추가';

  @override
  String get pickColor => '색상 선택';

  @override
  String get name => '이름';

  @override
  String get itemName => '항목 이름';

  @override
  String get account => '계정';

  @override
  String get selectIcon => '아이콘을 선택해 주세요';

  @override
  String get value => '값';

  @override
  String get hintAmount => '0.00';

  @override
  String get hintItemName => '항목 이름';

  @override
  String get amountRequired => '금액이 필요합니다';

  @override
  String get validNumber => '유효한 숫자를 입력해 주세요';

  @override
  String get category => '카테고리';

  @override
  String get date => '날짜';

  @override
  String get dueDate => '만기일';

  @override
  String get color => '색상';

  @override
  String get notes => '메모';

  @override
  String get selectColor => '색상 선택';

  @override
  String get more => '더보기';

  @override
  String get addLentItem => '빌려준 항목 추가';

  @override
  String get addBorrowedItem => '빌린 항목 추가';

  @override
  String get cancel => '취소';

  @override
  String get add => '추가';

  @override
  String get nameRequired => '이름이 필요합니다';

  @override
  String get buttonOk => '확인';

  @override
  String get vacationNoAccountsAvailable => '사용 가능한 휴가 계정이 없습니다.';

  @override
  String get exportFormat => '형식';

  @override
  String get exportOptions => '옵션';

  @override
  String get exportAccountData => '계정 데이터 내보내기';

  @override
  String get exportGoalsData => '목표 데이터 내보내기';

  @override
  String get exportCurrentMonth => '이번 달';

  @override
  String get exportLast30Days => '최근 30일';

  @override
  String get exportLast90Days => '최근 90일';

  @override
  String get exportLast365Days => '최근 365일';

  @override
  String get exportCsv => 'CSV';

  @override
  String get exportJson => 'JSON';

  @override
  String get exportImportInstructions => 'CSV 파일에서 앱으로 데이터를 가져올 수 있습니다.';

  @override
  String get exportInstructions1 => '예제 파일을 저장하여 필요한 데이터 형식을 확인하세요;';

  @override
  String get exportInstructions2 =>
      '템플릿에 따라 데이터를 형식화하세요. 열, 순서 및 이름이 템플릿과 정확히 동일한지 확인하세요. 열 이름은 영어여야 합니다;';

  @override
  String get exportInstructions3 => '가져오기를 누르고 파일을 선택하세요;';

  @override
  String get exportInstructions4 =>
      '기존 데이터를 덮어쓸지 또는 가져온 데이터를 기존 데이터에 추가할지 선택하세요. 덮어쓰기 옵션을 선택하면 기존 데이터가 영구적으로 삭제됩니다;';

  @override
  String get exportButtonExport => '내보내기';

  @override
  String get exportButtonImport => '가져오기';

  @override
  String get exportTabExport => '내보내기';

  @override
  String get exportTabImport => '가져오기';

  @override
  String get enableVacationMode => '휴가 모드 활성화';

  @override
  String get addProgress => '진행 상황 추가';

  @override
  String get pleaseEnterValidNumber => '유효한 숫자를 입력해 주세요';

  @override
  String get pleaseSelectCategory => '카테고리를 선택해 주세요';

  @override
  String get pleaseSelectCurrency => '통화를 선택해 주세요';

  @override
  String get pleaseSelectAccount => '계정을 선택해 주세요';

  @override
  String get pleaseSelectDate => '날짜를 선택해 주세요';

  @override
  String get pleaseSelectIcon => '아이콘을 선택해 주세요';

  @override
  String get deleteCategory => '카테고리 삭제';

  @override
  String get markAsReturned => '반환됨으로 표시';

  @override
  String get markPayment => '결제 표시';

  @override
  String get markPaid => '지불됨으로 표시';

  @override
  String get deleteItem => '항목 삭제';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get deleteAllAssociatedTransactions => '관련된 모든 거래 삭제';

  @override
  String get normalMode => '일반 모드';

  @override
  String normalModeWithCurrency(String currency) {
    return '이제 통화 $currency로 일반 모드입니다';
  }

  @override
  String get changeCurrency => '통화 변경';

  @override
  String get vacationModeDialog => '휴가 모드 대화상자';

  @override
  String get categoryAndTransactionsDeleted => '카테고리 및 관련 거래가 성공적으로 삭제되었습니다';

  @override
  String get select => '선택';

  @override
  String get delete => '삭제';

  @override
  String get confirm => '확인';

  @override
  String get yourData => '귀하의 데이터';

  @override
  String get profileMenuAccount => '계정';

  @override
  String get profileMenuCurrency => '통화';

  @override
  String get profileSectionLegal => '법적 고지';

  @override
  String get profileTermsConditions => '이용 약관';

  @override
  String get profilePrivacyPolicy => '개인정보 보호정책';

  @override
  String get profileSectionSupport => '지원';

  @override
  String get profileHelpSupport => '도움말 및 지원';

  @override
  String get profileSectionDanger => '위험 구역';

  @override
  String get currencyPageChange => '변경';

  @override
  String get addTransactionNotes => '메모';

  @override
  String get addTransactionMore => '더보기';

  @override
  String get addTransactionDate => '날짜';

  @override
  String get addTransactionTime => '시간';

  @override
  String get addTransactionPaid => '지불됨';

  @override
  String get addTransactionColor => '색상';

  @override
  String get addTransactionCancel => '취소';

  @override
  String get addTransactionCreate => '만들기';

  @override
  String get addTransactionUpdate => '업데이트';

  @override
  String get addBudgetLimitAmount => '한도 금액';

  @override
  String get addBudgetSelectCategory => '카테고리 선택';

  @override
  String get addBudgetBudgetType => '예산 유형';

  @override
  String get addBudgetRecurring => '반복 예산';

  @override
  String get addBudgetRecurringSubtitle => '각 기간마다 이 예산을 자동으로 갱신';

  @override
  String get addBudgetRecurringDailySubtitle => '매일 적용';

  @override
  String get addBudgetRecurringPremiumSubtitle => '프리미엄 기능 - 구독하여 활성화';

  @override
  String get addBudget => '예산 추가';

  @override
  String get addAccountTransactionLimit => '거래 한도';

  @override
  String get addAccountAccountType => '계정 유형';

  @override
  String get addAccountAdd => '추가';

  @override
  String get addAccountBalance => '잔액';

  @override
  String get addAccountCredit => '신용';

  @override
  String get homeIncomeCard => '수입';

  @override
  String get homeExpenseCard => '지출';

  @override
  String get homeTotalBudget => '총 예산';

  @override
  String get balanceDetailInitialBalance => '초기 잔액';

  @override
  String get balanceDetailCurrentBalance => '현재 잔액';

  @override
  String get expenseDetailTotal => '총계';

  @override
  String get expenseDetailAccumulatedAmount => '누적 금액';

  @override
  String get expenseDetailPaidStatus => '지불됨/미지불';

  @override
  String get expenseDetailVacation => '휴가';

  @override
  String get expenseDetailMarkPaid => '지불됨으로 표시';

  @override
  String get expenseDetailMarkUnpaid => '미지불로 표시';

  @override
  String get goalsScreenPending => '대기 중인 목표';

  @override
  String get goalsScreenFulfilled => '달성한 목표';

  @override
  String get createGoalTitle => '대기 중인 목표 만들기';

  @override
  String get createGoalAmount => '금액';

  @override
  String get createGoalName => '이름';

  @override
  String get createGoalCurrency => '통화';

  @override
  String get createGoalMore => '더보기';

  @override
  String get createGoalNotes => '메모';

  @override
  String get createGoalDate => '날짜';

  @override
  String get createGoalColor => '색상';

  @override
  String get createGoalLimitReached =>
      '목표 한도에 도달했습니다. 프리미엄으로 업그레이드하여 무제한 목표를 만들 수 있습니다.';

  @override
  String get personalScreenSubscriptions => '구독';

  @override
  String get personalScreenBorrowed => '빌린 것';

  @override
  String get personalScreenLent => '빌려준 것';

  @override
  String get personalScreenTotal => '총계';

  @override
  String get personalScreenActive => '활성';

  @override
  String get personalScreenNoSubscriptions => '아직 구독 없음';

  @override
  String get personalScreenNoBorrowed => '아직 빌린 항목 없음';

  @override
  String get personalScreenBorrowedItems => '빌린 항목';

  @override
  String get personalScreenLentItems => '빌려준 항목';

  @override
  String get personalScreenNoLent => '아직 빌려준 항목 없음';

  @override
  String get addBorrowedTitle => '빌린 항목 추가';

  @override
  String get addLentTitle => '빌려준 항목 추가';

  @override
  String get addBorrowedName => '이름';

  @override
  String get addBorrowedAmount => '금액';

  @override
  String get addBorrowedNotes => '메모';

  @override
  String get addBorrowedMore => '더보기';

  @override
  String get addBorrowedDate => '날짜';

  @override
  String get addBorrowedDueDate => '만기일';

  @override
  String get addBorrowedReturned => '반환됨';

  @override
  String get addBorrowedMarkReturned => '반환됨으로 표시';

  @override
  String get addSubscriptionPrice => '가격';

  @override
  String get addSubscriptionName => '이름';

  @override
  String get addSubscriptionRecurrence => '반복';

  @override
  String get addSubscriptionMore => '더보기';

  @override
  String get addSubscriptionNotes => '메모';

  @override
  String get addSubscriptionStartDate => '시작 날짜';

  @override
  String get addLentName => '이름';

  @override
  String get addLentAmount => '금액';

  @override
  String get addLentNotes => '메모';

  @override
  String get addLentMore => '더보기';

  @override
  String get addLentDate => '날짜';

  @override
  String get addLentDueDate => '만기일';

  @override
  String get addLentReturned => '반환됨';

  @override
  String get addLentMarkReturned => '반환됨으로 표시';

  @override
  String get currencyPageTitle => '환율';

  @override
  String get profileVacationMode => '휴가 모드';

  @override
  String get profileCurrency => '통화';

  @override
  String get profileLegal => '법적 고지';

  @override
  String get profileSupport => '지원';

  @override
  String get profileDangerZone => '위험 구역';

  @override
  String get profileLogout => '로그아웃';

  @override
  String get profileDeleteAccount => '계정 삭제';

  @override
  String get profileDeleteAccountTitle => '계정 삭제';

  @override
  String get profileDeleteAccountMessage =>
      '계정을 삭제하시겠습니까? 이 작업은 취소할 수 없습니다. 계정, 거래, 예산 및 목표를 포함한 모든 데이터가 영구적으로 삭제됩니다.';

  @override
  String get profileDeleteAccountConfirm => '삭제';

  @override
  String get profileDeleteAccountSuccess => '계정이 성공적으로 삭제되었습니다';

  @override
  String profileDeleteAccountError(String error) {
    return '계정 삭제 중 오류: $error';
  }

  @override
  String get homeIncome => '수입';

  @override
  String get homeExpense => '지출';

  @override
  String get expenseDetailPaidUnpaid => '지불됨/미지불';

  @override
  String get goalsScreenPendingGoals => '대기 중인 목표';

  @override
  String get goalsScreenFulfilledGoals => '달성한 목표';

  @override
  String get transactionEditIncome => '수입 편집';

  @override
  String get transactionEditExpense => '지출 편집';

  @override
  String get transactionPlanIncome => '수입 계획';

  @override
  String get transactionPlanExpense => '지출 계획';

  @override
  String get goal => '목표';

  @override
  String get none => '없음';

  @override
  String get unnamedCategory => '이름 없는 카테고리';

  @override
  String get month => '월';

  @override
  String get daily => '일일';

  @override
  String get weekly => '주간';

  @override
  String get monthly => '월간';

  @override
  String get profileLanguage => '언어';

  @override
  String get languageEnglish => '영어';

  @override
  String get languageSpanish => '스페인어';

  @override
  String get languageArabic => '아랍어';

  @override
  String get languageSelectLanguage => '언어 선택';

  @override
  String get vacationCurrencyDialogTitle => '휴가 통화';

  @override
  String vacationCurrencyDialogMessage(Object previousCurrency) {
    return '휴가 거래의 통화를 변경할 수 있습니다. 지금 통화를 변경하시겠습니까?\n\n이전 통화는 $previousCurrency였습니다.';
  }

  @override
  String vacationCurrencyDialogKeepCurrent(Object previousCurrency) {
    return '현재 유지 ($previousCurrency)';
  }

  @override
  String get includeVacationTransaction => '휴가 거래 포함';

  @override
  String get showVacationTransactions => '일반 모드에서 휴가 거래 표시';

  @override
  String get balanceDetailTransactionsWillAppear => '이 계정의 거래가 여기에 표시됩니다';

  @override
  String get personalNextBilling => '다음 청구';

  @override
  String get personalActive => '활성';

  @override
  String get personalInactive => '비활성';

  @override
  String get personalReturned => '반환됨';

  @override
  String get personalLent => '빌려준 것';

  @override
  String get personalDue => '만기';

  @override
  String get personalItems => '항목';

  @override
  String get status => '상태';

  @override
  String get notReturned => '반환되지 않음';

  @override
  String get borrowedOn => '빌린 날짜';

  @override
  String get lentOn => '빌려준 날짜';

  @override
  String get pause => '일시 중지';

  @override
  String get resume => '계속';

  @override
  String get upcomingBills => '다가오는 청구서';

  @override
  String get upcomingCharge => '다가오는 요금';

  @override
  String get pastHistory => '과거 내역';

  @override
  String get noHistoryYet => '아직 내역 없음';

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
