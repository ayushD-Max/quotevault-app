import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateNotifierProvider, StateNotifier;
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>(
  (ref) => SettingsController()..loadFromDisk(),
);

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(SettingsState.defaults);

  static const _kThemeMode = 'themeMode';
  static const _kAccent = 'accent';
  static const _kFontScale = 'fontScale';

  Future<void> loadFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeIndex = prefs.getInt(_kThemeMode);
      final accentValue = prefs.getInt(_kAccent);
      final fontScale = prefs.getDouble(_kFontScale);

      state = state.copyWith(
        themeMode: themeIndex == null ? state.themeMode : ThemeMode.values[themeIndex],
        accentColor: accentValue == null ? state.accentColor : Color(accentValue),
        fontScale: fontScale ?? state.fontScale,
      );
    } catch (_) {
      // defensive: keep defaults
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kThemeMode, mode.index);
    } catch (_) {}
  }

  Future<void> setAccentColor(Color color) async {
    state = state.copyWith(accentColor: color);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kAccent, color.value);
    } catch (_) {}
  }

  Future<void> setFontScale(double scale) async {
    state = state.copyWith(fontScale: scale);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kFontScale, scale);
    } catch (_) {}
  }
}