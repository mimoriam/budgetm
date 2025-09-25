import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currency_picker/currency_picker.dart';

class CurrencyProvider extends ChangeNotifier {
  String _selectedCurrencyCode = 'USD';
  String _selectedCurrencySymbol = '\$';
  double _conversionRate = 1.0;
  List<String> _otherCurrencies = [];

  // Keys for SharedPreferences
  static const String _selectedCurrencyCodeKey = 'selectedCurrencyCode';
  static const String _selectedCurrencySymbolKey = 'selectedCurrencySymbol';
  static const String _selectedCurrencyRateKey = 'selectedCurrencyRate';
  static const String _otherCurrenciesKey = 'otherCurrencies';

  CurrencyProvider() {
    _loadFromPreferences();
  }

  String get selectedCurrencyCode => _selectedCurrencyCode;
  String get selectedCurrencySymbol => _selectedCurrencySymbol;
  double get conversionRate => _conversionRate;
  List<String> get otherCurrencies => _otherCurrencies;

  // Get currency symbol for the selected currency
  String get currencySymbol {
    return _selectedCurrencySymbol;
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Only overwrite in-memory values if the preference actually exists.
      // This prevents an in-progress setCurrency call from being overwritten
      // by a concurrently-running initial load.
      if (prefs.containsKey(_selectedCurrencyCodeKey)) {
        _selectedCurrencyCode = prefs.getString(_selectedCurrencyCodeKey)!;
      }

      if (prefs.containsKey(_selectedCurrencySymbolKey)) {
        _selectedCurrencySymbol = prefs.getString(_selectedCurrencySymbolKey)!;
      } else {
        // If symbol not stored, attempt to resolve from code (or keep current)
        _selectedCurrencySymbol =
            CurrencyService().findByCode(_selectedCurrencyCode)?.symbol ??
                _selectedCurrencySymbol;
      }

      if (prefs.containsKey(_selectedCurrencyRateKey)) {
        _conversionRate = prefs.getDouble(_selectedCurrencyRateKey) ?? _conversionRate;
      }

      final otherCurrenciesList = prefs.getStringList(_otherCurrenciesKey);
      if (otherCurrenciesList != null) {
        _otherCurrencies = otherCurrenciesList;
      }

      notifyListeners();
    } catch (e) {
      // If there's an error loading preferences, we'll keep the current values
      print('Error loading currency preferences: $e');
    }
  }

  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedCurrencyCodeKey, _selectedCurrencyCode);
      await prefs.setString(
          _selectedCurrencySymbolKey, _selectedCurrencySymbol);
      await prefs.setDouble(_selectedCurrencyRateKey, _conversionRate);
      await prefs.setStringList(_otherCurrenciesKey, _otherCurrencies);
    } catch (e) {
      print('Error saving currency preferences: $e');
    }
  }

  /// Set selected currency and its conversion rate.
  /// Accepts a [Currency] object and a conversion [rate].
  Future<void> setCurrency(Currency currency, double rate) async {
    final oldCode = _selectedCurrencyCode;
    _selectedCurrencyCode = currency.code;
    _selectedCurrencySymbol = currency.symbol ?? _selectedCurrencySymbol;
    _conversionRate = rate;

    // Update other currencies list
    _otherCurrencies.remove(_selectedCurrencyCode);
    if (oldCode != _selectedCurrencyCode &&
        !_otherCurrencies.contains(oldCode)) {
      _otherCurrencies.add(oldCode);
    }

    notifyListeners();
    // Persist changes and wait for completion so callers can reliably observe persisted state.
    await _saveToPreferences();
  }

  void addOtherCurrency(String currencyCode) {
    if (!_otherCurrencies.contains(currencyCode) &&
        currencyCode != _selectedCurrencyCode) {
      _otherCurrencies.add(currencyCode);
      notifyListeners();
      _saveToPreferences();
    }
  }

  void removeOtherCurrency(String currencyCode) {
    _otherCurrencies.remove(currencyCode);
    notifyListeners();
    _saveToPreferences();
  }
}