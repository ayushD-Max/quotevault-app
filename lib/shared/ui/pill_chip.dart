import 'package:flutter/material.dart';

class PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const PillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      scale: selected ? 1.05 : 1.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 16 : 14,
            vertical: selected ? 11 : 10,
          ),
          decoration: BoxDecoration(
            color: selected ? cs.primary.withOpacity(0.16) : cs.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? cs.primary.withOpacity(0.35) : Theme.of(context).dividerColor,
              width: selected ? 1.2 : 1.0,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    )
                  ]
                : const [],
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? cs.primary : cs.onSurface.withOpacity(0.78),
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}