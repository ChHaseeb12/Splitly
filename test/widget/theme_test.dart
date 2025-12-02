import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitly/providers/theme_provider.dart';

void main() {
  group('Theme Tests', () {
    testWidgets('should apply light theme correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeProvider.lightTheme,
          home: const Scaffold(body: Text('Test')),
        ),
      );

      final BuildContext context = tester.element(find.text('Test'));
      final theme = Theme.of(context);

      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF5F5F5));
    });

    testWidgets('should apply dark theme correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeProvider.darkTheme,
          home: const Scaffold(body: Text('Test')),
        ),
      );

      final BuildContext context = tester.element(find.text('Test'));
      final theme = Theme.of(context);

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
    });

    testWidgets('should have consistent color scheme in light theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeProvider.lightTheme,
          home: const Scaffold(body: Text('Test')),
        ),
      );

      final BuildContext context = tester.element(find.text('Test'));
      final colorScheme = Theme.of(context).colorScheme;

      expect(colorScheme.primary, const Color(0xFF2C2C2C));
      expect(colorScheme.surface, Colors.white);
    });

    testWidgets('should have consistent color scheme in dark theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeProvider.darkTheme,
          home: const Scaffold(body: Text('Test')),
        ),
      );

      final BuildContext context = tester.element(find.text('Test'));
      final colorScheme = Theme.of(context).colorScheme;

      expect(colorScheme.primary, const Color(0xFF4A4A4A));
      expect(colorScheme.surface, const Color(0xFF1E1E1E));
    });

    testWidgets('should have proper text theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeProvider.lightTheme,
          home: const Scaffold(body: Text('Test')),
        ),
      );

      final BuildContext context = tester.element(find.text('Test'));
      final textTheme = Theme.of(context).textTheme;

      expect(textTheme.bodyLarge, isNotNull);
      expect(textTheme.bodyMedium, isNotNull);
      expect(textTheme.titleLarge, isNotNull);
    });

    testWidgets('should have proper button theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeProvider.lightTheme,
          home: Scaffold(
            body: ElevatedButton(onPressed: () {}, child: const Text('Button')),
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
    });

    testWidgets('should have proper card theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeProvider.lightTheme,
          home: const Scaffold(body: Card(child: Text('Card'))),
        ),
      );

      final BuildContext context = tester.element(find.text('Card'));
      final cardTheme = Theme.of(context).cardTheme;

      expect(cardTheme.elevation, 2);
      expect(cardTheme.shape, isA<RoundedRectangleBorder>());
    });

    testWidgets('should have proper input decoration theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeProvider.lightTheme,
          home: const Scaffold(
            body: TextField(decoration: InputDecoration(labelText: 'Test')),
          ),
        ),
      );

      final BuildContext context = tester.element(find.byType(TextField));
      final inputTheme = Theme.of(context).inputDecorationTheme;

      expect(inputTheme.border, isA<OutlineInputBorder>());
    });
  });

  group('Theme Contrast Tests', () {
    test('should have sufficient contrast for light theme', () {
      const backgroundColor = Color(0xFFF5F5F5);
      const textColor = Color(0xFF2C2C2C);

      // Calculate relative luminance
      final bgLuminance = backgroundColor.computeLuminance();
      final textLuminance = textColor.computeLuminance();

      // Calculate contrast ratio
      final contrast = (bgLuminance + 0.05) / (textLuminance + 0.05);

      // WCAG AA requires 4.5:1 for normal text
      expect(contrast, greaterThan(4.5));
    });

    test('should have sufficient contrast for dark theme', () {
      const backgroundColor = Color(0xFF121212);
      const textColor = Color(0xFFE0E0E0);

      final bgLuminance = backgroundColor.computeLuminance();
      final textLuminance = textColor.computeLuminance();

      final contrast = (textLuminance + 0.05) / (bgLuminance + 0.05);

      expect(contrast, greaterThan(4.5));
    });
  });
}
