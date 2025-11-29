import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitly/providers/auth_provider.dart';
import 'package:splitly/screens/auth/login_screen.dart';
import 'package:splitly/screens/auth/register_screen.dart';
import 'package:splitly/screens/home/splash_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool showLoginPage = true;

  void toggleAuthMode() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Authenticated - show splash then navigate to home
        if (authProvider.isAuthenticated) {
          return const SplashScreen();
        }

        // Unauthenticated - show login or register
        return showLoginPage
            ? LoginScreen(onToggleAuthMode: toggleAuthMode)
            : RegisterScreen(onToggleAuthMode: toggleAuthMode);
      },
    );
  }
}
