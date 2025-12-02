/// Test Configuration
///
/// This file contains configuration and utilities for testing.

import 'package:flutter_test/flutter_test.dart';

/// Test timeout duration
const testTimeout = Duration(seconds: 30);

/// Test groups configuration
class TestConfig {
  static const bool runUnitTests = true;
  static const bool runWidgetTests = true;
  static const bool runIntegrationTests = true;

  static const bool verbose = true;
}

/// Test utilities
class TestUtils {
  /// Wait for async operations
  static Future<void> waitForAsync() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Pump and settle with timeout
  static Future<void> pumpAndSettleWithTimeout(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await tester.pumpAndSettle(timeout);
  }

  /// Create test date
  static DateTime testDate({
    int year = 2025,
    int month = 12,
    int day = 1,
    int hour = 12,
    int minute = 0,
  }) {
    return DateTime(year, month, day, hour, minute);
  }

  /// Create test timestamp
  static DateTime testTimestamp() {
    return DateTime(2025, 12, 1, 12, 0, 0);
  }
}

/// Mock data generators
class MockData {
  static Map<String, dynamic> mockUser({
    String id = 'user1',
    String email = 'test@example.com',
    String displayName = 'Test User',
  }) {
    return {
      'userId': id,
      'email': email,
      'displayName': displayName,
      'currency': 'USD',
      'language': 'en',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> mockExpense({
    String id = 'exp1',
    double amount = 100.0,
    String category = 'FOOD',
  }) {
    return {
      'expenseId': id,
      'groupId': 'group1',
      'payerId': 'user1',
      'amount': amount,
      'currency': 'USD',
      'category': category,
      'description': 'Test expense',
      'date': DateTime.now().toIso8601String(),
      'participants': {
        'user1': {'userId': 'user1', 'amount': amount / 2},
        'user2': {'userId': 'user2', 'amount': amount / 2},
      },
      'splitType': 'EQUAL',
      'status': 'PENDING',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> mockGroup({
    String id = 'group1',
    String name = 'Test Group',
  }) {
    return {
      'groupId': id,
      'name': name,
      'description': 'Test group description',
      'createdBy': 'user1',
      'members': {
        'user1': {
          'userId': 'user1',
          'role': 'ADMIN',
          'joinedAt': DateTime.now().toIso8601String(),
        },
      },
      'currency': 'USD',
      'simplificationEnabled': true,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}

/// Test assertions
class TestAssertions {
  /// Assert date is recent (within last minute)
  static void assertDateIsRecent(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    expect(difference.inMinutes, lessThan(1));
  }

  /// Assert amount is positive
  static void assertAmountIsPositive(double amount) {
    expect(amount, greaterThan(0));
  }

  /// Assert email is valid format
  static void assertEmailIsValid(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    expect(emailRegex.hasMatch(email), true);
  }

  /// Assert list is not empty
  static void assertListNotEmpty(List list) {
    expect(list, isNotEmpty);
  }
}
