import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budgetm/models/budget.dart';

class RevampedBudget {
  final String id; // Composite key: {userId}_{categoryIds.join('_')}_{type}_{year}_{period}
  final String? name; // User-defined name for the budget
  final List<String> categoryIds; // Multiple categories
  final double limit;
  final BudgetType type;
  final int year;
  final int period; // Week number (1-53), month number (1-12), or day encoding
  final DateTime dateTime; // Start of period
  final String userId;
  final String currency;
  double spentAmount; // Calculated dynamically, not stored in Firestore

  RevampedBudget({
    required this.id,
    this.name,
    required this.categoryIds,
    required this.limit,
    required this.type,
    required this.year,
    required this.period,
    required this.dateTime,
    required this.userId,
    required this.currency,
    this.spentAmount = 0.0,
  });

  // Get start and end dates based on type and dateTime
  Map<String, DateTime> get dateRange {
    try {
      // Validate and sanitize inputs
      int validYear = year;
      int validPeriod = period;
      
      // Validate year (reasonable range)
      if (validYear < 2000 || validYear > 2100) {
        validYear = DateTime.now().year;
      }
      
      // Validate period encoding based on type
      switch (type) {
        case BudgetType.weekly:
          // Period encoding: month * 10 + weekOfMonth
          final month = validPeriod ~/ 10;
          final weekOfMonth = validPeriod % 10;
          
          // Validate month (1-12)
          if (month < 1 || month > 12 || weekOfMonth < 1 || weekOfMonth > 5) {
            // Invalid encoding, use current date as fallback
            final now = DateTime.now();
            validYear = now.year;
            final currentMonth = now.month;
            final currentWeek = Budget.getWeekOfMonth(now);
            validPeriod = currentMonth * 10 + currentWeek;
          }
          break;
          
        case BudgetType.monthly:
          // Period is month (1-12)
          if (validPeriod < 1 || validPeriod > 12) {
            // Invalid month, use current month as fallback
            final now = DateTime.now();
            validYear = now.year;
            validPeriod = now.month;
          }
          break;
          
        case BudgetType.daily:
          // Period encoding: month * 100 + day
          final month = validPeriod ~/ 100;
          final day = validPeriod % 100;
          
          // Validate month (1-12)
          if (month < 1 || month > 12) {
            // Invalid month, use current date as fallback
            final now = DateTime.now();
            validYear = now.year;
            validPeriod = now.month * 100 + now.day;
          } else {
            // Validate day against actual days in month
            int maxDaysInMonth;
            if (month == 2) {
              // Check for leap year
              final isLeapYear = (validYear % 4 == 0 && validYear % 100 != 0) || 
                                 (validYear % 400 == 0);
              maxDaysInMonth = isLeapYear ? 29 : 28;
            } else if ([4, 6, 9, 11].contains(month)) {
              maxDaysInMonth = 30;
            } else {
              maxDaysInMonth = 31;
            }
            
            // Validate day (1 to maxDaysInMonth)
            if (day < 1 || day > maxDaysInMonth) {
              // Invalid day, clamp to valid range
              final clampedDay = day.clamp(1, maxDaysInMonth);
              validPeriod = month * 100 + clampedDay;
            }
          }
          break;
      }
      
      // Check for year mismatch between dateTime and stored year
      // If dateTime is valid and year differs significantly, prefer dateTime's year
      if (dateTime.year >= 2000 && dateTime.year <= 2100) {
        final yearDiff = (dateTime.year - validYear).abs();
        if (yearDiff > 1) {
          // Significant mismatch, use dateTime's year
          validYear = dateTime.year;
        }
      }
      
      // Call Budget.getDateRange with validated inputs
      return Budget.getDateRange(type, validYear, validPeriod);
    } catch (e) {
      // Fallback to current date range if anything fails
      final now = DateTime.now();
      int fallbackYear = now.year;
      int fallbackPeriod;
      
      switch (type) {
        case BudgetType.weekly:
          final currentWeek = Budget.getWeekOfMonth(now);
          fallbackPeriod = now.month * 10 + currentWeek;
          break;
        case BudgetType.monthly:
          fallbackPeriod = now.month;
          break;
        case BudgetType.daily:
          fallbackPeriod = now.month * 100 + now.day;
          break;
      }
      
      return Budget.getDateRange(type, fallbackYear, fallbackPeriod);
    }
  }

