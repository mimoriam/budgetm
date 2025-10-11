import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

import 'package:budgetm/constants/transaction_type_enum.dart';
import 'package:budgetm/screens/dashboard/navbar/home/transaction/add_transaction_screen.dart';
import 'package:budgetm/viewmodels/home_screen_provider.dart';
import 'package:budgetm/viewmodels/goals_provider.dart';
import 'package:budgetm/viewmodels/vacation_mode_provider.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:budgetm/models/firestore_account.dart';
import 'package:budgetm/models/category.dart';
import 'package:budgetm/models/goal.dart';

// Mock classes
class MockFirestoreService implements FirestoreService {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Return default empty values for any unimplemented method
    if (invocation.isGetter) {
      switch (invocation.memberName) {
        case #instance:
          return this;
        default:
          return null;
      }
    }
    
    if (invocation.isMethod) {
      switch (invocation.memberName) {
        case #getAllAccounts:
          return Future.value([]);
        case #getAllCategories:
          return Future.value([]);
        case #getGoals:
          return Stream.value([]);
        default:
          return Future.value();
      }
    }
    
    return super.noSuchMethod(invocation);
  }
}

class MockHomeScreenProvider extends ChangeNotifier implements HomeScreenProvider {
  bool _shouldRefresh = false;
  bool _shouldRefreshAccounts = false;
  bool _shouldRefreshTransactions = false;
  DateTime? _transactionDate;
  DateTime? _selectedDate;

  @override
  bool get shouldRefresh => _shouldRefresh;

  @override
  bool get shouldRefreshAccounts => _shouldRefreshAccounts;

  @override
  bool get shouldRefreshTransactions => _shouldRefreshTransactions;

  @override
  DateTime? get transactionDate => _transactionDate;

  @override
  DateTime? get selectedDate => _selectedDate;

  @override
  void triggerRefresh({DateTime? transactionDate}) {
    _shouldRefresh = true;
    _transactionDate = transactionDate;
    notifyListeners();
  }

  @override
  void triggerAccountRefresh() {
    _shouldRefreshAccounts = true;
    notifyListeners();
  }

  @override
  void triggerTransactionsRefresh() {
    _shouldRefreshTransactions = true;
    notifyListeners();
  }

  @override
  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  @override
  void completeRefresh() {
    _shouldRefresh = false;
    _shouldRefreshAccounts = false;
    _shouldRefreshTransactions = false;
    _transactionDate = null;
    notifyListeners();
  }
}

class MockGoalsProvider extends ChangeNotifier implements GoalsProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isMethod) {
      switch (invocation.memberName) {
        case #getGoals:
          return Stream.value([]);
        case #updateGoalProgress:
          return Future.value();
        default:
          return Future.value();
      }
    }
    return super.noSuchMethod(invocation);
  }
}

class MockVacationProvider extends ChangeNotifier implements VacationProvider {
  bool _isVacationMode = false;
  String? _activeVacationAccountId;

  @override
  bool get isVacationMode => _isVacationMode;

  @override
  bool get isAiMode => _isVacationMode;

  @override
  String? get activeVacationAccountId => _activeVacationAccountId;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  group('AddTransactionScreen Tests', () {
    late MockFirestoreService mockFirestoreService;
    late MockHomeScreenProvider mockHomeScreenProvider;
    late MockGoalsProvider mockGoalsProvider;
    late MockVacationProvider mockVacationProvider;

    setUp(() {
      mockFirestoreService = MockFirestoreService();
      mockHomeScreenProvider = MockHomeScreenProvider();
      mockGoalsProvider = MockGoalsProvider();
      mockVacationProvider = MockVacationProvider();
    });

    Widget createTestWidget({DateTime? selectedDate}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<HomeScreenProvider>(
            create: (_) => mockHomeScreenProvider,
          ),
          ChangeNotifierProvider<GoalsProvider>(
            create: (_) => mockGoalsProvider,
          ),
          ChangeNotifierProvider<VacationProvider>(
            create: (_) => mockVacationProvider,
          ),
        ],
        child: MaterialApp(
          home: AddTransactionScreen(
            transactionType: TransactionType.expense,
            selectedDate: selectedDate,
          ),
        ),
      );
    }

    testWidgets(
      'add_transaction_screen date picker does not assert when initialDate is in the past',
      (WidgetTester tester) async {
        // Create a past date (yesterday)
        final pastDate = DateTime.now().subtract(const Duration(days: 1));

        // Build the widget with a past selectedDate
        await tester.pumpWidget(createTestWidget(selectedDate: pastDate));
        await tester.pumpAndSettle();

        // Verify the screen loaded without assertion errors
        expect(find.byType(AddTransactionScreen), findsOneWidget);

        // Find the 'More' button and tap it to reveal the date picker
        final moreButton = find.text('More');
        expect(moreButton, findsOneWidget);
        await tester.tap(moreButton);
        await tester.pumpAndSettle();

        // Find the date picker field and tap it
        final dateField = find.byType(FormBuilderDateTimePicker);
        expect(dateField, findsOneWidget);
        await tester.tap(dateField);
        await tester.pumpAndSettle();

        // If we get here without an assertion error, the fix is working
        expect(find.byType(FormBuilderDateTimePicker), findsOneWidget);
      },
    );
  });
}