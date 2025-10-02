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

  // Helper method to calculate week number (Monday to Sunday)
  static int getWeekNumber(DateTime date) {
    // Find the first Monday of the year
    final firstDayOfYear = DateTime(date.year, 1, 1);
    int daysToFirstMonday = (DateTime.monday - firstDayOfYear.weekday + 7) % 7;
    if (daysToFirstMonday == 0 && firstDayOfYear.weekday != DateTime.monday) {
      daysToFirstMonday = 7;
    }
    final firstMonday = firstDayOfYear.add(Duration(days: daysToFirstMonday));
    
    if (date.isBefore(firstMonday)) {
      // If date is before first Monday, it belongs to the last week of previous year
      return getWeekNumber(DateTime(date.year - 1, 12, 31));
    }
    
    final daysSinceFirstMonday = date.difference(firstMonday).inDays;
    return (daysSinceFirstMonday / 7).floor() + 1;
  }

  // Helper method to get start of week (Monday)
  static DateTime getStartOfWeek(DateTime date) {
    final daysFromMonday = (date.weekday - DateTime.monday + 7) % 7;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysFromMonday));
  }

  // Helper method to get end of week (Sunday)
  static DateTime getEndOfWeek(DateTime date) {
    final startOfWeek = getStartOfWeek(date);
    return startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  }

  // Helper method to get start and end dates for a budget type
  static Map<String, DateTime> getDateRange(BudgetType type, int year, int period) {
    switch (type) {
      case BudgetType.weekly:
        // Calculate the start date of the week
        final firstDayOfYear = DateTime(year, 1, 1);
        int daysToFirstMonday = (DateTime.monday - firstDayOfYear.weekday + 7) % 7;
        if (daysToFirstMonday == 0 && firstDayOfYear.weekday != DateTime.monday) {
          daysToFirstMonday = 7;
        }
        final firstMonday = firstDayOfYear.add(Duration(days: daysToFirstMonday));
        final startDate = firstMonday.add(Duration(days: (period - 1) * 7));
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