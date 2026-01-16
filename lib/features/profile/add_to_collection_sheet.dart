import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quotevault/shared/ui/qv_widgets.dart';
import 'package:quotevault/shared/ui/qv_tokens.dart';

Future<void> showSaveToCollectionSheet({
  required BuildContext context,
  required int quoteId,
}) async {
  await showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SaveToCollectionSheet(quoteId: quoteId),
  );
}

class _SaveToCollectionSheet extends StatefulWidget {
  final int quoteId;
  const _SaveToCollectionSheet({required this.quoteId});

  @override
  State<_SaveToCollectionSheet> createState() => _SaveToCollectionSheetState();
}

class _SaveToCollectionSheetState extends State<_SaveToCollectionSheet> {
  final _client = Supabase.instance.client;
  bool _busy = false;
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadCollections();
  }

  Future<List<Map<String, dynamic>>> _loadCollections() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final data = await _client
        .from('collections')
        .select('id, title, created_at')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return (data as List).whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
  }

  Future<void> _createNew() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final title = await showDialog<String>(
      context: context,
      builder: (_) => const _CreateCollectionDialog(),
    );
    if (title == null || title.trim().isEmpty) return;

    setState(() => _busy = true);
    try {
      final created = await _client
          .from('collections')
          .insert({'user_id': user.id, 'title': title.trim(), 'color_hex': 'EA2A33'})
          .select('id, title')
          .single();

      final cid = (created['id'] as num).toInt();

      await _client.from('collection_quotes').upsert(
        {'collection_id': cid, 'quote_id': widget.quoteId},
        onConflict: 'collection_id,quote_id',
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to new collection')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveTo(int collectionId, String title) async {
    setState(() => _busy = true);
    try {
      await _client.from('collection_quotes').upsert(
        {'collection_id': collectionId, 'quote_id': widget.quoteId},
        onConflict: 'collection_id,quote_id',
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to "$title"')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: qvSurface(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 5, width: 48, decoration: BoxDecoration(color: qvText(context).withOpacity(0.15), borderRadius: BorderRadius.circular(999))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Save to collection',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: qvText(context),
                        ),
                  ),
                ),
                if (_busy)
                  const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: QVColors.primary)),
              ],
            ),
            const SizedBox(height: 12),

            QVPrimaryButton(
              label: 'Create new collection',
              trailing: Icons.add_rounded,
              onPressed: _busy ? null : _createNew,
            ),

            const SizedBox(height: 12),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: QVColors.primary),
                  );
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'No collections yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: qvText(context).withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final c = items[i];
                    final id = (c['id'] as num).toInt();
                    final title = (c['title'] as String?) ?? 'Collection';

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _busy ? null : () => _saveTo(id, title),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.06)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                color: QVColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.collections_bookmark_rounded, color: QVColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: qvText(context),
                                    ),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: qvText(context).withOpacity(0.35)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
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