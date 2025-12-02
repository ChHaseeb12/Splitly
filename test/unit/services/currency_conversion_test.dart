import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Currency Conversion Tests', () {
    test('should convert USD to EUR correctly', () {
      final amount = 100.0;
      final rate = 0.92; // 1 USD = 0.92 EUR

      final converted = amount * rate;

      expect(converted, 92.0);
    });

    test('should convert EUR to USD correctly', () {
      final amount = 92.0;
      final rate = 1.087; // 1 EUR = 1.087 USD

      final converted = amount * rate;

      expect(converted, closeTo(100.0, 0.1));
    });

    test('should handle same currency conversion', () {
      final amount = 100.0;
      final rate = 1.0;

      final converted = amount * rate;

      expect(converted, amount);
    });

    test('should round to 2 decimal places', () {
      final amount = 100.0;
      final rate = 0.923456;

      final converted = (amount * rate * 100).round() / 100;

      expect(converted, 92.35);
    });

    test('should handle zero amount', () {
      final amount = 0.0;
      final rate = 0.92;

      final converted = amount * rate;

      expect(converted, 0.0);
    });

    test('should handle large amounts', () {
      final amount = 1000000.0;
      final rate = 0.92;

      final converted = amount * rate;

      expect(converted, 920000.0);
    });

    test('should calculate inverse rate correctly', () {
      final rate = 0.92; // USD to EUR
      final inverseRate = 1 / rate; // EUR to USD

      expect(inverseRate, closeTo(1.087, 0.001));
    });

    test('should handle multiple currency conversions', () {
      // USD -> EUR -> GBP
      final usdAmount = 100.0;
      final usdToEur = 0.92;
      final eurToGbp = 0.85;

      final eurAmount = usdAmount * usdToEur;
      final gbpAmount = eurAmount * eurToGbp;

      expect(gbpAmount, closeTo(78.2, 0.1));
    });
  });

  group('Currency Formatting Tests', () {
    test('should format USD correctly', () {
      final amount = 1234.56;
      final symbol = '\$';
      final formatted = '$symbol${amount.toStringAsFixed(2)}';

      expect(formatted, '\$1234.56');
    });

    test('should format EUR correctly', () {
      final amount = 1234.56;
      final symbol = '€';
      final formatted = '${amount.toStringAsFixed(2)} $symbol';

      expect(formatted, '1234.56 €');
    });

    test('should handle zero decimal currencies', () {
      final amount = 1234.0;
      final formatted = amount.toStringAsFixed(0);

      expect(formatted, '1234');
    });

    test('should handle 3 decimal currencies', () {
      final amount = 1234.567;
      final formatted = amount.toStringAsFixed(3);

      expect(formatted, '1234.567');
    });
  });
}
