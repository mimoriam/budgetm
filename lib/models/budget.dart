import 'package:cloud_firestore/cloud_firestore.dart';

enum BudgetType { weekly, monthly, yearly }

class Budget {
  final String id; // Composite key: {userId}_{categoryId}_{type}_{year}_{period}
  final String categoryId;
  final double limit;
  final BudgetType type;
  final int year;
  final int period; // Week number (1-53), month number (1-12), or year
  final DateTime startDate;
  final DateTime endDate;
  final String userId;
  double spentAmount; // Calculated dynamically, not stored in Firestore

  Budget({
    required this.id,
    required this.categoryId,
    required this.limit,
    required this.type,
    required this.year,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.userId,
    this.spentAmount = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'limit': limit,
      'type': type.toString().split('.').last,
      'year': year,
      'period': period,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'userId': userId,
    };
  }

  factory Budget.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Budget(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      limit: (data['limit'] as num?)?.toDouble() ?? 0.0,
      type: _budgetTypeFromString(data['type']),
      year: data['year'] ?? DateTime.now().year,
      period: data['period'] ?? 0,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      spentAmount: 0.0,
    );
  }

  factory Budget.fromJson(Map<String, dynamic> json, String id) {
    return Budget(
      id: id,
      categoryId: json['categoryId'] ?? '',
      limit: (json['limit'] as num?)?.toDouble() ?? 0.0,
      type: _budgetTypeFromString(json['type']),
      year: json['year'] ?? DateTime.now().year,
      period: json['period'] ?? 0,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      userId: json['userId'] ?? '',
      spentAmount: 0.0,
    );
  }

  static BudgetType _budgetTypeFromString(String? type) {
    switch (type) {
      case 'weekly':
        return BudgetType.weekly;
      case 'monthly':
        return BudgetType.monthly;
      case 'yearly':
        return BudgetType.yearly;
      default:
        return BudgetType.monthly;
    }
  }

  Budget copyWith({
    String? id,
    String? categoryId,
    double? limit,
    BudgetType? type,
    int? year,
    int? period,
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    double? spentAmount,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limit: limit ?? this.limit,
      type: type ?? this.type,
      year: year ?? this.year,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      userId: userId ?? this.userId,
      spentAmount: spentAmount ?? this.spentAmount,
    );
  }

  @override
  String toString() {
    return 'Budget(id: $id, categoryId: $categoryId, type: $type, year: $year, period: $period, limit: $limit, spentAmount: $spentAmount, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget &&
        other.id == id &&
        other.categoryId == categoryId &&
        other.type == type &&
        other.year == year &&
        other.period == period &&
        other.limit == limit &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return Object.hash(id, categoryId, type, year, period, limit, userId);
  }

  // Helper method to generate budget ID
  static String generateId(String userId, String categoryId, BudgetType type, int year, int period) {
    return '${userId}_${categoryId}_${type.toString().split('.').last}_${year}_$period';
  }

  // Helper method to calculate week number (Sunday to Saturday) — week-of-year
  static int getWeekNumber(DateTime date) {
    // Find the first Sunday of the year
    final firstDayOfYear = DateTime(date.year, 1, 1);
    int daysToFirstSunday = (DateTime.sunday - firstDayOfYear.weekday + 7) % 7;
    if (daysToFirstSunday == 0 && firstDayOfYear.weekday != DateTime.sunday) {
      daysToFirstSunday = 7;
    }
    final firstSunday = firstDayOfYear.add(Duration(days: daysToFirstSunday));
    
    if (date.isBefore(firstSunday)) {
      // If date is before first Sunday, it belongs to the last week of previous year
      return getWeekNumber(DateTime(date.year - 1, 12, 31));
    }
    
    final daysSinceFirstSunday = date.difference(firstSunday).inDays;
    return (daysSinceFirstSunday / 7).floor() + 1;
  }

  // Helper method to get week of month (Sunday to Saturday), where week 1 starts at the first Sunday on/after
  // the first day of the month. Days before that first Sunday are treated as part of week 1 for UI consistency.
  static int getWeekOfMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final firstSunday = getStartOfWeek(firstDayOfMonth);
    if (date.isBefore(firstSunday)) {
      // Treat days before the month's first Sunday as week 1 so UI week chips (1-4) include early-month days.
      return 1;
    }
    final daysSinceFirstSunday = date.difference(firstSunday).inDays;
    return (daysSinceFirstSunday / 7).floor() + 1;
  }

  // Helper method to get start of week (Sunday)
  static DateTime getStartOfWeek(DateTime date) {
    final daysFromSunday = date.weekday % 7;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysFromSunday));
  }

  // Helper method to get end of week (Saturday)
  static DateTime getEndOfWeek(DateTime date) {
    final startOfWeek = getStartOfWeek(date);
    return startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  }

  // Helper method to get start and end dates for a budget type
  static Map<String, DateTime> getDateRange(BudgetType type, int year, int period) {
    switch (type) {
      case BudgetType.weekly:
        // For weekly budgets we encode period as (month * 10 + weekOfMonth).
        // Decode month and weekOfMonth here so date ranges align with the UI week-of-month selector
        final month = period ~/ 10;
        final weekOfMonth = period % 10;
        // Safeguard: if decoding fails, fall back to week-of-year behavior
        if (month < 1 || month > 12 || weekOfMonth < 1) {
          // Fallback: treat period as week-of-year (legacy)
          final firstDayOfYear = DateTime(year, 1, 1);
          int daysToFirstSunday = (DateTime.sunday - firstDayOfYear.weekday + 7) % 7;
          if (daysToFirstSunday == 0 && firstDayOfYear.weekday != DateTime.sunday) {
            daysToFirstSunday = 7;
          }
          final firstSunday = firstDayOfYear.add(Duration(days: daysToFirstSunday));
          final startDate = firstSunday.add(Duration(days: (period - 1) * 7));
          final endDate = startDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
          return {'startDate': startDate, 'endDate': endDate};
        }
        // Calculate the first Sunday of the month and then the requested week
        final firstDayOfMonth = DateTime(year, month, 1);
        final firstSunday = getStartOfWeek(firstDayOfMonth);
        final startDate = firstSunday.add(Duration(days: (weekOfMonth - 1) * 7));
        final endDate = startDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return {'startDate': startDate, 'endDate': endDate};
      
      case BudgetType.monthly:
        final startDate = DateTime(year, period, 1);
        final endDate = DateTime(year, period + 1, 0, 23, 59, 59);
        return {'startDate': startDate, 'endDate': endDate};
      
      case BudgetType.yearly:
        final startDate = DateTime(year, 1, 1);
        final endDate = DateTime(year, 12, 31, 23, 59, 59);
        return {'startDate': startDate, 'endDate': endDate};
    }
  }
}