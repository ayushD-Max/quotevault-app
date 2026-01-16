import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/ui/qv_widgets.dart';
import '../../shared/ui/qv_tokens.dart';
import '../favorites/favorites_controller.dart';
import 'quotes_providers.dart';
import 'export_quote_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _c = TextEditingController();
  String chip = 'All';
  final chips = const ['All', 'Authors', 'Categories', 'Trending', 'Historical'];

  @override
  void initState() {
    super.initState();
    _c.addListener(() => ref.read(searchQueryProvider.notifier).state = _c.text);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider(query));

    return Scaffold(
      backgroundColor: qvBg(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Text(
                  'Search',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        color: qvText(context),
                      ),
                ),
              ),
            ),
          ),

          // Search bar (rounded)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: qvSurface(context),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: (qvIsDark(context) ? Colors.white : Colors.black).withOpacity(0.10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(qvIsDark(context) ? 0.18 : 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _c,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search for inspiration...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    prefixIcon: Icon(Icons.search_rounded, color: qvText(context).withOpacity(0.40)),
                    suffixIcon: query.trim().isEmpty
                        ? null
                        : IconButton(
                            onPressed: () => _c.clear(),
                            icon: const Icon(Icons.cancel_rounded),
                          ),
                  ),
                ),
              ),
            ),
          ),

          // chips (UI)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 46,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final c = chips[i];
                  return QVPillChip(
                    label: c,
                    selected: chip == c,
                    onTap: () => setState(() => chip = c),
                  );
                },
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            sliver: resultsAsync.when(
              loading: () => SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator(color: QVColors.primary)),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Text('Search failed: $e', style: TextStyle(color: qvText(context))),
              ),
              data: (items) {
                if (query.trim().isEmpty) {
                  return SliverToBoxAdapter(
                    child: Text(
                      'Type something to search quotes.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: qvText(context).withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  );
                }
                if (items.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Text(
                      'No results found.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: qvText(context).withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  );
                }

                return SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final q = items[i];
                    return _SearchResultCard(
                      quote: q.text,
                      author: q.author,
                      meta: q.category,
                      liked: q.liked,
                      onLike: () => ref.read(favoritesControllerProvider.notifier).toggle(q.id),
                      onShare: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ExportQuoteScreen(quote: q.text, author: q.author)),
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

class _SearchResultCard extends StatelessWidget {
  final String quote;
  final String author;
  final String meta;
  final bool liked;
  final VoidCallback onLike;
  final VoidCallback onShare;

  const _SearchResultCard({
    required this.quote,
    required this.author,
    required this.meta,
    required this.liked,
    required this.onLike,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);

    return Container(
      decoration: BoxDecoration(
        color: qvSurface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.16 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 12),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '"$quote"',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                      color: qvText(context),
                    ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      author,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: qvText(context),
                          ),
                    ),
                  ),
                  Text(
                    meta,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: qvText(context).withOpacity(0.45),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onShare,
                    icon: Icon(Icons.ios_share_rounded, size: 16, color: qvText(context).withOpacity(0.45)),
                    label: Text(
                      'Share',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: qvText(context).withOpacity(0.55),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              )
            ]),
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onLike,
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: liked ? QVColors.primary.withOpacity(0.12) : (isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: liked ? QVColors.primary : qvText(context).withOpacity(0.35),
              ),
            ),
          )
        ],
      ),
    );
  }
}