import 'package:flutter/material.dart';
import 'package:quotevault/theme/app_theme.dart';
import 'package:quotevault/shared/models/quote.dart';

class QuoteCard extends StatefulWidget {
  final Quote quote;

  final VoidCallback? onLike;
  final VoidCallback? onShare;

  /// ✅ New: Save to collection button
  final VoidCallback? onSaveToCollection;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.onLike,
    required this.onShare,
    required this.onSaveToCollection,
  });

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final liked = widget.quote.liked;

    final quoteStyle =
        context.quoteSerif.titleLarge?.copyWith(
          height: 1.45,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ) ??
        Theme.of(context).textTheme.titleLarge?.copyWith(
          height: 1.45,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        );

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.992 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.06,
                ),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
              if (liked)
                BoxShadow(
                  color: cs.primary.withOpacity(0.14),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('“${widget.quote.text}”', style: quoteStyle),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.quote.author,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface.withOpacity(0.74),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  _Tag(label: widget.quote.category),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _IconPill(
                    icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: liked ? cs.primary : cs.onSurface.withOpacity(0.68),
                    onTap: widget.onLike,
                  ),
                  const SizedBox(width: 10),
                  _IconPill(
                    icon: Icons.ios_share_rounded,
                    color: cs.onSurface.withOpacity(0.68),
                    onTap: widget.onShare,
                  ),
                  const SizedBox(width: 10),
                  _IconPill(
                    icon: Icons.bookmark_add_rounded,
                    color: cs.onSurface.withOpacity(0.68),
                    onTap: widget.onSaveToCollection,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary.withOpacity(0.18), cs.primary.withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary.withOpacity(0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}

class _IconPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _IconPill({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 42,
        width: 48,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}