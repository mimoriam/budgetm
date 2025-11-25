// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get loginTitle => 'ログイン';

  @override
  String get loginSubtitle => 'メールアドレスとパスワードを入力してログインしてください';

  @override
  String get emailHint => 'メールアドレス';

  @override
  String get passwordHint => 'パスワード';

  @override
  String get rememberMe => 'ログイン情報を記憶する';

  @override
  String get forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get loginButton => 'ログイン';

  @override
  String get orLoginWith => 'または、以下でログイン';

  @override
  String get dontHaveAccount => 'アカウントをお持ちでないですか？';

  @override
  String get signUp => '新規登録';

  @override
  String get forgotPasswordTitle => 'パスワードを忘れた場合';

  @override
  String get forgotPasswordSubtitle => 'パスワードを回復するためにメールアドレスを入力してください';

  @override
  String get emailLabel => 'メールアドレス';

  @override
  String get confirmButton => '確認';

  @override
  String get passwordResetEmailSent => 'パスワードリセットメールを送信しました。受信トレイをご確認ください。';

  @override
  String get getStartedTitle => '始めましょう';

  @override
  String get createAccountSubtitle => '続けるにはアカウントを作成してください';

  @override
  String get nameHint => '名前';

  @override
  String get confirmPasswordHint => 'パスワードを再確認';

  @override
  String get passwordsDoNotMatch => 'パスワードが一致しません';

  @override
  String get orContinueWith => 'または、以下で続行';

  @override
  String get continueWithGoogle => 'Googleで続行';

  @override
  String get continueWithApple => 'Appleで続行';

  @override
  String get alreadyHaveAccount => 'すでにアカウントをお持ちですか？';

  @override
  String get selectCurrencyTitle => '通貨を選択';

  @override
  String get selectCurrencySubtitle => 'ご希望の通貨を選択してください';

  @override
  String get selectCurrencyLabel => '通貨を選択';

  @override
  String get continueButton => '続行';

  @override
  String errorDuringSetup(Object error) {
    return '設定中にエラーが発生しました: $error';
  }

  @override
  String get backButton => '戻る';

  @override
  String get onboardingPage1Title => '賢く貯蓄';

  @override
  String get onboardingPage1Description => '手間なくお金を確保し、一歩ごとに貯蓄が増えるのを見てみましょう。';

  @override
  String get onboardingPage2Title => '目標を達成';

  @override
  String get onboardingPage2Description =>
      '新しいガジェットから夢の旅行まで、財務目標を設定し、進捗を追跡します。';

  @override
  String get onboardingPage3Title => '軌道に乗る';

  @override
  String get onboardingPage3Description => '支出、収入、貯蓄をすべて一つのシンプルなダッシュボードで監視します。';

  @override
  String get paywallCouldNotLoadPlans => 'プランを読み込めませんでした。\n後でもう一度お試しください。';

  @override
  String get paywallChooseYourPlan => 'プランを選択してください';

  @override
  String get paywallInvestInFinancialFreedom => '今すぐ経済的自由のために投資しましょう';

  @override
  String paywallPricePerDay(Object price) {
    return '$price/日';
  }

  @override
  String paywallSaveAmount(Object amount) {
    return '$amount節約';
  }

  @override
  String get paywallEverythingIncluded => '含まれるすべての機能:';

  @override
  String get paywallPersonalizedBudgetInsights => '定期的な予算を作成';

  @override
  String get paywallDailyProgressTracking => '複数アカウントの作成';

  @override
  String get paywallExpenseManagementTools => 'パーソナライズされたバケーションモード';

  @override
  String get paywallFinancialHealthTimeline => '色とカスタマイズ';

  @override
  String get paywallExpertGuidanceTips => 'カスタムカテゴリ';

  @override
  String get paywallCommunitySupportAccess => 'コミュニティサポートへのアクセス';

  @override
  String get paywallSaveYourFinances => 'あなたの財政と未来を守りましょう';

  @override
  String get paywallAverageUserSaves => '平均的なユーザーは効果的な予算編成により年間約£2,500節約しています';

  @override
  String get paywallSubscribeYourPlan => 'プランを購読する';

  @override
  String get paywallPleaseSelectPlan => 'プランを選択してください。';

  @override
  String get paywallSubscriptionActivated =>
      'サブスクリプションが有効になりました！プレミアム機能にアクセスできます。';

  @override
  String paywallFailedToPurchase(Object message) {
    return '購入に失敗しました: $message';
  }

  @override
  String paywallUnexpectedError(Object error) {
    return '予期せぬエラーが発生しました: $error';
  }

  @override
  String get paywallRestorePurchases => '購入を復元';

  @override
  String get paywallManageSubscription => 'サブスクリプションを管理';

  @override
  String get paywallPurchasesRestoredSuccessfully => '購入が正常に復元されました！';

  @override
  String get paywallNoActiveSubscriptionFound =>
      '有効なサブスクリプションが見つかりませんでした。現在は無料プランです。';

  @override
  String get paywallPerMonth => '月額';

  @override
  String get paywallPerYear => '年額';

  @override
  String get paywallBestValue => 'ベストバリュー';

  @override
  String get paywallMostPopular => '最も人気';

  @override
  String get mainScreenHome => 'ホーム';

  @override
  String get mainScreenBudget => '予算';

  @override
  String get mainScreenBalance => '残高';

  @override
  String get mainScreenGoals => '目標';

  @override
  String get mainScreenPersonal => '個人';

  @override
  String get mainScreenIncome => '収入';

  @override
  String get mainScreenExpense => '支出';

  @override
  String get balanceTitle => '残高';

  @override
  String get balanceAddAccount => '口座を追加';

  @override
  String get addAVacation => 'バケーションを追加';

  @override
  String get balanceMyAccounts => 'マイ口座';

  @override
  String get balanceVacation => 'バケーション';

  @override
  String get balanceAccountBalance => '口座残高';

  @override
  String get balanceNoAccountsFound => '口座が見つかりません。';

  @override
  String get balanceNoAccountsCreated => '口座が作成されていません';

  @override
  String get balanceCreateFirstAccount => '最初の口座を作成して残高の追跡を開始しましょう';

  @override
  String get balanceCreateFirstAccountFinances => '最初の口座を作成して財務の追跡を開始しましょう';

  @override
  String get balanceNoVacationsYet => 'バケーションはまだありません';

  @override
  String get balanceCreateFirstVacation => '最初のバケーション口座を作成して旅行の計画を始めましょう';

  @override
  String get balanceCreateVacationAccount => 'バケーション口座を作成';

  @override
  String get balanceSingleAccountView => '単一口座表示';

  @override
  String get balanceAddMoreAccounts => 'さらに口座を追加してチャートを表示';

  @override
  String get balanceNoAccountsForCurrency => '選択された通貨の口座が見つかりません';

  @override
  String balanceCreditLimit(Object value) {
    return '利用限度額: $value';
  }

  @override
  String balanceBalanceLimit(Object value) {
    return '残高上限: $value';
  }

  @override
  String get budgetTitle => '予算';

  @override
  String get budgetAddBudget => '予算を追加';

  @override
  String get budgetDaily => '日次';

  @override
  String get budgetWeekly => '週次';

  @override
  String get budgetMonthly => '月次';

  @override
  String get budgetSelectWeek => '週を選択';

  @override
  String get budgetSelectDate => '日付を選択';

  @override
  String get budgetSelectDay => '日を選択';

  @override
  String get budgetCancel => 'キャンセル';

  @override
  String get budgetApply => '適用';

  @override
  String get budgetTotalSpending => '合計支出';

  @override
  String get budgetCategoryBreakdown => 'カテゴリの内訳';

  @override
  String get budgetViewAll => 'すべて表示';

  @override
  String get budgetBudgets => '予算';

  @override
  String get budgetNoBudgetCreated => '予算が作成されていません';

  @override
  String get budgetStartCreatingBudget => '予算を作成して支出の内訳をここに表示しましょう。';

  @override
  String get budgetSetSpendingLimit => '支出上限を設定';

  @override
  String get budgetEnterLimitAmount => '上限額を入力';

  @override
  String get budgetSave => '保存';

  @override
  String get budgetEnterValidNumber => '有効な数値を入力してください';

  @override
  String get budgetLimitSaved => '予算上限を保存しました';

  @override
  String get budgetCreated => '予算が作成されました';

  @override
  String get budgetTransactions => '取引';

  @override
  String budgetOverBudget(Object amount) {
    return '予算を$amountオーバー';
  }

  @override
  String budgetRemaining(Object amount) {
    return '残り$amount';
  }

  @override
  String get homeNoMoreTransactions => 'これ以上取引はありません';

  @override
  String get homeErrorLoadingMoreTransactions => '追加の取引の読み込み中にエラーが発生しました';

  @override
  String get homeRetry => '再試行';

  @override
  String get homeErrorLoadingData => 'データの読み込み中にエラーが発生しました';

  @override
  String get homeNoTransactionsRecorded => '取引が記録されていません';

  @override
  String get homeStartAddingTransactions => '取引を追加して支出の内訳をここに表示しましょう。';

  @override
  String get homeCurrencyChange => '通貨の変更';

  @override
  String get homeCurrencyChangeMessage =>
      '通貨を変更すると、既存のすべての金額が換算されます。この操作は元に戻せません。続行しますか？';

  @override
  String get homeNo => 'いいえ';

  @override
  String get homeYes => 'はい';

  @override
  String get homeVacationBudgetBreakdown => 'バケーション予算の内訳';

  @override
  String get homeBalanceBreakdown => '残高の内訳';

  @override
  String get homeClose => '閉じる';

  @override
  String get transactionPickColor => '色を選択';

  @override
  String get transactionSelectDate => '日付を選択';

  @override
  String get transactionCancel => 'キャンセル';

  @override
  String get transactionApply => '適用';

  @override
  String get transactionAmount => '金額';

  @override
  String get transactionSelect => '選択';

  @override
  String get transactionPaid => '支払い済み';

  @override
  String get transactionAddTransaction => '取引を追加';

  @override
  String get transactionEditTransaction => '取引を編集';

  @override
  String get transactionIncome => '収入';

  @override
  String get transactionExpense => '支出';

  @override
  String get transactionDescription => '説明';

  @override
  String get transactionCategory => 'カテゴリ';

  @override
  String get transactionAccount => '口座';

  @override
  String get transactionDate => '日付';

  @override
  String get transactionSave => '保存';

  @override
  String get transactionDelete => '削除';

  @override
  String get transactionSuccess => '取引を正常に保存しました';

  @override
  String get transactionError => '取引の保存中にエラーが発生しました';

  @override
  String get transactionDeleteConfirm => 'この取引を削除してもよろしいですか？';

  @override
  String get transactionDeleteSuccess => '取引を正常に削除しました';

  @override
  String get goalsTitle => '目標';

  @override
  String get goalsAddGoal => '目標を追加';

  @override
  String get goalsNoGoalsCreated => '目標が作成されていません';

  @override
  String get goalsStartCreatingGoal => '財務の進捗を追跡するために目標を作成しましょう';

  @override
  String get goalsCreateGoal => '目標を作成';

  @override
  String get goalsEditGoal => '目標を編集';

  @override
  String get goalsGoalName => '目標名';

  @override
  String get goalsTargetAmount => '目標金額';

  @override
  String get goalsCurrentAmount => '現在の金額';

  @override
  String get goalsDeadline => '期限';

  @override
  String get goalsDescription => '説明';

  @override
  String get goalsSave => '保存';

  @override
  String get goalsCancel => 'キャンセル';

  @override
  String get goalsDelete => '削除';

  @override
  String get goalsGoalCreated => '目標を正常に作成しました';

  @override
  String get goalsGoalUpdated => '目標を正常に更新しました';

  @override
  String get goalsGoalDeleted => '目標を正常に削除しました';

  @override
  String get goalsErrorSaving => '目標の保存中にエラーが発生しました';

  @override
  String get goalsDeleteConfirm => 'この目標を削除してもよろしいですか？';

  @override
  String get goalsProgress => '進捗';

  @override
  String get goalsCompleted => '完了';

  @override
  String get goalsInProgress => '進行中';

  @override
  String get goalsNotStarted => '未開始';

  @override
  String get profileTitle => 'プロフィール';

  @override
  String get profilePremiumActive => 'プレミアムが有効';

  @override
  String get profilePremiumDescription => 'すべてのプレミアム機能にアクセスできます';

  @override
  String get profileFreePlan => '無料プラン';

  @override
  String get profileUpgradeDescription => '高度な機能のためにプレミアムにアップグレード';

  @override
  String profileRenewalDate(Object date) {
    return '更新日: $date';
  }

  @override
  String profileExpiresOn(Object date) {
    return '有効期限: $date';
  }

  @override
  String profileErrorSigningOut(Object error) {
    return 'サインアウト中にエラーが発生しました: $error';
  }

  @override
  String get profileUserNotFound => 'ユーザーが見つかりません';

  @override
  String get profileEditDisplayName => '表示名を編集';

  @override
  String get profileCancel => 'キャンセル';

  @override
  String get profileSave => '保存';

  @override
  String get profileDisplayNameUpdated => '表示名を正常に更新しました';

  @override
  String get profileErrorUpdatingName => '表示名の更新中にエラーが発生しました';

  @override
  String get profileManageSubscription => 'サブスクリプションを管理';

  @override
  String get profileRestorePurchases => '購入を復元';

  @override
  String get profileRefreshStatus => 'ステータスを更新';

  @override
  String get profileSubscriptionRefreshed => 'サブスクリプションステータスを更新しました';

  @override
  String get profileSignOut => 'サインアウト';

  @override
  String get profileSignOutConfirm => 'サインアウトしてもよろしいですか？';

  @override
  String get profileCurrencyRates => '通貨レート';

  @override
  String get profileCategories => 'カテゴリ';

  @override
  String get profileFeedback => 'フィードバック';

  @override
  String get profileExportData => 'データのエクスポート';

  @override
  String get profileSettings => '設定';

  @override
  String get profileAccount => 'アカウント';

  @override
  String get profileDisplayName => '表示名';

  @override
  String get profileEmail => 'メールアドレス';

  @override
  String get profileSubscription => 'サブスクリプション';

  @override
  String get profileVersion => 'バージョン';

  @override
  String get personalTitle => '個人';

  @override
  String get personalSubscriptions => 'サブスクリプション';

  @override
  String get personalBorrowed => '借りたもの';

  @override
  String get personalAddSubscription => 'サブスクリプションを追加';

  @override
  String get personalAddLent => '貸したものを追加';

  @override
  String get personalAddBorrowed => '借りたものを追加';

  @override
  String get personalNoSubscriptions => 'サブスクリプションが見つかりません';

  @override
  String get personalNoLent => '貸したアイテムが見つかりません';

  @override
  String get personalNoBorrowed => '借りたアイテムが見つかりません';

  @override
  String get personalStartAddingSubscription =>
      '定期的な支払いを追跡するためにサブスクリプションを追加しましょう';

  @override
  String get personalStartAddingLent => '貸したお金を追跡するために貸したアイテムを追加しましょう';

  @override
  String get personalStartAddingBorrowed => '借りたお金を追跡するために借りたアイテムを追加しましょう';

  @override
  String get personalEdit => '編集';

  @override
  String get personalDelete => '削除';

  @override
  String get personalMarkAsPaid => '支払い済みにする';

  @override
  String get personalMarkAsUnpaid => '未払いに戻す';

  @override
  String get personalAmount => '金額';

  @override
  String get personalDescription => '説明';

  @override
  String get personalDueDate => '期日';

  @override
  String get personalRecurring => '定期購入';

  @override
  String get personalOneTime => '一回限り';

  @override
  String get personalMonthly => '毎月';

  @override
  String get personalYearly => '毎年';

  @override
  String get personalWeekly => '毎週';

  @override
  String get personalDaily => '毎日';

  @override
  String get personalName => '名前';

  @override
  String get personalCategory => 'カテゴリ';

  @override
  String get personalNotes => 'メモ';

  @override
  String get personalSave => '保存';

  @override
  String get personalCancel => 'キャンセル';

  @override
  String get personalDeleteConfirm => 'このアイテムを削除してもよろしいですか？';

  @override
  String get personalItemSaved => 'アイテムを正常に保存しました';

  @override
  String get personalItemDeleted => 'アイテムを正常に削除しました';

  @override
  String get personalErrorSaving => 'アイテムの保存中にエラーが発生しました';

  @override
  String get personalErrorDeleting => 'アイテムの削除中にエラーが発生しました';

  @override
  String get analyticsTitle => '分析';

  @override
  String get analyticsOverview => '概要';

  @override
  String get analyticsIncome => '収入';

  @override
  String get analyticsExpenses => '支出';

  @override
  String get analyticsSavings => '貯蓄';

  @override
  String get analyticsCategories => 'カテゴリ';

  @override
  String get analyticsTrends => '傾向';

  @override
  String get analyticsMonthly => '月次';

  @override
  String get analyticsWeekly => '週次';

  @override
  String get analyticsDaily => '日次';

  @override
  String get analyticsYearly => '年次';

  @override
  String get analyticsNoData => 'データがありません';

  @override
  String get analyticsStartTracking => 'ここに分析を表示するために財務の追跡を開始しましょう';

  @override
  String get analyticsTotalIncome => '合計収入';

  @override
  String get analyticsTotalExpenses => '合計支出';

  @override
  String get analyticsNetSavings => '純貯蓄';

  @override
  String get analyticsTopCategories => 'トップカテゴリ';

  @override
  String get analyticsSpendingTrends => '支出傾向';

  @override
  String get analyticsIncomeTrends => '収入傾向';

  @override
  String get analyticsSavingsRate => '貯蓄率';

  @override
  String get analyticsAverageDaily => '日平均';

  @override
  String get analyticsAverageWeekly => '週平均';

  @override
  String get analyticsAverageMonthly => '月平均';

  @override
  String get analyticsSelectPeriod => '期間を選択';

  @override
  String get analyticsExportData => 'データのエクスポート';

  @override
  String get analyticsRefresh => '更新';

  @override
  String get analyticsErrorLoading => '分析データの読み込み中にエラーが発生しました';

  @override
  String get analyticsRetry => '再試行';

  @override
  String get goalsSelectColor => '色を選択';

  @override
  String get goalsMore => 'その他';

  @override
  String get goalsName => '目標名';

  @override
  String get goalsColor => '色';

  @override
  String get goalsNameRequired => '目標名は必須です';

  @override
  String get goalsAmountRequired => '目標金額は必須です';

  @override
  String get goalsAmountMustBePositive => '目標金額は0より大きい必要があります';

  @override
  String get goalsDeadlineRequired => '期限は必須です';

  @override
  String get goalsDeadlineMustBeFuture => '期限は未来の日付である必要があります';

  @override
  String get goalsNameAlreadyExists => 'この名前の目標はすでに存在します';

  @override
  String goalsErrorCreating(Object error) {
    return '目標の作成中にエラーが発生しました: $error';
  }

  @override
  String goalsErrorUpdating(Object error) {
    return '目標の更新中にエラーが発生しました: $error';
  }

  @override
  String goalsErrorDeleting(Object error) {
    return '目標の削除中にエラーが発生しました: $error';
  }

  @override
  String get expenseDetailTitle => '支出の詳細';

  @override
  String get expenseDetailEdit => '編集';

  @override
  String get expenseDetailDelete => '削除';

  @override
  String get expenseDetailAmount => '金額';

  @override
  String get expenseDetailCategory => 'カテゴリ';

  @override
  String get expenseDetailAccount => '口座';

  @override
  String get expenseDetailDate => '日付';

  @override
  String get expenseDetailDescription => '説明';

  @override
  String get expenseDetailNotes => 'メモ';

  @override
  String get expenseDetailSave => '保存';

  @override
  String get expenseDetailCancel => 'キャンセル';

  @override
  String get expenseDetailDeleteConfirm => 'この支出を削除してもよろしいですか？';

  @override
  String get expenseDetailUpdated => '支出を正常に更新しました';

  @override
  String get expenseDetailDeleted => '支出を正常に削除しました';

  @override
  String get expenseDetailErrorSaving => '支出の保存中にエラーが発生しました';

  @override
  String get expenseDetailErrorDeleting => '支出の削除中にエラーが発生しました';

  @override
  String get calendarTitle => 'カレンダー';

  @override
  String get calendarSelectDate => '日付を選択';

  @override
  String get calendarToday => '今日';

  @override
  String get calendarThisWeek => '今週';

  @override
  String get calendarThisMonth => '今月';

  @override
  String get calendarThisYear => '今年';

  @override
  String get calendarNoTransactions => 'この日付の取引はありません';

  @override
  String get calendarStartAddingTransactions => 'カレンダーに表示するために取引を追加しましょう';

  @override
  String get vacationDialogTitle => 'バケーションモード';

  @override
  String get vacationDialogEnable => 'バケーションモードを有効にする';

  @override
  String get vacationDialogDisable => 'バケーションモードを無効にする';

  @override
  String get vacationDialogDescription => 'バケーションモードは、旅行や休暇中の支出を追跡するのに役立ちます';

  @override
  String get vacationDialogCancel => 'キャンセル';

  @override
  String get vacationDialogConfirm => '確認';

  @override
  String get vacationDialogEnabled => 'バケーションモードを有効にしました';

  @override
  String get vacationDialogDisabled => 'バケーションモードを無効にしました';

  @override
  String get balanceDetailTitle => '口座の詳細';

  @override
  String get balanceDetailEdit => '編集';

  @override
  String get balanceDetailDelete => '削除';

  @override
  String get balanceDetailTransactions => '取引';

  @override
  String get balanceDetailBalance => '残高';

  @override
  String get balanceDetailCreditLimit => '利用限度額';

  @override
  String get balanceDetailBalanceLimit => '残高上限';

  @override
  String get balanceDetailCurrency => '通貨';

  @override
  String get balanceDetailAccountType => '口座タイプ';

  @override
  String get balanceDetailAccountName => '口座名';

  @override
  String get balanceDetailSave => '保存';

  @override
  String get balanceDetailCancel => 'キャンセル';

  @override
  String get balanceDetailDeleteConfirm => 'この口座を削除してもよろしいですか？';

  @override
  String get balanceDetailUpdated => '口座を正常に更新しました';

  @override
  String get balanceDetailDeleted => '口座を正常に削除しました';

  @override
  String get balanceDetailErrorSaving => '口座の保存中にエラーが発生しました';

  @override
  String get balanceDetailErrorDeleting => '口座の削除中にエラーが発生しました';

  @override
  String get addAccountTitle => '口座を追加';

  @override
  String get addAccountEditTitle => '口座を編集';

  @override
  String get addAccountName => '口座名';

  @override
  String get addAccountType => '口座タイプ';

  @override
  String get addAccountCurrency => '通貨';

  @override
  String get addAccountInitialBalance => '初期残高';

  @override
  String get addAccountCreditLimit => '利用限度額';

  @override
  String get addAccountBalanceLimit => '残高上限';

  @override
  String get addAccountColor => '色';

  @override
  String get addAccountIcon => 'アイコン';

  @override
  String get addAccountSave => '保存';

  @override
  String get addAccountCancel => 'キャンセル';

  @override
  String get addAccountCreated => '口座を正常に作成しました';

  @override
  String get addAccountUpdated => '口座を正常に更新しました';

  @override
  String get addAccountErrorSaving => '口座の保存中にエラーが発生しました';

  @override
  String get addAccountNameRequired => '口座名は必須です';

  @override
  String get addAccountTypeRequired => '口座タイプは必須です';

  @override
  String get addAccountCurrencyRequired => '通貨は必須です';

  @override
  String get budgetDetailTitle => '予算の詳細';

  @override
  String get budgetDetailEdit => '編集';

  @override
  String get budgetDetailDelete => '削除';

  @override
  String get budgetDetailSpending => '支出';

  @override
  String get budgetDetailLimit => '上限';

  @override
  String get budgetDetailRemaining => '残り';

  @override
  String get budgetDetailOverBudget => '予算オーバー';

  @override
  String get budgetDetailCategories => 'カテゴリ';

  @override
  String get budgetDetailTransactions => '取引';

  @override
  String get budgetDetailSave => '保存';

  @override
  String get budgetDetailCancel => 'キャンセル';

  @override
  String get budgetDetailDeleteConfirm => 'この予算を削除してもよろしいですか？';

  @override
  String get budgetDetailUpdated => '予算を正常に更新しました';

  @override
  String get budgetDetailDeleted => '予算を正常に削除しました';

  @override
  String get budgetDetailErrorSaving => '予算の保存中にエラーが発生しました';

  @override
  String get budgetDetailErrorDeleting => '予算の削除中にエラーが発生しました';

  @override
  String get addBudgetTitle => '予算を追加';

  @override
  String get addBudgetEditTitle => '予算を編集';

  @override
  String get addBudgetName => '予算名';

  @override
  String get addBudgetType => '予算タイプ';

  @override
  String get addBudgetAmount => '金額';

  @override
  String get addBudgetCurrency => '通貨';

  @override
  String get addBudgetPeriod => '期間';

  @override
  String get addBudgetCategories => 'カテゴリ';

  @override
  String get addBudgetColor => '色';

  @override
  String get addBudgetSave => '保存';

  @override
  String get addBudgetSaveBudget => '予算を保存';

  @override
  String get addBudgetCancel => 'キャンセル';

  @override
  String get addBudgetCreated => '予算を正常に作成しました';

  @override
  String get addBudgetUpdated => '予算を正常に更新しました';

  @override
  String get addBudgetErrorSaving => '予算の保存中にエラーが発生しました';

  @override
  String get addBudgetNameRequired => '予算名は必須です';

  @override
  String get addBudgetAmountRequired => '予算金額は必須です';

  @override
  String get addBudgetAmountMustBePositive => '予算金額は0より大きい必要があります';

  @override
  String get addBudgetCategoryRequired => 'カテゴリを選択してください';

  @override
  String get budgetDetailNoBudgetToDelete =>
      '削除する予算がありません。これは単なる取引のプレースホルダーです。';

  @override
  String get personalItemDetails => 'アイテムの詳細';

  @override
  String get personalStartDateRequired => '開始日を選択してください';

  @override
  String get profileMainCurrency => 'メイン通貨';

  @override
  String get profileFeedbackThankYou => 'フィードバックありがとうございます！';

  @override
  String get profileFeedbackEmailError => 'メールクライアントを開けませんでした。';

  @override
  String get feedbackModalTitle => 'アプリを楽しんでいますか？';

  @override
  String get feedbackModalDescription =>
      'あなたのフィードバックは、私たちのモチベーションを維持し、改善に役立ちます。';

  @override
  String get goalNameAlreadyExistsSnackbar => 'この名前の目標はすでに存在します';

  @override
  String get lentSelectBothDates => '日付と期日の両方を選択してください';

  @override
  String get lentDueDateBeforeLentDate => '期日は貸付日より前にすることはできません';

  @override
  String get lentItemAddedSuccessfully => '貸したアイテムを正常に追加しました';

  @override
  String lentItemError(Object error) {
    return 'エラー: $error';
  }

  @override
  String get borrowedSelectBothDates => '日付と期日の両方を選択してください';

  @override
  String get borrowedDueDateBeforeBorrowedDate => '期日は借用日より前にすることはできません';

  @override
  String get borrowedItemAddedSuccessfully => '借りたアイテムを正常に追加しました';

  @override
  String borrowedItemError(Object error) {
    return 'エラー: $error';
  }

  @override
  String get subscriptionCreatedSuccessfully => 'サブスクリプションを正常に作成しました';

  @override
  String subscriptionError(Object error) {
    return 'エラー: $error';
  }

  @override
  String get paymentMarkedSuccessfully => '支払いを正常にマークしました';

  @override
  String get subscriptionContinued => 'サブスクリプションを正常に再開しました';

  @override
  String get subscriptionPaused => 'サブスクリプションを正常に一時停止しました';

  @override
  String get itemMarkedAsReturnedSuccessfully => 'アイテムを返却済みにしました';

  @override
  String get itemDeletedSuccessfully => 'アイテムを正常に削除しました';

  @override
  String get failedToDeleteBudget => '予算の削除に失敗しました';

  @override
  String get failedToDeleteGoal => '目標の削除に失敗しました';

  @override
  String failedToSaveTransaction(Object error) {
    return '取引の保存に失敗しました: $error';
  }

  @override
  String get failedToReorderCategories => 'カテゴリの並べ替えに失敗しました。変更を元に戻します。';

  @override
  String get categoryAddedSuccessfully => 'カテゴリを正常に追加しました';

  @override
  String failedToAddCategory(Object error) {
    return 'カテゴリの追加に失敗しました: $error';
  }

  @override
  String get addCategory => 'カテゴリを追加';

  @override
  String errorCreatingGoal(Object error) {
    return '目標の作成中にエラーが発生しました: $error';
  }

  @override
  String get hintName => '名前';

  @override
  String get hintDescription => '説明';

  @override
  String get hintSelectDate => '日付を選択';

  @override
  String get hintSelectDueDate => '期日を選択';

  @override
  String get hintSelectCategory => 'カテゴリを選択';

  @override
  String get hintSelectAccount => '口座を選択';

  @override
  String get hintSelectGoal => '目標を選択';

  @override
  String get hintNotes => 'メモ';

  @override
  String get hintSelectColor => '色を選択';

  @override
  String get hintEnterCategoryName => 'カテゴリ名を入力';

  @override
  String get hintSelectType => 'タイプを選択';

  @override
  String get hintWriteThoughts => 'ここにあなたの考えを書いてください......';

  @override
  String get hintEnterDisplayName => '表示名を入力';

  @override
  String get hintSelectBudgetType => '予算タイプを選択';

  @override
  String get hintSelectAccountType => '口座タイプを選択';

  @override
  String get hintEnterName => '名前を入力';

  @override
  String get hintSelectIcon => 'アイコンを選択';

  @override
  String get hintSelect => '選択';

  @override
  String get hintAmountPlaceholder => '0.00';

  @override
  String get labelValue => '値';

  @override
  String get labelName => '名前';

  @override
  String get labelDescription => '説明';

  @override
  String get labelCategory => 'カテゴリ';

  @override
  String get labelDate => '日付';

  @override
  String get labelDueDate => '期日';

  @override
  String get labelColor => '色';

  @override
  String get labelNotes => 'メモ';

  @override
  String get labelAccount => '口座';

  @override
  String get labelMore => 'その他';

  @override
  String get labelHome => 'ホーム';

  @override
  String get titlePickColor => '色を選択';

  @override
  String get titleAddLentItem => '貸したアイテムを追加';

  @override
  String get titleAddBorrowedItem => '借りたアイテムを追加';

  @override
  String get titleSelectCategory => 'カテゴリを選択';

  @override
  String get titleSelectAccount => '口座を選択';

  @override
  String get titleSelectGoal => '目標を選択';

  @override
  String get titleSelectType => 'タイプを選択';

  @override
  String get titleSelectAccountType => '口座タイプを選択';

  @override
  String get titleSelectBudgetType => '予算タイプを選択';

  @override
  String get validationNameRequired => '名前は必須です';

  @override
  String get validationAmountRequired => '金額は必須です';

  @override
  String get validationPleaseEnterValidNumber => '有効な数値を入力してください';

  @override
  String get validationPleaseSelectIcon => 'アイコンを選択してください';

  @override
  String get buttonCancel => 'キャンセル';

  @override
  String get buttonAdd => '追加';

  @override
  String get buttonSave => '保存';

  @override
  String get switchAddProgress => '進捗を追加';

  @override
  String get pickColor => '色を選択';

  @override
  String get name => '名前';

  @override
  String get itemName => 'アイテム名';

  @override
  String get account => '口座';

  @override
  String get selectIcon => 'アイコンを選択してください';

  @override
  String get value => '値';

  @override
  String get hintAmount => '0.00';

  @override
  String get hintItemName => 'アイテム名';

  @override
  String get amountRequired => '金額は必須です';

  @override
  String get validNumber => '有効な数値を入力してください';

  @override
  String get category => 'カテゴリ';

  @override
  String get date => '日付';

  @override
  String get dueDate => '期日';

  @override
  String get color => '色';

  @override
  String get notes => 'メモ';

  @override
  String get selectColor => '色を選択';

  @override
  String get more => 'その他';

  @override
  String get addLentItem => '貸したアイテムを追加';

  @override
  String get addBorrowedItem => '借りたアイテムを追加';

  @override
  String get cancel => 'キャンセル';

  @override
  String get add => '追加';

  @override
  String get nameRequired => '名前は必須です';

  @override
  String get buttonOk => 'OK';

  @override
  String get vacationNoAccountsAvailable => '利用可能なバケーション口座がありません。';

  @override
  String get exportFormat => '形式';

  @override
  String get exportOptions => 'オプション';

  @override
  String get exportAccountData => '口座データのエクスポート';

  @override
  String get exportGoalsData => '目標データのエクスポート';

  @override
  String get exportCurrentMonth => '今月';

  @override
  String get exportLast30Days => '過去30日間';

  @override
  String get exportLast90Days => '過去90日間';

  @override
  String get exportLast365Days => '過去365日間';

  @override
  String get exportCsv => 'CSV';

  @override
  String get exportJson => 'JSON';

  @override
  String get exportImportInstructions => 'CSVファイルからアプリにデータをインポートできます。';

  @override
  String get exportInstructions1 => '必要なデータ形式を確認するためにサンプルファイルを保存してください。';

  @override
  String get exportInstructions2 =>
      'テンプレートに従ってデータをフォーマットしてください。列、その順序、名前がテンプレートと完全に同じであることを確認してください。列名は英語である必要があります。';

  @override
  String get exportInstructions3 => 'インポートを押してファイルを選択してください。';

  @override
  String get exportInstructions4 =>
      '既存のデータを上書きするか、インポートしたデータを既存のデータに追加するかを選択してください。上書きオプションを選択した場合、既存のデータは完全に削除されます。';

  @override
  String get exportButtonExport => 'エクスポート';

  @override
  String get exportButtonImport => 'インポート';

  @override
  String get exportTabExport => 'エクスポート';

  @override
  String get exportTabImport => 'インポート';

  @override
  String get enableVacationMode => 'バケーションモードを有効にする';

  @override
  String get addProgress => '進捗を追加';

  @override
  String get pleaseEnterValidNumber => '有効な数値を入力してください';

  @override
  String get pleaseSelectCategory => 'カテゴリを選択してください';

  @override
  String get pleaseSelectCurrency => '通貨を選択してください';

  @override
  String get pleaseSelectAccount => '口座を選択してください';

  @override
  String get pleaseSelectDate => '日付を選択してください';

  @override
  String get pleaseSelectIcon => 'アイコンを選択してください';

  @override
  String get deleteCategory => 'カテゴリを削除';

  @override
  String get markAsReturned => '返却済みにする';

  @override
  String get markPayment => '支払いをマーク';

  @override
  String get markPaid => '支払い済みをマーク';

  @override
  String get deleteItem => 'アイテムを削除';

  @override
  String get deleteAccount => '口座を削除';

  @override
  String get deleteAllAssociatedTransactions => '関連するすべての取引を削除';

  @override
  String get normalMode => '通常モード';

  @override
  String normalModeWithCurrency(String currency) {
    return '現在、通常モード ($currency通貨) です';
  }

  @override
  String get changeCurrency => '通貨を変更';

  @override
  String get vacationModeDialog => 'バケーションモードダイアログ';

  @override
  String get categoryAndTransactionsDeleted => 'カテゴリと関連する取引を正常に削除しました';

  @override
  String get select => '選択';

  @override
  String get delete => '削除';

  @override
  String get confirm => '確認';

  @override
  String get yourData => 'あなたのデータ';

  @override
  String get profileMenuAccount => 'アカウント';

  @override
  String get profileMenuCurrency => '通貨';

  @override
  String get profileSectionLegal => '法的事項';

  @override
  String get profileTermsConditions => '利用規約';

  @override
  String get profilePrivacyPolicy => 'プライバシーポリシー';

  @override
  String get profileSectionSupport => 'サポート';

  @override
  String get profileHelpSupport => 'ヘルプとサポート';

  @override
  String get profileSectionDanger => '危険ゾーン';

  @override
  String get currencyPageChange => '変更';

  @override
  String get addTransactionNotes => 'メモ';

  @override
  String get addTransactionMore => 'その他';

  @override
  String get addTransactionDate => '日付';

  @override
  String get addTransactionTime => '時刻';

  @override
  String get addTransactionPaid => '支払い済み';

  @override
  String get addTransactionColor => '色';

  @override
  String get addTransactionCancel => 'キャンセル';

  @override
  String get addTransactionCreate => '作成';

  @override
  String get addTransactionUpdate => '更新';

  @override
  String get addBudgetLimitAmount => '上限金額';

  @override
  String get addBudgetSelectCategory => 'カテゴリを選択';

  @override
  String get addBudgetBudgetType => '予算タイプ';

  @override
  String get addBudgetRecurring => '定期的な予算';

  @override
  String get addBudgetRecurringSubtitle => 'この予算を期間ごとに自動的に更新する';

  @override
  String get addBudgetRecurringDailySubtitle => '毎日適用';

  @override
  String get addBudgetRecurringPremiumSubtitle => 'プレミアム機能 - 購読して有効にする';

  @override
  String get addBudget => '予算を追加';

  @override
  String get addAccountTransactionLimit => '取引制限';

  @override
  String get addAccountAccountType => '口座タイプ';

  @override
  String get addAccountAdd => '追加';

  @override
  String get addAccountBalance => '残高';

  @override
  String get addAccountCredit => 'クレジット';

  @override
  String get homeIncomeCard => '収入';

  @override
  String get homeExpenseCard => '支出';

  @override
  String get homeTotalBudget => '合計予算';

  @override
  String get balanceDetailInitialBalance => '初期残高';

  @override
  String get balanceDetailCurrentBalance => '現在の残高';

  @override
  String get expenseDetailTotal => '合計';

  @override
  String get expenseDetailAccumulatedAmount => '累計金額';

  @override
  String get expenseDetailPaidStatus => '支払い済み/未払い';

  @override
  String get expenseDetailVacation => 'バケーション';

  @override
  String get expenseDetailMarkPaid => '支払い済みにする';

  @override
  String get expenseDetailMarkUnpaid => '未払いに戻す';

  @override
  String get goalsScreenPending => '保留中の目標';

  @override
  String get goalsScreenFulfilled => '達成された目標';

  @override
  String get createGoalTitle => '保留中の目標を作成';

  @override
  String get createGoalAmount => '金額';

  @override
  String get createGoalName => '名前';

  @override
  String get createGoalCurrency => '通貨';

  @override
  String get createGoalMore => 'その他';

  @override
  String get createGoalNotes => 'メモ';

  @override
  String get createGoalDate => '日付';

  @override
  String get createGoalColor => '色';

  @override
  String get createGoalLimitReached =>
      '目標の上限に達しました。無制限の目標を作成するにはプレミアムにアップグレードしてください。';

  @override
  String get personalScreenSubscriptions => 'サブスクリプション';

  @override
  String get personalScreenBorrowed => '借りたもの';

  @override
  String get personalScreenLent => '貸したもの';

  @override
  String get personalScreenTotal => '合計';

  @override
  String get personalScreenActive => '有効';

  @override
  String get personalScreenNoSubscriptions => 'サブスクリプションはまだありません';

  @override
  String get personalScreenNoBorrowed => '借りたアイテムはまだありません';

  @override
  String get personalScreenBorrowedItems => '借りたアイテム';

  @override
  String get personalScreenLentItems => '貸したアイテム';

  @override
  String get personalScreenNoLent => '貸したアイテムはまだありません';

  @override
  String get addBorrowedTitle => '借りたアイテムを追加';

  @override
  String get addLentTitle => '貸したアイテムを追加';

  @override
  String get addBorrowedName => '名前';

  @override
  String get addBorrowedAmount => '金額';

  @override
  String get addBorrowedNotes => 'メモ';

  @override
  String get addBorrowedMore => 'その他';

  @override
  String get addBorrowedDate => '日付';

  @override
  String get addBorrowedDueDate => '期日';

  @override
  String get addBorrowedReturned => '返却済み';

  @override
  String get addBorrowedMarkReturned => '返却済みにする';

  @override
  String get addSubscriptionPrice => '価格';

  @override
  String get addSubscriptionName => '名前';

  @override
  String get addSubscriptionRecurrence => '頻度';

  @override
  String get addSubscriptionMore => 'その他';

  @override
  String get addSubscriptionNotes => 'メモ';

  @override
  String get addSubscriptionStartDate => '開始日';

  @override
  String get addLentName => '名前';

  @override
  String get addLentAmount => '金額';

  @override
  String get addLentNotes => 'メモ';

  @override
  String get addLentMore => 'その他';

  @override
  String get addLentDate => '日付';

  @override
  String get addLentDueDate => '期日';

  @override
  String get addLentReturned => '返却済み';

  @override
  String get addLentMarkReturned => '返却済みにする';

  @override
  String get currencyPageTitle => '通貨レート';

  @override
  String get profileVacationMode => 'バケーションモード';

  @override
  String get profileCurrency => '通貨';

  @override
  String get profileLegal => '法的事項';

  @override
  String get profileSupport => 'サポート';

  @override
  String get profileDangerZone => '危険ゾーン';

  @override
  String get profileLogout => 'ログアウト';

  @override
  String get profileDeleteAccount => 'アカウントを削除';

  @override
  String get profileDeleteAccountTitle => 'アカウントを削除';

  @override
  String get profileDeleteAccountMessage =>
      'アカウントを削除してもよろしいですか？この操作は元に戻せません。口座、取引、予算、目標を含むすべてのデータが完全に削除されます。';

  @override
  String get profileDeleteAccountConfirm => '削除';

  @override
  String get profileDeleteAccountSuccess => 'アカウントを正常に削除しました';

  @override
  String profileDeleteAccountError(String error) {
    return 'アカウントの削除中にエラーが発生しました: $error';
  }

  @override
  String get homeIncome => '収入';

  @override
  String get homeExpense => '支出';

  @override
  String get expenseDetailPaidUnpaid => '支払い済み/未払い';

  @override
  String get goalsScreenPendingGoals => '保留中の目標';

  @override
  String get goalsScreenFulfilledGoals => '達成された目標';

  @override
  String get transactionEditIncome => '収入を編集';

  @override
  String get transactionEditExpense => '支出を編集';

  @override
  String get transactionPlanIncome => '収入を計画';

  @override
  String get transactionPlanExpense => '支出を計画';

  @override
  String get goal => '目標';

  @override
  String get none => 'なし';

  @override
  String get unnamedCategory => '名前のないカテゴリ';

  @override
  String get month => '月';

  @override
  String get daily => '日次';

  @override
  String get weekly => '週次';

  @override
  String get monthly => '月次';

  @override
  String get profileLanguage => '言語';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageSpanish => 'スペイン語';

  @override
  String get languageArabic => 'アラビア語';

  @override
  String get languageSelectLanguage => '言語を選択';

  @override
  String get vacationCurrencyDialogTitle => 'バケーション通貨';

  @override
  String vacationCurrencyDialogMessage(Object previousCurrency) {
    return 'バケーションの取引の通貨を変更できます。今すぐ通貨を変更しますか？\n\n以前の通貨は $previousCurrency でした。';
  }

  @override
  String vacationCurrencyDialogKeepCurrent(Object previousCurrency) {
    return '現在の通貨を維持 ($previousCurrency)';
  }

  @override
  String get includeVacationTransaction => 'バケーション取引を含める';

  @override
  String get showVacationTransactions => '通常モードでバケーション取引を表示する';

  @override
  String get balanceDetailTransactionsWillAppear => 'この口座の取引がここに表示されます';

  @override
  String get personalNextBilling => '次回の請求';

  @override
  String get personalActive => '有効';

  @override
  String get personalInactive => '無効';

  @override
  String get personalReturned => '返却済み';

  @override
  String get personalLent => '貸付';

  @override
  String get personalDue => '期日';

  @override
  String get personalItems => 'アイテム';

  @override
  String get status => 'ステータス';

  @override
  String get notReturned => '未返却';

  @override
  String get borrowedOn => '借用日';

  @override
  String get lentOn => '貸付日';

  @override
  String get pause => '一時停止';

  @override
  String get resume => '再開';

  @override
  String get upcomingBills => '今後の請求';

  @override
  String get upcomingCharge => '今後の支払い';

  @override
  String get pastHistory => '過去の履歴';

  @override
  String get noHistoryYet => 'まだ履歴はありません';

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
