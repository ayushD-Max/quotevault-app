import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/settings_controller.dart';
import '../theme/app_theme.dart';
import 'app_root.dart';

class QuoteVaultApp extends ConsumerWidget {
  const QuoteVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    final theme = AppTheme.build(
      accent: settings.accentColor,
      isDark: false,
    );
    final darkTheme = AppTheme.build(
      accent: settings.accentColor,
      isDark: true,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuoteVault',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: settings.themeMode,
      home: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(settings.fontScale),
        ),
        child: const AppRoot(),
      ),
    );
  }
}