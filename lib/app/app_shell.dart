import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:quotevault/features/quotes/home_screen.dart';
import 'package:quotevault/features/quotes/search_screen.dart';
import 'package:quotevault/features/favorites/favorites_screen.dart';
import 'package:quotevault/features/profile/profile_screen.dart';

class AppShell extends ConsumerWidget {
  final VoidCallback onLogout;
  const AppShell({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final showNav = keyboardInset == 0;

    // ✅ set your index storage however you want; keeping local for now
    // If you already use a provider index, keep it; this is safe default:
    final index = ref.watch(_tabIndexProvider);

    final pages = <Widget>[
      const HomeScreen(),
      const SearchScreen(),
      const FavoritesScreen(),
      ProfileScreen(onLogout: onLogout),
    ];

    // ✅ Bottom nav visual height (actual container height) – tuned to prevent overflow
    final navVisualHeight = 64.0;

    final bodyBottomPadding = showNav ? (navVisualHeight + bottomInset + 14) : 0.0;

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bodyBottomPadding),
          child: IndexedStack(index: index, children: pages),
        ),
      ),
      bottomNavigationBar: showNav
          ? Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + bottomInset),
              child: _BottomNav(
                height: navVisualHeight,
                index: index,
                onChanged: (i) => ref.read(_tabIndexProvider.notifier).state = i,
              ),
            )
          : null,
    );
  }
}

final _tabIndexProvider = StateProvider<int>((ref) => 0);

class _BottomNav extends StatelessWidget {
  final double height;
  final int index;
  final ValueChanged<int> onChanged;

  const _BottomNav({
    required this.height,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.28 : 0.10),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: index == 0,
            onTap: () => onChanged(0),
          ),
          _NavItem(
            icon: Icons.search_rounded,
            label: 'Search',
            selected: index == 1,
            onTap: () => onChanged(1),
          ),
          _NavItem(
            icon: Icons.favorite_rounded,
            label: 'Favorites',
            selected: index == 2,
            onTap: () => onChanged(2),
          ),
          _NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            selected: index == 3,
            onTap: () => onChanged(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ✅ clamp label scaling for bottom nav only (prevents overflow when fontScale high)
    final safeScaler = MediaQuery.textScalerOf(context).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.0);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: selected ? cs.primary.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // ✅ prevents extra height pressure
            children: [
              Icon(icon, size: 20, color: selected ? cs.primary : cs.onSurface.withOpacity(0.55)),
              const SizedBox(height: 2),
              MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: safeScaler),
                child: FittedBox(
                  fit: BoxFit.scaleDown, // ✅ prevents bottom overflow
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: selected ? cs.primary : cs.onSurface.withOpacity(0.55),
                          fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}