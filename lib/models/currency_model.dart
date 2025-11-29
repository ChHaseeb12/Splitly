class CurrencyModel {
  final String code; // ISO 4217 code (e.g., USD, EUR)
  final String name; // Full name (e.g., US Dollar)
  final String symbol; // Currency symbol (e.g., $, €)
  final int decimalPlaces; // Number of decimal places (usually 2)
  final String flag; // Country flag emoji

  CurrencyModel({
    required this.code,
    required this.name,
    required this.symbol,
    this.decimalPlaces = 2,
    required this.flag,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'decimalPlaces': decimalPlaces,
      'flag': flag,
    };
  }

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      code: json['code'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      decimalPlaces: json['decimalPlaces'] as int? ?? 2,
      flag: json['flag'] as String,
    );
  }
}

class ExchangeRateModel {
  final String baseCurrency;
  final Map<String, double> rates;
  final DateTime lastUpdated;

  ExchangeRateModel({
    required this.baseCurrency,
    required this.rates,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'baseCurrency': baseCurrency,
      'rates': rates,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      baseCurrency: json['baseCurrency'] as String,
      rates: Map<String, double>.from(json['rates'] as Map),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}
