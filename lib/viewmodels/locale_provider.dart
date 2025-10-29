import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  
  Locale _currentLocale = const Locale('en'); // Default to English
  bool _isInitialized = false;

  Locale get currentLocale => _currentLocale;
  bool get isInitialized => _isInitialized;

  /// Initialize the locale provider by loading the saved locale from SharedPreferences
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);
      
      if (savedLocaleCode != null) {
        _currentLocale = Locale(savedLocaleCode);
      }
    } catch (e) {
      // If there's an error loading the saved locale, keep the default
      debugPrint('Error loading saved locale: $e');
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  /// Change the current locale and persist it to SharedPreferences
  Future<void> setLocale(Locale locale) async {
    if (_currentLocale == locale) return;
    
    _currentLocale = locale;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  /// Get the display name for a locale
  String getLocaleDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  /// Get the flag emoji for a locale
  String getLocaleFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'es':
        return '🇪🇸';
      default:
        return '🌐';
    }
  }
}
