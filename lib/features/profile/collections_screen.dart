import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quotevault/features/auth/auth_session_notifier.dart';
import 'package:quotevault/shared/ui/qv_widgets.dart';
import 'package:quotevault/shared/ui/qv_tokens.dart';
import 'package:quotevault/supabase/supabase_client_provider.dart';
import 'collection_detail_screen.dart';
import 'profile_providers.dart';

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  final _search = TextEditingController();
  bool _editMode = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _createCollection() async {
    final user = ref.read(authUserProvider);
    if (user == null) return;

    final title = await showDialog<String>(
      context: context,
      builder: (_) => const _CreateCollectionDialog(),
    );
    if (title == null || title.trim().isEmpty) return;

    final client = ref.read(supabaseClientProvider);
    await client.from('collections').insert({
      'user_id': user.id,
      'title': title.trim(),
      'color_hex': 'EA2A33',
    });

    ref.invalidate(userCollectionsProvider);
    ref.invalidate(recentCollectionsProvider);
    ref.invalidate(collectionsCountProvider);
  }

  Future<void> _deleteCollection(int id, String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete collection?'),
        content: Text('Delete "$title"? This will remove its saved quotes list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (ok != true) return;

    final client = ref.read(supabaseClientProvider);
    await client.from('collections').delete().eq('id', id);

    ref.invalidate(userCollectionsProvider);
    ref.invalidate(recentCollectionsProvider);
    ref.invalidate(collectionsCountProvider);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(userCollectionsProvider);
    final countAsync = ref.watch(collectionsCountProvider);

    return Scaffold(
      backgroundColor: qvBg(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: QVGlassHeader(
                left: QVCircleIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                title: Text(
                  'My Collections',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: qvText(context),
                      ),
                ),
                right: TextButton(
                  onPressed: () => setState(() => _editMode = !_editMode),
                  child: Text(
                    _editMode ? 'Done' : 'Edit',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: QVColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: qvSurface(context),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: (qvIsDark(context) ? Colors.white : Colors.black).withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search_rounded, color: QVColors.primary.withOpacity(0.70)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search collections...',
                          hintStyle: TextStyle(color: qvText(context).withOpacity(0.35)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 92,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _MiniStat(
                    title: 'Total',
                    value: countAsync.value?.toString() ?? '—',
                    accent: false,
                  ),
                  const SizedBox(width: 12),
                  const _MiniStat(title: 'Favorites', value: '—', accent: true),
                  const SizedBox(width: 12),
                  const _MiniStat(title: 'New', value: '—', accent: false),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
            sliver: async.when(
              loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: QVColors.primary))),
              error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
              data: (items) {
                final q = _search.text.trim().toLowerCase();
                final filtered = q.isEmpty
                    ? items
                    : items.where((c) => ((c['title'] as String?) ?? '').toLowerCase().contains(q)).toList();

                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        return _CreateNewCard(onTap: _createCollection);
                      }

                      final c = filtered[index - 1];
                      final id = (c['id'] as num).toInt();
                      final title = (c['title'] as String?) ?? 'Collection';

                      return _CollectionCard(
                        title: title,
                        editMode: _editMode,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CollectionDetailScreen(collectionId: id, title: title),
                            ),
                          );
                        },
                        onDelete: () => _deleteCollection(id, title),
                      );
                    },
                    childCount: 1 + filtered.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 4 / 5,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: QVColors.primary,
        foregroundColor: Colors.white,
        onPressed: _createCollection,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;
  final bool accent;

  const _MiniStat({required this.title, required this.value, required this.accent});

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: qvSurface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: qvText(context).withOpacity(0.45),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  )),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: accent ? QVColors.primary : qvText(context),
                ),
          ),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final String title;
  final bool editMode;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CollectionCard({
    required this.title,
    required this.editMode,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              QVColors.primary.withOpacity(0.18),
              QVColors.primary.withOpacity(0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: QVColors.primary.withOpacity(0.14)),
        ),
        padding: const EdgeInsets.all(14),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.collections_bookmark_rounded, color: QVColors.primary),
                const Spacer(),
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text('Tap to open', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: qvText(context).withOpacity(0.6))),
              ],
            ),
            if (editMode)
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onDelete,
                  child: Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CreateNewCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateNewCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: QVDashedBorder(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: QVColors.primary.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_rounded, color: QVColors.primary, size: 26),
                ),
                const SizedBox(height: 10),
                Text(
                  'Create New',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: QVColors.primary,
                        fontWeight: FontWeight.w900,
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

class _CreateCollectionDialog extends StatefulWidget {
  const _CreateCollectionDialog();

  @override
  State<_CreateCollectionDialog> createState() => _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends State<_CreateCollectionDialog> {
  final c = TextEditingController();

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Collection'),
      content: TextField(controller: c, decoration: const InputDecoration(hintText: 'Collection name')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Create')),
      ],
    );
  }
}