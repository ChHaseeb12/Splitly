import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Provider for managing app locale/language
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  bool _isLoading = false;

  Locale get locale => _locale;
  bool get isLoading => _isLoading;

  /// Supported languages with their names
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'pt': 'Português',
    'zh': '中文',
    'hi': 'हिन्दी',
  };

  /// Get language name from code
  String getLanguageName(String code) {
    return supportedLanguages[code] ?? 'English';
  }

  /// Get all supported locales
  List<Locale> getSupportedLocales() {
    return supportedLanguages.keys.map((code) => Locale(code)).toList();
  }

  /// Initialize locale from saved preference
  Future<void> initializeLocale() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Try to get from user profile first
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final language = userDoc.data()?['language'] as String?;
          if (language != null && supportedLanguages.containsKey(language)) {
            _locale = Locale(language);
            await _saveToPreferences(language);
            _isLoading = false;
            notifyListeners();
            return;
          }
        }
      }

      // Fall back to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code');

      if (languageCode != null &&
          supportedLanguages.containsKey(languageCode)) {
        _locale = Locale(languageCode);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error initializing locale: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set locale and save to preferences and Firestore
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    try {
      _isLoading = true;
      _locale = locale;
      notifyListeners();

      // Save to SharedPreferences
      await _saveToPreferences(locale.languageCode);

      // Save to Firestore if user is logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'language': locale.languageCode,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error setting locale: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Save language code to SharedPreferences
  Future<void> _saveToPreferences(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }

  /// Clear saved locale
  Future<void> clearLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('language_code');
      _locale = const Locale('en');
      notifyListeners();
    } catch (e) {
      print('Error clearing locale: $e');
    }
  }
}
