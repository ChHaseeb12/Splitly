import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:splitly/firebase_options.dart';
import 'package:splitly/providers/auth_provider.dart';
import 'package:splitly/providers/expense_provider.dart';
import 'package:splitly/providers/balance_provider.dart';
import 'package:splitly/providers/friend_provider.dart';
import 'package:splitly/providers/group_provider.dart';
import 'package:splitly/providers/recurring_expense_provider.dart';
import 'package:splitly/providers/saved_split_provider.dart';
import 'package:splitly/providers/currency_provider.dart';
import 'package:splitly/providers/locale_provider.dart';
import 'package:splitly/providers/sync_provider.dart';
import 'package:splitly/providers/analytics_provider.dart';
import 'package:splitly/providers/theme_provider.dart';
import 'package:splitly/providers/notification_provider.dart';
import 'package:splitly/providers/budget_provider.dart';
import 'package:splitly/providers/comment_provider.dart';
import 'package:splitly/services/local_storage_service.dart';
import 'package:splitly/services/connectivity_service.dart';
import 'package:splitly/services/sync_service.dart';
import 'package:splitly/l10n/app_localizations.dart';
import 'package:splitly/screens/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize local storage
  await LocalStorageService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create singleton instances for offline services
    final localStorageService = LocalStorageService();
    final connectivityService = ConnectivityService();
    final syncService = SyncService(localStorageService, connectivityService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => BalanceProvider()),
        ChangeNotifierProvider(create: (_) => FriendProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => RecurringExpenseProvider()),
        ChangeNotifierProvider(create: (_) => SavedSplitProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider()..initializeLocale(),
        ),
        ChangeNotifierProvider(
          create: (_) => SyncProvider(
            syncService,
            connectivityService,
            localStorageService,
          )..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Splitly',
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            // Localization configuration
            locale: localeProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
