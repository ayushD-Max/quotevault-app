import 'dart:ui';
import 'package:flutter/material.dart';
import 'qv_tokens.dart';

bool qvIsDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

Color qvBg(BuildContext context) => qvIsDark(context) ? QVColors.bgDark : QVColors.bgLight;
Color qvSurface(BuildContext context) => qvIsDark(context) ? QVColors.surfaceDark : QVColors.surfaceLight;
Color qvText(BuildContext context) => qvIsDark(context) ? QVColors.textDark : QVColors.textLight;

class QVConstrained extends StatelessWidget {
  final Widget child;
  const QVConstrained({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: child,
      ),
    );
  }
}

class QVGlassHeader extends StatelessWidget implements PreferredSizeWidget {
  final Widget left;
  final Widget title;
  final Widget right;

  const QVGlassHeader({
    super.key,
    required this.left,
    required this.title,
    required this.right,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: preferredSize.height,
          decoration: BoxDecoration(
            color: qvBg(context).withOpacity(isDark ? 0.85 : 0.88),
            border: Border(bottom: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.06))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(alignment: Alignment.centerLeft, child: left),
              DefaultTextStyle.merge(style: TextStyle(color: qvText(context)), child: title),
              Align(alignment: Alignment.centerRight, child: right),
            ],
          ),
        ),
      ),
    );
  }
}

class QVCircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  const QVCircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: filled
              ? QVColors.primary.withOpacity(0.12)
              : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04)),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: filled ? QVColors.primary : qvText(context).withOpacity(0.9)),
      ),
    );
  }
}

class QVPrimaryButton extends StatefulWidget {
  final String label;
  final IconData? trailing;
  final VoidCallback? onPressed;

  const QVPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailing,
  });

  @override
  State<QVPrimaryButton> createState() => _QVPrimaryButtonState();
}

class _QVPrimaryButtonState extends State<QVPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);

    return GestureDetector(
      onTapDown: widget.onPressed == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: widget.onPressed == null ? null : () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.985 : 1.0,
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: QVColors.primary,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: QVColors.primary.withOpacity(isDark ? 0.30 : 0.22),
                blurRadius: 20,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: 10),
                  Icon(widget.trailing, size: 20, color: Colors.white),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QVTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscure;
  final IconData? leading;
  final Widget? trailing;
  final bool roundedFull;

  const QVTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.leading,
    this.trailing,
    this.roundedFull = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);

    return Container(
      decoration: BoxDecoration(
        color: qvSurface(context),
        borderRadius: BorderRadius.circular(roundedFull ? 999 : 14),
        border: Border.all(color: isDark ? QVColors.borderDark : QVColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.10 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: TextStyle(color: qvText(context)),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: qvText(context).withOpacity(0.35), fontWeight: FontWeight.w500),
          contentPadding: EdgeInsets.symmetric(
            horizontal: leading == null ? 18 : 52,
            vertical: 18,
          ),
          prefixIcon: leading == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(left: 18, right: 10),
                  child: Icon(leading, color: qvText(context).withOpacity(0.40)),
                ),
          prefixIconConstraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          suffixIcon: trailing,
        ),
      ),
    );
  }
}

class QVPillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const QVPillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);

    final bg = selected ? (isDark ? Colors.white : QVColors.textLight) : qvSurface(context);
    final fg = selected
        ? (isDark ? QVColors.textLight : Colors.white)
        : qvText(context).withOpacity(isDark ? 0.85 : 0.60);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : (isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.05)),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.25 : 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  )
                ]
              : const [],
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: fg,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class QVGroupedCard extends StatelessWidget {
  final List<Widget> children;
  const QVGroupedCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);
    final card = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final ring = (isDark ? Colors.white : Colors.black).withOpacity(isDark ? 0.10 : 0.05);

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 22,
            offset: const Offset(0, 14),
          )
        ],
        border: Border.all(color: ring),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }
}

class QVDividerLine extends StatelessWidget {
  const QVDividerLine({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);
    return Container(
      height: 1,
      color: (isDark ? QVColors.separatorDark : QVColors.separatorLight).withOpacity(0.9),
    );
  }
}

/// Simple dashed border (no plugin)
class QVDashedBorder extends StatelessWidget {
  final BorderRadius borderRadius;
  final Widget child;
  final Color color;

  const QVDashedBorder({
    super.key,
    required this.child,
    required this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(color: color, radius: borderRadius.topLeft.x),
      child: ClipRRect(borderRadius: borderRadius, child: child),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedRRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    const dashWidth = 8.0;
    const dashSpace = 6.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final len = (distance + dashWidth < metric.length) ? dashWidth : (metric.length - distance);
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}