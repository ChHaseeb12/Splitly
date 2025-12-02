# Splitly Test Suite

This directory contains comprehensive tests for the Splitly application.

## Test Structure

```
test/
├── unit/                    # Unit tests
│   ├── models/             # Model tests
│   ├── services/           # Service logic tests
│   └── utils/              # Utility function tests
├── widget/                 # Widget tests
├── integration/            # Integration tests
├── test_config.dart        # Test configuration
└── README.md              # This file

test_driver/
└── app_test.dart          # Integration test driver
```

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/unit/models/expense_model_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### View Coverage Report
```bash
# Install lcov (if not already installed)
# On macOS: brew install lcov
# On Linux: sudo apt-get install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html
```

### Run Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

## Test Categories

### Unit Tests

**Models:**
- ExpenseModel serialization/deserialization
- Data validation
- Model methods

**Services:**
- Split calculation (equal, unequal, percentage, shares)
- Debt simplification algorithm
- Currency conversion
- Balance calculations

**Utils:**
- Date formatting
- Number formatting
- Locale utilities
- Relative time calculations

### Widget Tests

**Custom Components:**
- EmptyState widget
- LoadingState widget
- ErrorState widget
- ExpenseCard widget
- DebtCard widget
- GroupCard widget

**Theme:**
- Light theme application
- Dark theme application
- Color contrast
- Accessibility

### Integration Tests

**Authentication Flow:**
- Email validation
- Password validation
- Auth state transitions
- Error handling

**Expense Flow:**
- Expense creation
- Expense editing
- Expense deletion
- Filtering

**Sync Flow:**
- Offline queue management
- Online sync processing
- Retry logic
- Conflict resolution

## Test Coverage Goals

- **Unit Tests:** >80% coverage
- **Widget Tests:** All custom widgets
- **Integration Tests:** All critical user flows

## Writing Tests

### Unit Test Example
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyClass', () {
    test('should do something', () {
      // Arrange
      final input = 'test';
      
      // Act
      final result = myFunction(input);
      
      // Assert
      expect(result, 'expected');
    });
  });
}
```

### Widget Test Example
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MyWidget should display text', (tester) async {
    // Build widget
    await tester.pumpWidget(
      const MaterialApp(
        home: MyWidget(text: 'Hello'),
      ),
    );
    
    // Verify
    expect(find.text('Hello'), findsOneWidget);
  });
}
```

## Test Best Practices

1. **Arrange-Act-Assert:** Structure tests clearly
2. **Descriptive Names:** Use clear test names
3. **One Assertion:** Test one thing at a time
4. **Independent Tests:** Tests should not depend on each other
5. **Mock External Dependencies:** Use mocks for Firebase, etc.
6. **Test Edge Cases:** Include boundary conditions
7. **Test Error Handling:** Verify error scenarios

## Continuous Integration

Tests are automatically run on:
- Every commit
- Pull requests
- Before deployment

## Test Maintenance

- Update tests when features change
- Remove obsolete tests
- Keep test data realistic
- Review test coverage regularly

## Troubleshooting

### Tests Failing
1. Check test output for specific errors
2. Verify test data is correct
3. Ensure dependencies are up to date
4. Check for async timing issues

### Coverage Not Generated
1. Ensure `--coverage` flag is used
2. Check that lcov is installed
3. Verify coverage directory exists

### Widget Tests Timing Out
1. Increase timeout duration
2. Use `pumpAndSettle` appropriately
3. Check for infinite animations

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing](https://docs.flutter.dev/cookbook/testing/integration/introduction)
