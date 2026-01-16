import 'package:flutter/material.dart';

class QVColors {
  static const primary = Color(0xFFEA2A33);

  static const bgLight = Color(0xFFF8F6F6);
  static const bgDark = Color(0xFF211111);

  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF2A1A1A);
  static const surfaceDark2 = Color(0xFF2C1B1B);

  static const textLight = Color(0xFF1B0E0E);
  static const textDark = Color(0xFFF2F0F0);

  static const borderLight = Color(0xFFE7D0D1);
  static const borderDark = Color(0xFF4A3A3A);

  static const separatorLight = Color(0xFFE5E5EA);
  static const separatorDark = Color(0xFF38383A);
}

class QVShadows {
  static List<BoxShadow> soft({required bool isDark}) => [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.45 : 0.08),
          blurRadius: 28,
          offset: const Offset(0, 18),
        ),
      ];

  static List<BoxShadow> glow(Color c) => [
        BoxShadow(
          color: c.withOpacity(0.28),
          blurRadius: 22,
          offset: const Offset(0, 14),
        )
      ];
}