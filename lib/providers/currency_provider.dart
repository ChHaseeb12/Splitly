import 'package:flutter/material.dart';
import '../models/currency_model.dart';
import '../services/currency_service.dart';
import '../data/currencies.dart';

class CurrencyProvider with ChangeNotifier {
  final CurrencyService _currencyService = CurrencyService();

  String _defaultCurrency = 'USD';
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdated;
  Map<String, double> _cachedRates = {};

  String get defaultCurrency => _defaultCurrency;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  // Set default currency
  void setDefaultCurrency(String currencyCode) {
    _defaultCurrency = currencyCode;
    notifyListeners();
  }

  // Get exchange rate between two currencies
  Future<double?> getExchangeRate(String from, String to) async {
    if (from == to) return 1.0;

    try {
      _error = null;
      final rate = await _currencyService.getExchangeRate(from, to);

      if (rate != null) {
        _cachedRates['$from-$to'] = rate;
        _lastUpdated = await _currencyService.getCacheLastUpdated(from);
        notifyListeners();
      }

      return rate;
    } catch (e) {
      _error = 'Failed to get exchange rate: $e';
      notifyListeners();
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

    try {
      _error = null;
      final converted = await _currencyService.convertAmount(
        amount,
        fromCurrency,
        toCurrency,
      );

      if (converted != null) {
        _lastUpdated = await _currencyService.getCacheLastUpdated(fromCurrency);
        notifyListeners();
      }

      return converted;
    } catch (e) {
      _error = 'Failed to convert amount: $e';
      notifyListeners();
      return null;
    }
  }

  // Refresh exchange rates
  Future<void> refreshRates(String baseCurrency) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _currencyService.refreshRates(baseCurrency);
      _lastUpdated = await _currencyService.getCacheLastUpdated(baseCurrency);
      _error = null;
    } catch (e) {
      _error = 'Failed to refresh rates: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get currency by code
  CurrencyModel? getCurrency(String code) {
    return CurrencyData.getCurrency(code);
  }

  // Get all currencies
  List<CurrencyModel> getAllCurrencies() {
    return CurrencyData.currencies;
  }

  // Search currencies
  List<CurrencyModel> searchCurrencies(String query) {
    return CurrencyData.searchCurrencies(query);
  }

  // Get popular currencies
  List<String> getPopularCurrencies() {
    return CurrencyData.getPopularCurrencies();
  }

  // Format amount with currency
  String formatAmount(
    double amount,
    String currencyCode, {
    bool showSymbol = true,
  }) {
    final currency = getCurrency(currencyCode);
    if (currency == null) {
      return amount.toStringAsFixed(2);
    }

    final formatted = amount.toStringAsFixed(currency.decimalPlaces);

    if (showSymbol) {
      return '${currency.symbol}$formatted';
    } else {
      return '$formatted $currencyCode';
    }
  }

  // Get cached rate if available
  double? getCachedRate(String from, String to) {
    return _cachedRates['$from-$to'];
  }

  // Clear all cached rates
  Future<void> clearCache() async {
    await _currencyService.clearCache();
    _cachedRates.clear();
    _lastUpdated = null;
    notifyListeners();
  }
}
