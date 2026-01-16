import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quotevault/shared/models/quote.dart';
import 'package:quotevault/shared/ui/qv_widgets.dart';
import 'package:quotevault/shared/ui/qv_tokens.dart';
import 'package:quotevault/features/favorites/favorites_controller.dart';
import 'package:quotevault/features/quotes/quotes_providers.dart';
import 'package:quotevault/features/quotes/export_quote_screen.dart';
import 'package:quotevault/features/profile/add_to_collection_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const categories = ['All', 'Motivation', 'Wisdom', 'Love', 'Success', 'Humor'];

  Future<void> _refresh() async {
    ref.invalidate(homeQuotesProvider);
    await ref.read(homeQuotesProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(homeCategoryProvider);
    final asyncQuotes = ref.watch(homeQuotesProvider);
    final favIds = ref.watch(favoritesControllerProvider).value ?? <int>{};

    return Scaffold(
      backgroundColor: qvBg(context),
      body: RefreshIndicator(
        color: QVColors.primary,
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _dateLine().toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: qvText(context).withOpacity(0.35),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Discover',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.4,
                                    color: qvText(context),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      _AvatarButton(onTap: () {}),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                child: asyncQuotes.when(
                  loading: () => _HeroSkeleton(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (items) {
                    if (items.isEmpty) return const SizedBox.shrink();
                    final hero = items.first.copyWith(liked: favIds.contains(items.first.id));

                    return _QuoteOfDayHero(
                      quote: hero,
                      onShare: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ExportQuoteScreen(
                              quoteId: hero.id,
                              quote: hero.text,
                              author: hero.author,
                            ),
                          ),
                        );
                      },
                      onSave: () => showSaveToCollectionSheet(context: context, quoteId: hero.id),
                      onLike: () => ref.read(favoritesControllerProvider.notifier).toggle(hero.id),
                    );
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 54,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final c = categories[i];
                    return QVPillChip(
                      label: c,
                      selected: selected == c,
                      onTap: () => ref.read(homeCategoryProvider.notifier).state = c,
                    );
                  },
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: asyncQuotes.when(
                loading: () => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Center(child: CircularProgressIndicator(color: QVColors.primary)),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: _MessageCard(
                    title: 'Could not load quotes',
                    subtitle: e.toString(),
                    actionLabel: 'Retry',
                    onAction: () => ref.invalidate(homeQuotesProvider),
                  ),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: _MessageCard(title: 'No quotes found', subtitle: 'Try a different category.'),
                    );
                  }

                  final list = items.length > 1 ? items.sublist(1) : <Quote>[];

                  return SliverList.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final base = list[index];
                      final q = base.copyWith(liked: favIds.contains(base.id));

                      return _StitchQuoteCard(
                        quote: q,
                        onLike: () => ref.read(favoritesControllerProvider.notifier).toggle(q.id),
                        onShare: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ExportQuoteScreen(
                                quoteId: q.id,
                                quote: q.text,
                                author: q.author,
                              ),
                            ),
                          );
                        },
                        onSave: () => showSaveToCollectionSheet(context: context, quoteId: q.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dateLine() {
    final now = DateTime.now();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final wd = weekdays[(now.weekday - 1).clamp(0, 6)];
    final m = months[(now.month - 1).clamp(0, 11)];
    return '$wd, $m ${now.day}';
  }
}

class _AvatarButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AvatarButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(isDark ? 0.06 : 0.9),
          border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: const Center(child: Icon(Icons.person_rounded, size: 22)),
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: qvSurface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: (qvIsDark(context) ? Colors.white : Colors.black).withOpacity(0.06)),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _QuoteOfDayHero extends StatelessWidget {
  final Quote quote;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onLike;

  const _QuoteOfDayHero({
    required this.quote,
    required this.onShare,
    required this.onSave,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);

    return Container(
      decoration: BoxDecoration(
        color: qvSurface(context),
        borderRadius: BorderRadius.circular(18),
        boxShadow: QVShadows.soft(isDark: isDark),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.18 : 0.55,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [QVColors.primary.withOpacity(0.10), Colors.transparent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withOpacity(isDark ? 0.20 : 0.65),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.auto_awesome_rounded, size: 18, color: QVColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'QUOTE OF THE DAY',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                              color: qvText(context).withOpacity(0.85),
                            ),
                      ),
                    ]),
                  ),
                  const Spacer(),
                  InkWell(onTap: onSave, child: Icon(Icons.bookmark_add_rounded, color: qvText(context).withOpacity(0.45))),
                ]),
                const SizedBox(height: 16),
                Text(
                  quote.text,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        height: 1.18,
                        letterSpacing: -0.35,
                        color: qvText(context),
                      ),
                ),
                const SizedBox(height: 14),
                Text(quote.author, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: onLike,
                      child: Icon(
                        quote.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: quote.liked ? QVColors.primary : qvText(context).withOpacity(0.45),
                      ),
                    ),
                    const SizedBox(width: 14),
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: onShare,
                      child: Icon(Icons.ios_share_rounded, color: qvText(context).withOpacity(0.45)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StitchQuoteCard extends StatelessWidget {
  final Quote quote;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const _StitchQuoteCard({
    required this.quote,
    required this.onLike,
    required this.onShare,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);

    return Container(
      decoration: BoxDecoration(
        color: qvSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 10),
          )
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.format_quote_rounded, size: 16, color: QVColors.primary),
            const SizedBox(width: 8),
            Text(
              quote.category.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: qvText(context).withOpacity(0.35),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
            ),
            const Spacer(),
            InkWell(onTap: onSave, child: Icon(Icons.bookmark_add_rounded, color: qvText(context).withOpacity(0.45))),
          ]),
          const SizedBox(height: 12),
          Text(
            quote.text,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: qvText(context),
                ),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: qvText(context).withOpacity(0.08)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  quote.author,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: qvText(context).withOpacity(0.55),
                      ),
                ),
              ),
              InkWell(onTap: onLike, child: Icon(quote.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: quote.liked ? QVColors.primary : qvText(context).withOpacity(0.35))),
              const SizedBox(width: 14),
              InkWell(onTap: onShare, child: Icon(Icons.ios_share_rounded, color: qvText(context).withOpacity(0.35))),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageCard({required this.title, required this.subtitle, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: qvSurface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: (qvIsDark(context) ? Colors.white : Colors.black).withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: qvText(context).withOpacity(0.65), fontWeight: FontWeight.w600)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            QVPrimaryButton(label: actionLabel!, onPressed: onAction, trailing: Icons.refresh_rounded),
          ],
        ],
      ),
    );
  }
}