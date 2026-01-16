import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _bgLight = Color(0xFFF8F6F6);
  static const _bgDark = Color(0xFF211111);

  static const _surfaceLight = Colors.white;
  static const _surfaceDark = Color(0xFF2A1A1A);

  static ThemeData build({
    required Color accent,
    required bool isDark,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    final bg = isDark ? _bgDark : _bgLight;
    final surface = isDark ? _surfaceDark : _surfaceLight;

    final cs = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: isDark ? Brightness.dark : Brightness.light,
      surface: surface,
    );

    final sans = GoogleFonts.publicSansTextTheme(base.textTheme);
    final serif = GoogleFonts.playfairDisplayTextTheme(base.textTheme);

    final textTheme = sans.copyWith(
      headlineLarge: sans.headlineLarge?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.6,
      ),
      headlineMedium: sans.headlineMedium?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.4,
      ),
      titleLarge: sans.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
      titleMedium: sans.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      labelLarge: sans.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      bodyMedium: sans.bodyMedium?.copyWith(height: 1.35),
      bodyLarge: sans.bodyLarge?.copyWith(height: 1.35),
    );

    return base.copyWith(
      colorScheme: cs,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      dividerColor: (isDark ? Colors.white : Colors.black).withOpacity(0.08),

      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: isDark ? Colors.white : const Color(0xFF1B0E0E),
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.35),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF4A3A3A) : const Color(0xFFE7D0D1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF4A3A3A) : const Color(0xFFE7D0D1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: accent, width: 1.4),
        ),
      ),

      extensions: <ThemeExtension<dynamic>>[
        QuoteTypography(quoteSerif: serif),
      ],
    );
  }
}

class QuoteTypography extends ThemeExtension<QuoteTypography> {
  final TextTheme quoteSerif;
  const QuoteTypography({required this.quoteSerif});

  @override
  QuoteTypography copyWith({TextTheme? quoteSerif}) {
    return QuoteTypography(quoteSerif: quoteSerif ?? this.quoteSerif);
  }

  @override
  QuoteTypography lerp(ThemeExtension<QuoteTypography>? other, double t) {
    if (other is! QuoteTypography) return this;
    return QuoteTypography(quoteSerif: TextTheme.lerp(quoteSerif, other.quoteSerif, t)!);
  }
}

extension QuoteTypographyX on BuildContext {
  TextTheme get quoteSerif {
    final ext = Theme.of(this).extension<QuoteTypography>();
    // Defensive fallback: never crash
    return ext?.quoteSerif ?? GoogleFonts.playfairDisplayTextTheme(Theme.of(this).textTheme);
  }
}