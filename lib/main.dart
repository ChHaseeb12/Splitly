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
import 'package:splitly/l10n/app_localizations.dart';
import 'package:splitly/screens/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Splitly',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
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
