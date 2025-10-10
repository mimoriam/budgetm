class Subscription {
  final String title;
  final String? description;
  final double amount;
  final DateTime nextBillingDate;
  final List<List<dynamic>> icon;
  final bool isActive;
  final String currency; // New field for currency

  Subscription({
    required this.title,
    this.description,
    required this.amount,
    required this.nextBillingDate,
    required this.icon,
    this.isActive = true,
    required this.currency, // New required field
  });
}