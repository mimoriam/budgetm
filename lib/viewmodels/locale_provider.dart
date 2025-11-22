import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  static const String _hasPersistedLocaleKey = 'has_persisted_locale';
  
  Locale _currentLocale = const Locale('en'); // Default to English
  bool _isInitialized = false;
  bool _hasPersistedLocale = false;

  Locale get currentLocale => _currentLocale;
  bool get isInitialized => _isInitialized;
  bool get hasPersistedLocale => _hasPersistedLocale;

  /// Initialize the locale provider by loading the saved locale from SharedPreferences
  /// If no saved locale exists, auto-detect device locale (fallback to English if unsupported)
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);
      _hasPersistedLocale = prefs.getBool(_hasPersistedLocaleKey) ?? false;
      
      if (savedLocaleCode != null && _hasPersistedLocale) {
        // User has explicitly chosen a locale
        _currentLocale = Locale(savedLocaleCode);
      } else {
        // No persisted locale - auto-detect device locale
        final deviceLocale = ui.PlatformDispatcher.instance.locale;
        final supportedLocales = AppLocalizations.supportedLocales;
        
        // Check if device locale is supported
        final matchingLocale = supportedLocales.firstWhere(
          (locale) => locale.languageCode == deviceLocale.languageCode,
          orElse: () => const Locale('en'), // Fallback to English
        );
        
        _currentLocale = matchingLocale;
        // Don't persist yet - user hasn't confirmed
      }
    } catch (e) {
      // If there's an error loading the saved locale, keep the default
      debugPrint('Error loading saved locale: $e');
      _currentLocale = const Locale('en');
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  /// Change the current locale and persist it to SharedPreferences
  /// This marks the locale as explicitly chosen by the user
  Future<void> setLocale(Locale locale) async {
    if (_currentLocale == locale && _hasPersistedLocale) return;
    
    _currentLocale = locale;
    _hasPersistedLocale = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      await prefs.setBool(_hasPersistedLocaleKey, true);
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
      case 'ar':
        return 'العربية';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
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
      case 'ar':
        return '🇸🇦';
      case 'ja':
        return '🇯🇵';
      case 'ko':
        return '🇰🇷';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      default:
        return '🌐';
    }
  }
}
