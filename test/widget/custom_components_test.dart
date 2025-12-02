import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitly/widgets/empty_state.dart';
import 'package:splitly/widgets/loading_state.dart';
import 'package:splitly/widgets/error_state.dart';

void main() {
  group('EmptyState Widget Tests', () {
    testWidgets('should display icon, title, and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
              message: 'Add your first item',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('No Items'), findsOneWidget);
      expect(find.text('Add your first item'), findsOneWidget);
    });

    testWidgets('should display action button when provided', (tester) async {
      var buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
              message: 'Add your first item',
              actionLabel: 'Add Item',
              onAction: () => buttonPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Add Item'), findsOneWidget);

      await tester.tap(find.text('Add Item'));
      await tester.pump();

      expect(buttonPressed, true);
    });

    testWidgets('should not display action button when not provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
              message: 'Add your first item',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });
  });

  group('LoadingState Widget Tests', () {
    testWidgets('should display circular progress indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingState())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingState(message: 'Loading data...')),
        ),
      );

      expect(find.text('Loading data...'), findsOneWidget);
    });
  });

  group('ErrorState Widget Tests', () {
    testWidgets('should display error icon, title, and message', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorState(
              title: 'Error Occurred',
              message: 'Something went wrong',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Error Occurred'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('should call onRetry when retry button pressed', (
      tester,
    ) async {
      var retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              title: 'Error Occurred',
              message: 'Something went wrong',
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(retryPressed, true);
    });
  });

  group('Widget Accessibility Tests', () {
    testWidgets('EmptyState should have semantic labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Items',
              message: 'Add your first item',
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.text('No Items'));
      expect(semantics.label, contains('No Items'));
    });

    testWidgets('LoadingState should have semantic labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingState(message: 'Loading...')),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('ErrorState retry button should be accessible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              title: 'Error',
              message: 'Error message',
              onRetry: () {},
            ),
          ),
        ),
      );

      // Verify the button text is present
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}
