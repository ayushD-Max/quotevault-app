import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/ui/qv_widgets.dart';
import '../shared/ui/qv_tokens.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  /// जर Settings हा BottomNav tab असेल => asTab: true करा
  /// जर route/push करून उघडत असशील => asTab: false (default)
  final bool asTab;
  const SettingsScreen({super.key, this.asTab = false});

  static const accents = <Color>[
    QVColors.primary,
    Color(0xFF4B0082), // indigo
    Color(0xFF008080), // teal
    Color(0xFFFFBF00), // amber
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);
    final ctrl = ref.read(settingsControllerProvider.notifier);

    final isDark = qvIsDark(context);
    final bg = isDark ? Colors.black : const Color(0xFFF2F2F7);

    final content = ColoredBox(
      color: bg, 
      child: CustomScrollView(
        slivers: [

          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: QVGlassHeader(
                left: TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    foregroundColor: QVColors.primary,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chevron_left_rounded, size: 28),
                      Text(
                        'Library',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: QVColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
                title: Text(
                  'Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: qvText(context),
                      ),
                ),
                right: TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    foregroundColor: QVColors.primary,
                  ),
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
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                _SectionHeader('APPEARANCE'),
                const SizedBox(height: 8),

                QVGroupedCard(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: _ThemeSegmented(
                        value: state.themeMode,
                        onChanged: ctrl.setThemeMode,
                      ),
                    ),
                    const QVDividerLine(),
                    _RowTile(
                      title: 'Accent Color',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: accents.map((c) {
                          final selected = c.value == state.accentColor.value;
                          return Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: () => ctrl.setAccentColor(c),
                              child: Container(
                                height: 22,
                                width: 22,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected ? c : (isDark ? Colors.white10 : Colors.black12),
                                    width: selected ? 2.0 : 1.0,
                                  ),
                                  boxShadow: selected ? QVShadows.glow(c) : const [],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Theme changes will apply to the app experience.',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: qvText(context).withOpacity(0.45),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),

                const SizedBox(height: 18),
                _SectionHeader('TYPOGRAPHY'),
                const SizedBox(height: 8),

                QVGroupedCard(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF7F7FA),
                      child: Center(
                        child: Text(
                          '“Design is intelligence made visible.”',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontStyle: FontStyle.italic,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                                fontSize: 16 * state.fontScale,
                              ),
                        ),
                      ),
                    ),
                    const QVDividerLine(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.text_decrease_rounded, color: qvText(context).withOpacity(0.35)),
                          Expanded(
                            child: Slider(
                              value: state.fontScale,
                              min: 0.9,
                              max: 1.25,
                              divisions: 7,
                              activeColor: QVColors.primary,
                              onChanged: ctrl.setFontScale,
                            ),
                          ),
                          Icon(Icons.text_increase_rounded, color: qvText(context).withOpacity(0.35), size: 28),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                _SectionHeader('STABILITY'),
                const SizedBox(height: 8),

                QVGroupedCard(
                  children: [
                    _RowTile(
                      title: 'Daily Quote',
                      trailing: Switch(
                        value: false,
                        onChanged: null, // intentionally disabled
                        activeColor: QVColors.primary,
                      ),
                    ),
                    const QVDividerLine(),
                    _RowTile(
                      title: 'Export Collection',
                      trailing: Icon(Icons.chevron_right_rounded, color: qvText(context).withOpacity(0.30)),
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 34,
                        width: 34,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [QVColors.primary, Color(0xFFFF6B6B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.30 : 0.10),
                              blurRadius: 14,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: const Icon(Icons.format_quote_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'QuoteVault',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Version 1.0.2',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: qvText(context).withOpacity(0.45),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );

    if (asTab) return content;

    return Scaffold(
      backgroundColor: bg,
      body: content,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: qvText(context).withOpacity(0.45),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
            ),
      ),
    );
  }
}

class _RowTile extends StatelessWidget {
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  const _RowTile({
    required this.title,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: qvText(context),
                    ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _ThemeSegmented extends StatelessWidget {
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSegmented({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);

    final bg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF0F0F5);
    final active = isDark ? const Color(0xFF636366) : Colors.white;

    Widget item(String label, ThemeMode mode) {
      final selected = value == mode;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onChanged(mode),
          child: Container(
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? active : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.25 : 0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ]
                  : const [],
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: selected ? qvText(context) : qvText(context).withOpacity(0.45),
                  ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          item('Auto', ThemeMode.system),
          item('Light', ThemeMode.light),
          item('Dark', ThemeMode.dark),
        ],
      ),
    );
  }
}