import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
import 'package:splitly/providers/sync_provider.dart';
import 'package:splitly/providers/analytics_provider.dart';
import 'package:splitly/providers/theme_provider.dart';
import 'package:splitly/providers/notification_provider.dart';
import 'package:splitly/providers/budget_provider.dart';
import 'package:splitly/providers/comment_provider.dart';
import 'package:splitly/services/local_storage_service.dart';
import 'package:splitly/services/connectivity_service.dart';
import 'package:splitly/services/sync_service.dart';
import 'package:splitly/screens/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize local storage
  await LocalStorageService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      // Clear session activities when app is closed or paused
      final commentProvider = context.read<CommentProvider>();
      commentProvider.clearSessionActivities();
    }
  }

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
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Splitly',
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
