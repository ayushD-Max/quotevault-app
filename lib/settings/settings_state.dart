import 'package:flutter/material.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Color accentColor;
  final double fontScale;

  const SettingsState({
    required this.themeMode,
    required this.accentColor,
    required this.fontScale,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
    double? fontScale,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      fontScale: fontScale ?? this.fontScale,
    );
  }

  static const defaults = SettingsState(
    themeMode: ThemeMode.system,
    accentColor: Color(0xFFE53935), // red primary
    fontScale: 1.0,
  );
}