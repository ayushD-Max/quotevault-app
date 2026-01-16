import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'qv_tokens.dart';
import 'qv_widgets.dart';

class QVText {
  static TextStyle quote(BuildContext context,
      {double size = 28, FontWeight weight = FontWeight.w600, FontStyle style = FontStyle.italic, double height = 1.15}) {
    return GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: weight,
      fontStyle: style,
      height: height,
      letterSpacing: -0.4,
      color: qvIsDark(context) ? QVColors.textDark : QVColors.textLight,
    );
  }
}