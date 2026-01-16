import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/auth_gate.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        onDone: () => setState(() => _showSplash = false),
      );
    }
    return const AuthGate();
  }
}