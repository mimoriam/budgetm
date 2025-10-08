class Goal {
  final String title;
  final String? description;
  final double currentAmount;
  final double totalAmount;
  final DateTime date;
  final List<List<dynamic>> icon;
  final bool isFulfilled;

  Goal({
    required this.title,
    this.description,
    required this.currentAmount,
    required this.totalAmount,
    required this.date,
    required this.icon,
    this.isFulfilled = false,
  });
}