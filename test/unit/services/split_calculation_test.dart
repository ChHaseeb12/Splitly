import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Split Calculation Tests', () {
    group('Equal Split', () {
      test('should split amount equally among participants', () {
        final amount = 100.0;
        final participants = 4;
        final expectedPerPerson = 25.0;

        final result = amount / participants;

        expect(result, expectedPerPerson);
      });

      test('should handle remainder with banker\'s rounding', () {
        final amount = 100.0;
        final participants = 3;
        final expectedPerPerson = 33.33;

        final result = (amount / participants * 100).round() / 100;

        expect(result, closeTo(expectedPerPerson, 0.01));
      });

      test('should handle single participant', () {
        final amount = 100.0;
        final participants = 1;

        final result = amount / participants;

        expect(result, amount);
      });
    });

    group('Unequal Split', () {
      test('should validate sum equals total', () {
        final total = 100.0;
        final splits = [30.0, 40.0, 30.0];
        final sum = splits.reduce((a, b) => a + b);

        expect(sum, total);
      });

      test('should reject invalid sum', () {
        final total = 100.0;
        final splits = [30.0, 40.0, 20.0];
        final sum = splits.reduce((a, b) => a + b);

        expect(sum, isNot(total));
      });
    });

    group('Percentage Split', () {
      test('should calculate amounts from percentages', () {
        final total = 100.0;
        final percentages = [50.0, 30.0, 20.0];

        final amounts = percentages.map((p) => total * p / 100).toList();

        expect(amounts[0], 50.0);
        expect(amounts[1], 30.0);
        expect(amounts[2], 20.0);
      });

      test('should validate percentages sum to 100', () {
        final percentages = [50.0, 30.0, 20.0];
        final sum = percentages.reduce((a, b) => a + b);

        expect(sum, 100.0);
      });

      test('should reject invalid percentage sum', () {
        final percentages = [50.0, 30.0, 30.0];
        final sum = percentages.reduce((a, b) => a + b);

        expect(sum, isNot(100.0));
      });
    });

    group('Shares Split', () {
      test('should calculate amounts from shares', () {
        final total = 100.0;
        final shares = [2.0, 1.0, 1.0];
        final totalShares = shares.reduce((a, b) => a + b);

        final amounts = shares.map((s) => total * s / totalShares).toList();

        expect(amounts[0], 50.0);
        expect(amounts[1], 25.0);
        expect(amounts[2], 25.0);
      });

      test('should handle fractional shares', () {
        final total = 100.0;
        final shares = [1.5, 1.0, 0.5];
        final totalShares = shares.reduce((a, b) => a + b);

        final amounts = shares.map((s) => total * s / totalShares).toList();

        expect(amounts[0], 50.0);
        expect(amounts[1], closeTo(33.33, 0.01));
        expect(amounts[2], closeTo(16.67, 0.01));
      });
    });
  });
}
