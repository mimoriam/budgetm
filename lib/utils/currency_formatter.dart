import 'package:intl/intl.dart';

/// Formats a currency amount with thousands separator (comma) and currency code.
/// 
/// Example:
/// - formatCurrency(1234.56, 'USD') returns 'USD 1,234.56'
/// - formatCurrency(1000000.0, 'EUR') returns 'EUR 1,000,000.00'
/// 
/// [amount] - The amount to format
/// [currencyCode] - The currency code (e.g., 'USD', 'EUR', 'VND')
/// Returns a formatted string with currency code and amount with comma separators
String formatCurrency(double amount, String currencyCode) {
  final formatter = NumberFormat('#,##0.00');
  return '$currencyCode ${formatter.format(amount)}';
}

/// Formats a currency amount with thousands separator (comma) without currency code.
/// Useful when currency code is displayed separately or with prefix/suffix.
/// 
/// Example:
/// - formatCurrencyAmount(1234.56) returns '1,234.56'
/// - formatCurrencyAmount(1000000.0) returns '1,000,000.00'
/// 
/// [amount] - The amount to format
/// Returns a formatted string with amount and comma separators
String formatCurrencyAmount(double amount) {
  final formatter = NumberFormat('#,##0.00');
  return formatter.format(amount);
}

