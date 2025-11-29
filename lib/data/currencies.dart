import '../models/currency_model.dart';

class CurrencyData {
  static final List<CurrencyModel> currencies = [
    // Major Currencies
    CurrencyModel(code: 'USD', name: 'US Dollar', symbol: '\$', flag: '🇺🇸'),
    CurrencyModel(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺'),
    CurrencyModel(
      code: 'GBP',
      name: 'British Pound',
      symbol: '£',
      flag: '🇬🇧',
    ),
    CurrencyModel(
      code: 'JPY',
      name: 'Japanese Yen',
      symbol: '¥',
      decimalPlaces: 0,
      flag: '🇯🇵',
    ),
    CurrencyModel(code: 'CHF', name: 'Swiss Franc', symbol: 'Fr', flag: '🇨🇭'),
    CurrencyModel(
      code: 'CAD',
      name: 'Canadian Dollar',
      symbol: 'C\$',
      flag: '🇨🇦',
    ),
    CurrencyModel(
      code: 'AUD',
      name: 'Australian Dollar',
      symbol: 'A\$',
      flag: '🇦🇺',
    ),
    CurrencyModel(
      code: 'NZD',
      name: 'New Zealand Dollar',
      symbol: 'NZ\$',
      flag: '🇳🇿',
    ),

    // Asian Currencies
    CurrencyModel(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', flag: '🇨🇳'),
    CurrencyModel(code: 'INR', name: 'Indian Rupee', symbol: '₹', flag: '🇮🇳'),
    CurrencyModel(
      code: 'KRW',
      name: 'South Korean Won',
      symbol: '₩',
      decimalPlaces: 0,
      flag: '🇰🇷',
    ),
    CurrencyModel(
      code: 'SGD',
      name: 'Singapore Dollar',
      symbol: 'S\$',
      flag: '🇸🇬',
    ),
    CurrencyModel(
      code: 'HKD',
      name: 'Hong Kong Dollar',
      symbol: 'HK\$',
      flag: '🇭🇰',
    ),
    CurrencyModel(code: 'THB', name: 'Thai Baht', symbol: '฿', flag: '🇹🇭'),
    CurrencyModel(
      code: 'MYR',
      name: 'Malaysian Ringgit',
      symbol: 'RM',
      flag: '🇲🇾',
    ),
    CurrencyModel(
      code: 'IDR',
      name: 'Indonesian Rupiah',
      symbol: 'Rp',
      decimalPlaces: 0,
      flag: '🇮🇩',
    ),
    CurrencyModel(
      code: 'PHP',
      name: 'Philippine Peso',
      symbol: '₱',
      flag: '🇵🇭',
    ),
    CurrencyModel(
      code: 'VND',
      name: 'Vietnamese Dong',
      symbol: '₫',
      decimalPlaces: 0,
      flag: '🇻🇳',
    ),
    CurrencyModel(
      code: 'PKR',
      name: 'Pakistani Rupee',
      symbol: '₨',
      flag: '🇵🇰',
    ),
    CurrencyModel(
      code: 'BDT',
      name: 'Bangladeshi Taka',
      symbol: '৳',
      flag: '🇧🇩',
    ),

    // Middle Eastern Currencies
    CurrencyModel(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ', flag: '🇦🇪'),
    CurrencyModel(code: 'SAR', name: 'Saudi Riyal', symbol: '﷼', flag: '🇸🇦'),
    CurrencyModel(
      code: 'QAR',
      name: 'Qatari Riyal',
      symbol: 'ر.ق',
      flag: '🇶🇦',
    ),
    CurrencyModel(
      code: 'KWD',
      name: 'Kuwaiti Dinar',
      symbol: 'د.ك',
      decimalPlaces: 3,
      flag: '🇰🇼',
    ),
    CurrencyModel(
      code: 'ILS',
      name: 'Israeli Shekel',
      symbol: '₪',
      flag: '🇮🇱',
    ),
    CurrencyModel(code: 'TRY', name: 'Turkish Lira', symbol: '₺', flag: '🇹🇷'),

    // European Currencies
    CurrencyModel(
      code: 'SEK',
      name: 'Swedish Krona',
      symbol: 'kr',
      flag: '🇸🇪',
    ),
    CurrencyModel(
      code: 'NOK',
      name: 'Norwegian Krone',
      symbol: 'kr',
      flag: '🇳🇴',
    ),
    CurrencyModel(
      code: 'DKK',
      name: 'Danish Krone',
      symbol: 'kr',
      flag: '🇩🇰',
    ),
    CurrencyModel(
      code: 'PLN',
      name: 'Polish Zloty',
      symbol: 'zł',
      flag: '🇵🇱',
    ),
    CurrencyModel(
      code: 'CZK',
      name: 'Czech Koruna',
      symbol: 'Kč',
      flag: '🇨🇿',
    ),
    CurrencyModel(
      code: 'HUF',
      name: 'Hungarian Forint',
      symbol: 'Ft',
      decimalPlaces: 0,
      flag: '🇭🇺',
    ),
    CurrencyModel(
      code: 'RON',
      name: 'Romanian Leu',
      symbol: 'lei',
      flag: '🇷🇴',
    ),
    CurrencyModel(
      code: 'BGN',
      name: 'Bulgarian Lev',
      symbol: 'лв',
      flag: '🇧🇬',
    ),
    CurrencyModel(
      code: 'RUB',
      name: 'Russian Ruble',
      symbol: '₽',
      flag: '🇷🇺',
    ),
    CurrencyModel(
      code: 'UAH',
      name: 'Ukrainian Hryvnia',
      symbol: '₴',
      flag: '🇺🇦',
    ),

    // Latin American Currencies
    CurrencyModel(
      code: 'BRL',
      name: 'Brazilian Real',
      symbol: 'R\$',
      flag: '🇧🇷',
    ),
    CurrencyModel(
      code: 'MXN',
      name: 'Mexican Peso',
      symbol: 'Mex\$',
      flag: '🇲🇽',
    ),
    CurrencyModel(
      code: 'ARS',
      name: 'Argentine Peso',
      symbol: '\$',
      flag: '🇦🇷',
    ),
    CurrencyModel(
      code: 'CLP',
      name: 'Chilean Peso',
      symbol: '\$',
      decimalPlaces: 0,
      flag: '🇨🇱',
    ),
    CurrencyModel(
      code: 'COP',
      name: 'Colombian Peso',
      symbol: '\$',
      flag: '🇨🇴',
    ),
    CurrencyModel(
      code: 'PEN',
      name: 'Peruvian Sol',
      symbol: 'S/',
      flag: '🇵🇪',
    ),

    // African Currencies
    CurrencyModel(
      code: 'ZAR',
      name: 'South African Rand',
      symbol: 'R',
      flag: '🇿🇦',
    ),
    CurrencyModel(
      code: 'EGP',
      name: 'Egyptian Pound',
      symbol: '£',
      flag: '🇪🇬',
    ),
    CurrencyModel(
      code: 'NGN',
      name: 'Nigerian Naira',
      symbol: '₦',
      flag: '🇳🇬',
    ),
    CurrencyModel(
      code: 'KES',
      name: 'Kenyan Shilling',
      symbol: 'KSh',
      flag: '🇰🇪',
    ),
    CurrencyModel(
      code: 'MAD',
      name: 'Moroccan Dirham',
      symbol: 'د.م.',
      flag: '🇲🇦',
    ),

    // Other Major Currencies
    CurrencyModel(
      code: 'TWD',
      name: 'Taiwan Dollar',
      symbol: 'NT\$',
      flag: '🇹🇼',
    ),
    CurrencyModel(
      code: 'BTC',
      name: 'Bitcoin',
      symbol: '₿',
      decimalPlaces: 8,
      flag: '🪙',
    ),
  ];

  static CurrencyModel? getCurrency(String code) {
    try {
      return currencies.firstWhere((c) => c.code == code);
    } catch (e) {
      return null;
    }
  }

  static List<CurrencyModel> searchCurrencies(String query) {
    if (query.isEmpty) return currencies;

    final lowerQuery = query.toLowerCase();
    return currencies.where((currency) {
      return currency.code.toLowerCase().contains(lowerQuery) ||
          currency.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static List<String> getPopularCurrencies() {
    return ['USD', 'EUR', 'GBP', 'JPY', 'CNY', 'INR', 'CAD', 'AUD'];
  }
}
