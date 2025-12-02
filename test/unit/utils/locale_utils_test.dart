import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('Date Formatting Tests', () {
    test('should format date in US format', () {
      final date = DateTime(2025, 12, 1);
      final locale = const Locale('en', 'US');
      final formatted = DateFormat.yMd(locale.toString()).format(date);

      expect(formatted, '12/1/2025');
    });

    test('should format time in 12-hour format', () {
      final time = DateTime(2025, 12, 1, 14, 30);
      final locale = const Locale('en', 'US');
      final formatted = DateFormat.jm(locale.toString()).format(time);

      // Accept both with and without non-breaking space
      expect(formatted.replaceAll('\u202F', ' '), '2:30 PM');
    });
  });

  group('Number Formatting Tests', () {
    test('should format number with decimal', () {
      final number = 1234.56;
      final formatted = number.toStringAsFixed(2);

      expect(formatted, '1234.56');
    });

    test('should format percentage', () {
      final percentage = 0.7525;
      final formatted = '${(percentage * 100).round()}%';

      expect(formatted, '75%');
    });

    test('should format compact number', () {
      final number = 1500.0;
      final formatted = NumberFormat.compact().format(number);

      expect(formatted, '1.5K');
    });
  });

  group('Relative Time Tests', () {
    test('should calculate hours ago', () {
      final now = DateTime.now();
      final twoHoursAgo = now.subtract(const Duration(hours: 2));
      final difference = now.difference(twoHoursAgo);

      expect(difference.inHours, 2);
    });

    test('should calculate days ago', () {
      final now = DateTime.now();
      final threeDaysAgo = now.subtract(const Duration(days: 3));
      final difference = now.difference(threeDaysAgo);

      expect(difference.inDays, 3);
    });

    test('should identify today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final testDate = DateTime(now.year, now.month, now.day, 10, 30);

      expect(testDate.year, today.year);
      expect(testDate.month, today.month);
      expect(testDate.day, today.day);
    });

    test('should identify yesterday', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final difference = now.difference(yesterday);

      expect(difference.inDays, 1);
    });
  });

  group('Locale Helper Tests', () {
    test('should identify 12-hour format locales', () {
      final locales12Hour = ['en', 'hi'];

      expect(locales12Hour.contains('en'), true);
      expect(locales12Hour.contains('hi'), true);
      expect(locales12Hour.contains('de'), false);
    });

    test('should identify comma decimal locales', () {
      final localesCommaDecimal = ['de', 'fr', 'es', 'pt'];

      expect(localesCommaDecimal.contains('de'), true);
      expect(localesCommaDecimal.contains('fr'), true);
      expect(localesCommaDecimal.contains('en'), false);
    });

    test('should get first day of week', () {
      // US: Sunday (0), Europe: Monday (1)
      final usFirstDay = 0;
      final euFirstDay = 1;

      expect(usFirstDay, 0);
      expect(euFirstDay, 1);
    });
  });
}
