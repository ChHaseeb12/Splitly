import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility class for locale-aware formatting
class LocaleUtils {
  /// Format date according to locale
  static String formatDate(DateTime date, Locale locale) {
    final format = DateFormat.yMMMd(locale.languageCode);
    return format.format(date);
  }

  /// Format date with time according to locale
  static String formatDateTime(DateTime dateTime, Locale locale) {
    final format = DateFormat.yMMMd(locale.languageCode).add_jm();
    return format.format(dateTime);
  }

  /// Format time according to locale
  static String formatTime(DateTime time, Locale locale) {
    final format = DateFormat.jm(locale.languageCode);
    return format.format(time);
  }

  /// Format number according to locale
  static String formatNumber(double number, Locale locale) {
    final format = NumberFormat.decimalPattern(locale.languageCode);
    return format.format(number);
  }

  /// Format currency amount according to locale
  static String formatCurrency(
    double amount,
    String currencyCode,
    Locale locale,
  ) {
    final format = NumberFormat.currency(
      locale: locale.languageCode,
      symbol: _getCurrencySymbol(currencyCode),
      decimalDigits: _getDecimalPlaces(currencyCode),
    );
    return format.format(amount);
  }

  /// Format currency amount with custom symbol
  static String formatCurrencyWithSymbol(
    double amount,
    String symbol,
    Locale locale, {
    int decimalPlaces = 2,
  }) {
    final format = NumberFormat.currency(
      locale: locale.languageCode,
      symbol: symbol,
      decimalDigits: decimalPlaces,
    );
    return format.format(amount);
  }

  /// Format percentage according to locale
  static String formatPercentage(double percentage, Locale locale) {
    final format = NumberFormat.percentPattern(locale.languageCode);
    return format.format(percentage / 100);
  }

  /// Get relative time string (e.g., "2 hours ago")
  static String getRelativeTime(DateTime dateTime, Locale locale) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1
          ? '1 day ago'
          : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? '1 minute ago'
          : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  /// Get currency symbol from currency code
  static String _getCurrencySymbol(String currencyCode) {
    final symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CNY': '¥',
      'INR': '₹',
      'BRL': 'R\$',
      'CAD': 'C\$',
      'AUD': 'A\$',
      'CHF': 'CHF',
      'KRW': '₩',
      'RUB': '₽',
      'MXN': 'MX\$',
      'ZAR': 'R',
      'SGD': 'S\$',
      'HKD': 'HK\$',
      'SEK': 'kr',
      'NOK': 'kr',
      'DKK': 'kr',
      'PLN': 'zł',
      'THB': '฿',
      'IDR': 'Rp',
      'MYR': 'RM',
      'PHP': '₱',
      'TRY': '₺',
      'AED': 'د.إ',
      'SAR': 'ر.س',
    };
    return symbols[currencyCode] ?? currencyCode;
  }

  /// Get decimal places for currency
  static int _getDecimalPlaces(String currencyCode) {
    final noDecimalCurrencies = ['JPY', 'KRW', 'VND', 'CLP'];
    final threeDecimalCurrencies = ['BHD', 'KWD', 'OMR', 'TND'];

    if (noDecimalCurrencies.contains(currencyCode)) {
      return 0;
    } else if (threeDecimalCurrencies.contains(currencyCode)) {
      return 3;
    }
    return 2;
  }

  /// Check if locale uses 12-hour time format
  static bool uses12HourFormat(Locale locale) {
    final use12Hour = ['en', 'hi'];
    return use12Hour.contains(locale.languageCode);
  }

  /// Check if locale uses comma as decimal separator
  static bool usesCommaDecimal(Locale locale) {
    final commaLocales = ['de', 'fr', 'es', 'pt'];
    return commaLocales.contains(locale.languageCode);
  }

  /// Get first day of week for locale (0 = Sunday, 1 = Monday)
  static int getFirstDayOfWeek(Locale locale) {
    // Most locales start week on Monday, except US (Sunday)
    return locale.languageCode == 'en' ? 0 : 1;
  }

  /// Format compact number (e.g., 1.2K, 3.4M)
  static String formatCompactNumber(double number, Locale locale) {
    final format = NumberFormat.compact(locale: locale.languageCode);
    return format.format(number);
  }

  /// Parse date string according to locale
  static DateTime? parseDate(String dateString, Locale locale) {
    try {
      final format = DateFormat.yMMMd(locale.languageCode);
      return format.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