  DateTime get startDate => dateRange['startDate']!;
  DateTime get endDate => dateRange['endDate']!;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'categoryIds': categoryIds,
      'limit': limit,
      'type': type.toString().split('.').last,
      'year': year,
      'period': period,
      'dateTime': Timestamp.fromDate(dateTime),
      'userId': userId,
      'currency': currency,
    };
  }

  factory RevampedBudget.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RevampedBudget(
      id: doc.id,
      name: data['name'] as String?,
      categoryIds: List<String>.from(data['categoryIds'] ?? []),
      limit: (data['limit'] as num?)?.toDouble() ?? 0.0,
      type: _budgetTypeFromString(data['type']),
      year: data['year'] ?? DateTime.now().year,
      period: data['period'] ?? 0,
      dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] ?? '',
      currency: data['currency'] ?? 'USD',
      spentAmount: 0.0,
    );
  }

  factory RevampedBudget.fromJson(Map<String, dynamic> json, String id) {
    return RevampedBudget(
      id: id,
      name: json['name'] as String?,
      categoryIds: List<String>.from(json['categoryIds'] ?? []),
      limit: (json['limit'] as num?)?.toDouble() ?? 0.0,
      type: _budgetTypeFromString(json['type']),
      year: json['year'] ?? DateTime.now().year,
      period: json['period'] ?? 0,
      dateTime: (json['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: json['userId'] ?? '',
      currency: json['currency'] ?? 'USD',
      spentAmount: 0.0,
    );
  }

  static BudgetType _budgetTypeFromString(String? type) {
    switch (type) {
      case 'weekly':
        return BudgetType.weekly;
      case 'monthly':
        return BudgetType.monthly;
      case 'daily':
        return BudgetType.daily;
      default:
        return BudgetType.monthly;
    }
  }

  RevampedBudget copyWith({
    String? id,
    String? name,
    List<String>? categoryIds,
    double? limit,
    BudgetType? type,
    int? year,
    int? period,
    DateTime? dateTime,
    String? userId,
    String? currency,
    double? spentAmount,
  }) {
    return RevampedBudget(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryIds: categoryIds ?? this.categoryIds,
      limit: limit ?? this.limit,
      type: type ?? this.type,
      year: year ?? this.year,
      period: period ?? this.period,
      dateTime: dateTime ?? this.dateTime,
      userId: userId ?? this.userId,
      currency: currency ?? this.currency,
      spentAmount: spentAmount ?? this.spentAmount,
    );
  }

  @override
  String toString() {
    return 'RevampedBudget(id: $id, name: $name, categoryIds: $categoryIds, type: $type, year: $year, period: $period, limit: $limit, spentAmount: $spentAmount, userId: $userId, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RevampedBudget &&
        other.id == id &&
        other.name == name &&
        other.categoryIds.length == categoryIds.length &&
        other.categoryIds.every((id) => categoryIds.contains(id)) &&
        other.type == type &&
        other.year == year &&
        other.period == period &&
        other.limit == limit &&
        other.userId == userId &&
        other.currency == currency;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      categoryIds.join(','),
      type,
      year,
      period,
      limit,
      userId,
      currency,
    );
  }

  // Helper method to generate revamped budget ID
  static String generateId(
    String userId,
    List<String> categoryIds,
    BudgetType type,
    int year,
    int period,
    {String? currency}
  ) {
    final sortedCategoryIds = List<String>.from(categoryIds)..sort();
    final categoryIdsStr = sortedCategoryIds.join('_');
    final currencySuffix = currency != null ? '_$currency' : '';
    return '${userId}_${categoryIdsStr}_${type.toString().split('.').last}_${year}_$period$currencySuffix';
  }
}

