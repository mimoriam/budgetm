class Subscription {
  final String title;
  final String? description;
  final double amount;
  final DateTime nextBillingDate;
  final List<List<dynamic>> icon;
  final bool isActive;

  Subscription({
    required this.title,
    this.description,
    required this.amount,
    required this.nextBillingDate,
    required this.icon,
    this.isActive = true,
  });
}
