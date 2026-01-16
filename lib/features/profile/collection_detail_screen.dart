import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quotevault/shared/ui/qv_widgets.dart';
import 'package:quotevault/shared/ui/qv_tokens.dart';
import 'package:quotevault/features/favorites/favorites_controller.dart';
import 'package:quotevault/features/quotes/export_quote_screen.dart';
import 'package:quotevault/features/profile/add_to_collection_sheet.dart';
import 'profile_providers.dart';

class CollectionDetailScreen extends ConsumerWidget {
  final int collectionId;
  final String title;

  const CollectionDetailScreen({
    super.key,
    required this.collectionId,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favoritesControllerProvider).value ?? <int>{};
    final async = ref.watch(collectionQuotesProvider(collectionId));

    return Scaffold(
      backgroundColor: qvBg(context),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: QVColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(
                'No quotes in this collection yet.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          final list = items.map((q) => q.copyWith(liked: favIds.contains(q.id))).toList();

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final q = list[i];
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: qvSurface(context),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: (qvIsDark(context) ? Colors.white : Colors.black).withOpacity(0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('“${q.text}”', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Text(q.author, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => ref.read(favoritesControllerProvider.notifier).toggle(q.id),
                          child: Icon(
                            q.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: q.liked ? QVColors.primary : qvText(context).withOpacity(0.45),
                          ),
                        ),
                        const SizedBox(width: 14),
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExportQuoteScreen(
                                quoteId: q.id,
                                quote: q.text,
                                author: q.author,
                              ),
                            ),
                          ),
                          child: Icon(Icons.ios_share_rounded, color: qvText(context).withOpacity(0.45)),
                        ),
                        const SizedBox(width: 14),
                        InkWell(
                          onTap: () => showSaveToCollectionSheet(context: context, quoteId: q.id),
                          child: Icon(Icons.bookmark_add_rounded, color: qvText(context).withOpacity(0.45)),
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
    );
  }
}