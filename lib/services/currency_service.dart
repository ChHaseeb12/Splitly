import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  // Using exchangerate-api.com (free tier: 1500 requests/month)
  // Alternative: api.exchangerate.host (free, no API key needed)
  static const String _baseUrl = 'https://api.exchangerate.host';
  static const String _cacheKey = 'exchange_rates_cache';
  static const String _cacheTimeKey = 'exchange_rates_cache_time';
  static const Duration _cacheExpiry = Duration(hours: 24);

  // Get current exchange rate between two currencies
  Future<double?> getExchangeRate(String from, String to) async {
    if (from == to) return 1.0;

    try {
      final rates = await _getExchangeRates(from);
      return rates[to];
    } catch (e) {
      print('Error getting exchange rate: $e');
      return null;
    }
  }

  // Convert amount from one currency to another
  Future<double?> convertAmount(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) async {
    if (fromCurrency == toCurrency) return amount;

    final rate = await getExchangeRate(fromCurrency, toCurrency);
    if (rate == null) return null;

    return amount * rate;
  }

  // Get all exchange rates for a base currency
  Future<Map<String, double>> _getExchangeRates(String baseCurrency) async {
    // Try to get from cache first
    final cachedRates = await _getCachedRates(baseCurrency);
    if (cachedRates != null) {
      return cachedRates;
    }

    // Fetch from API
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/latest?base=$baseCurrency'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = Map<String, double>.from(
          (data['rates'] as Map).map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ),
        );

        // Cache the rates
        await _cacheRates(baseCurrency, rates);

        return rates;
      } else {
        throw Exception(
          'Failed to load exchange rates: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching exchange rates: $e');
      // Try to return expired cache as fallback
      final expiredCache = await _getCachedRates(
        baseCurrency,
        ignoreExpiry: true,
      );
      if (expiredCache != null) {
        return expiredCache;
      }
      rethrow;
    }
  }

  // Get cached exchange rates
  Future<Map<String, double>?> _getCachedRates(
    String baseCurrency, {
    bool ignoreExpiry = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '${_cacheKey}_$baseCurrency';
      final cacheTimeKey = '${_cacheTimeKey}_$baseCurrency';

      final cachedData = prefs.getString(cacheKey);
      final cacheTimeStr = prefs.getString(cacheTimeKey);

      if (cachedData == null || cacheTimeStr == null) {
        return null;
      }

      final cacheTime = DateTime.parse(cacheTimeStr);
      final now = DateTime.now();

      // Check if cache is expired
      if (!ignoreExpiry && now.difference(cacheTime) > _cacheExpiry) {
        return null;
      }

      final rates = Map<String, double>.from(json.decode(cachedData));
      return rates;
    } catch (e) {
      print('Error reading cached rates: $e');
      return null;
    }
  }

  // Cache exchange rates
  Future<void> _cacheRates(
    String baseCurrency,
    Map<String, double> rates,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '${_cacheKey}_$baseCurrency';
      final cacheTimeKey = '${_cacheTimeKey}_$baseCurrency';

      await prefs.setString(cacheKey, json.encode(rates));
      await prefs.setString(cacheTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching rates: $e');
    }
  }

  // Get cache last updated time
  Future<DateTime?> getCacheLastUpdated(String baseCurrency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTimeKey = '${_cacheTimeKey}_$baseCurrency';
      final cacheTimeStr = prefs.getString(cacheTimeKey);

      if (cacheTimeStr == null) return null;

      return DateTime.parse(cacheTimeStr);
    } catch (e) {
      print('Error getting cache time: $e');
      return null;
    }
  }

  // Force refresh exchange rates
  Future<void> refreshRates(String baseCurrency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '${_cacheKey}_$baseCurrency';
      final cacheTimeKey = '${_cacheTimeKey}_$baseCurrency';

      // Clear cache
      await prefs.remove(cacheKey);
      await prefs.remove(cacheTimeKey);

      // Fetch new rates
      await _getExchangeRates(baseCurrency);
    } catch (e) {
      print('Error refreshing rates: $e');
      rethrow;
    }
  }

  // Clear all cached rates
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_cacheKey) || key.startsWith(_cacheTimeKey)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Get historical exchange rate (optional - requires paid API)
  Future<double?> getHistoricalRate(
    String from,
    String to,
    DateTime date,
  ) async {
    // This would require a paid API plan
    // For now, return current rate as fallback
    return getExchangeRate(from, to);
  }
}
