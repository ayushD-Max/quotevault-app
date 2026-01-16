import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quotevault/shared/ui/qv_widgets.dart';
import 'package:quotevault/shared/ui/qv_tokens.dart';

enum ExportStyle { minimal, gradient, pattern }

class ExportQuoteScreen extends StatefulWidget {
  final int? quoteId; // ✅
  final String quote;
  final String author;

  const ExportQuoteScreen({
    super.key,
    this.quoteId,
    required this.quote,
    required this.author,
  });

  @override
  State<ExportQuoteScreen> createState() => _ExportQuoteScreenState();
}

class _ExportQuoteScreenState extends State<ExportQuoteScreen> {
  ExportStyle style = ExportStyle.gradient;

  String get _shareText => '“${widget.quote}” — ${widget.author}';

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _shareText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _sharePlaceholder() {
    // ✅ plugin-free safe placeholder
    // Later: add share_plus and call Share.share(_shareText)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share sheet: add share_plus later (text-only).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);

    return Scaffold(
      backgroundColor: qvBg(context),
      body: Stack(
        children: [
          QVConstrained(
            child: CustomScrollView(
              slivers: [
                // ✅ FIX: SafeArea wrapped header (no “too high” issue)
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: QVGlassHeader(
                      left: QVCircleIconButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      title: Text(
                        'Export Quote',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: qvText(context),
                            ),
                      ),
                      right: TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: Text(
                          'Done',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: QVColors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 160),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed([
                      _PreviewCard(
                        quote: widget.quote,
                        author: widget.author,
                        style: style,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Text(
                            'Style',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: qvText(context),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StyleTile(
                              labelTop: 'Minimal',
                              labelBottom: 'Solid',
                              selected: style == ExportStyle.minimal,
                              onTap: () => setState(() => style = ExportStyle.minimal),
                              child: const _StyleSwatch(style: ExportStyle.minimal),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StyleTile(
                              labelTop: 'Gradient',
                              labelBottom: 'Soft',
                              selected: style == ExportStyle.gradient,
                              onTap: () => setState(() => style = ExportStyle.gradient),
                              child: const _StyleSwatch(style: ExportStyle.gradient),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StyleTile(
                              labelTop: 'Pattern',
                              labelBottom: 'Texture',
                              selected: style == ExportStyle.pattern,
                              onTap: () => setState(() => style = ExportStyle.pattern),
                              child: const _StyleSwatch(style: ExportStyle.pattern),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sharing is text-only for stability (no image saving).',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: qvText(context).withOpacity(0.55),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // Sticky bottom actions
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomActions(
              isDark: isDark,
              onShare: _sharePlaceholder,
              onCopy: _copy,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final bool isDark;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  const _BottomActions({
    required this.isDark,
    required this.onShare,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 14 + bottomInset),
          decoration: BoxDecoration(
            color: qvBg(context).withOpacity(isDark ? 0.82 : 0.86),
            border: Border(top: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.06))),
          ),
          child: QVConstrained(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QVPrimaryButton(
                  label: 'Share to Socials',
                  trailing: Icons.ios_share_rounded,
                  onPressed: onShare,
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    side: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: onCopy,
                  icon: Icon(Icons.content_copy_rounded, color: qvText(context).withOpacity(0.65)),
                  label: Text(
                    'Copy Text',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: qvText(context).withOpacity(0.75),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String quote;
  final String author;
  final ExportStyle style;

  const _PreviewCard({
    required this.quote,
    required this.author,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);

    Decoration bg() {
      switch (style) {
        case ExportStyle.minimal:
          return BoxDecoration(color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F6F6));
        case ExportStyle.gradient:
          return BoxDecoration(
            gradient: LinearGradient(
              colors: isDark ? [const Color(0xFF2C3E50), const Color(0xFF000000)] : [const Color(0xFFFDFBFB), const Color(0xFFE6E9F0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          );
        case ExportStyle.pattern:
          return BoxDecoration(color: isDark ? const Color(0xFF252525) : const Color(0xFFF4F4F4));
      }
    }

    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.55 : 0.12),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned.fill(child: DecoratedBox(decoration: bg())),
              if (style == ExportStyle.pattern)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GridPatternPainter(color: (isDark ? Colors.white : Colors.black).withOpacity(0.06)),
                  ),
                ),
              Positioned(
                top: 18,
                right: 18,
                child: Icon(
                  Icons.format_quote_rounded,
                  size: 90,
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Icon(Icons.format_quote_rounded, color: QVColors.primary, size: 34),
                    const Spacer(),
                    Text(
                      quote,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.18,
                            letterSpacing: -0.3,
                            color: qvText(context),
                          ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      height: 2,
                      width: 34,
                      decoration: BoxDecoration(
                        color: QVColors.primary.withOpacity(0.60),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      author.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 2.4,
                            fontWeight: FontWeight.w900,
                            color: qvText(context).withOpacity(0.55),
                          ),
                    ),
                    const Spacer(),
                    Opacity(
                      opacity: 0.30,
                      child: Text(
                        'QuoteVault'.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w900,
                              color: qvText(context),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  final Color color;
  _GridPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;

    const step = 20.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPatternPainter oldDelegate) => oldDelegate.color != color;
}

class _StyleTile extends StatelessWidget {
  final String labelTop;
  final String labelBottom;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const _StyleTile({
    required this.labelTop,
    required this.labelBottom,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Stack(
        children: [
          if (selected)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: QVColors.primary,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(3),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: qvSurface(context),
                      border: Border.all(color: (qvIsDark(context) ? Colors.white : Colors.black).withOpacity(0.08)),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(child: Padding(padding: const EdgeInsets.all(10), child: child)),
                        if (selected)
                          Center(
                            child: Container(
                              height: 28,
                              width: 28,
                              decoration: const BoxDecoration(color: QVColors.primary, shape: BoxShape.circle),
                              child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  labelTop,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: selected ? QVColors.primary : qvText(context),
                      ),
                ),
                Text(
                  labelBottom,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected ? QVColors.primary.withOpacity(0.7) : qvText(context).withOpacity(0.45),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleSwatch extends StatelessWidget {
  final ExportStyle style;
  const _StyleSwatch({required this.style});

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);

    switch (style) {
      case ExportStyle.minimal:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F6F6),
          ),
        );
      case ExportStyle.gradient:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: isDark ? [const Color(0xFF2C3E50), const Color(0xFF000000)] : [const Color(0xFFFDFBFB), const Color(0xFFE6E9F0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      case ExportStyle.pattern:
        return CustomPaint(
          painter: _GridPatternPainter(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08)),
          child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(14))),
        );
    }
  }
}