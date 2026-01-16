import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quotevault/app/app_shell.dart';
import 'package:quotevault/features/auth/auth_session_notifier.dart';
import 'package:quotevault/features/auth/login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);

    if (session == null) {
      return const LoginScreen();
    }

    // AppShell already handles tabs. Logout actually happens in Profile via AuthService.signOut().
    return AppShell(
      onLogout: () {},
    );
  }
}