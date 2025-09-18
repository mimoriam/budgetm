import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  String _selectedCurrency = 'USD';
  List<String> _otherCurrencies = [];
  
  // Keys for SharedPreferences
  static const String _selectedCurrencyKey = 'selectedCurrency';
  static const String _otherCurrenciesKey = 'otherCurrencies';

  CurrencyProvider() {
    _loadFromPreferences();
  }

  String get selectedCurrency => _selectedCurrency;
  List<String> get otherCurrencies => _otherCurrencies;

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load selected currency
      _selectedCurrency = prefs.getString(_selectedCurrencyKey) ?? 'USD';
      
      // Load other currencies
      final otherCurrenciesList = prefs.getStringList(_otherCurrenciesKey);
      if (otherCurrenciesList != null) {
        _otherCurrencies = otherCurrenciesList;
      }
      
      notifyListeners();
    } catch (e) {
      // If there's an error loading preferences, we'll use the default values
      print('Error loading currency preferences: $e');
    }
  }

  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedCurrencyKey, _selectedCurrency);
      await prefs.setStringList(_otherCurrenciesKey, _otherCurrencies);
    } catch (e) {
      print('Error saving currency preferences: $e');
    }
  }

  void setCurrency(String currency) {
    final oldCurrency = _selectedCurrency;
    _selectedCurrency = currency;
    
    // Remove the newly selected currency from other currencies if it's present
    _otherCurrencies.remove(currency);
    
    // Add the old currency to other currencies if it's not already there
    if (oldCurrency != currency && !_otherCurrencies.contains(oldCurrency)) {
      _otherCurrencies.add(oldCurrency);
    }
    
    notifyListeners();
    _saveToPreferences();
  }

  void addOtherCurrency(String currency) {
    if (!_otherCurrencies.contains(currency) && currency != _selectedCurrency) {
      _otherCurrencies.add(currency);
      notifyListeners();
      _saveToPreferences();
    }
  }

  void removeOtherCurrency(String currency) {
    _otherCurrencies.remove(currency);
    notifyListeners();
    _saveToPreferences();
  }
}