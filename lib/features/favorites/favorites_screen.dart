import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quotevault/shared/ui/qv_widgets.dart';
import 'package:quotevault/shared/ui/qv_tokens.dart';
import 'package:quotevault/features/quotes/export_quote_screen.dart';
import 'package:quotevault/features/profile/add_to_collection_sheet.dart';
import 'package:quotevault/features/favorites/favorites_controller.dart';
import 'package:quotevault/features/favorites/favorites_providers.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  static const filters = ['All', 'Motivation', 'Wisdom', 'Love', 'Success', 'Humor'];
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final asyncFavs = ref.watch(favoriteQuotesProvider);

    return Scaffold(
      backgroundColor: qvBg(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Your ',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                    color: qvText(context),
                                  ),
                            ),
                            TextSpan(
                              text: 'Favorites',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                    color: QVColors.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    QVCircleIconButton(icon: Icons.search_rounded, onTap: () {}),
                    const SizedBox(width: 10),
                    QVCircleIconButton(icon: Icons.more_horiz_rounded, onTap: () {}),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 46,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final f = filters[i];
                  return QVPillChip(
                    label: f,
                    selected: selectedFilter == f,
                    onTap: () => setState(() => selectedFilter = f),
                  );
                },
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            sliver: asyncFavs.when(
              loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: QVColors.primary))),
              error: (e, _) => SliverToBoxAdapter(child: Text('Failed: $e')),
              data: (items) {
                if (items.isEmpty) {
                  return const SliverToBoxAdapter(child: Text('No favorites yet'));
                }

                final list = selectedFilter == 'All'
                    ? items
                    : items.where((q) => q.category == selectedFilter).toList();

                return SliverList.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final q = list[i];
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
                          Row(
                            children: [
                              Text(q.category.toUpperCase(),
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: QVColors.primary)),
                              const Spacer(),
                              InkWell(onTap: () => showSaveToCollectionSheet(context: context, quoteId: q.id), child: Icon(Icons.bookmark_add_rounded, color: qvText(context).withOpacity(0.45))),
                              const SizedBox(width: 12),
                              InkWell(onTap: () => ref.read(favoritesControllerProvider.notifier).toggle(q.id), child: const Icon(Icons.favorite_rounded, color: QVColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('"${q.text}"', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontStyle: FontStyle.italic, height: 1.35)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: Text(q.author, style: Theme.of(context).textTheme.bodyMedium)),
                              InkWell(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => ExportQuoteScreen(quoteId: q.id, quote: q.text, author: q.author)),
                                ),
                                child: Icon(Icons.ios_share_rounded, color: qvText(context).withOpacity(0.45)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}