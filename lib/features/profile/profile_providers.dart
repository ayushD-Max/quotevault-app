import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quotevault/supabase/supabase_client_provider.dart';
import 'package:quotevault/features/auth/auth_session_notifier.dart';
import 'package:quotevault/shared/models/quote.dart';

final profileFullNameProvider = FutureProvider.autoDispose<String>((ref) async {
  final user = ref.watch(authUserProvider);
  if (user == null) return '';

  final client = ref.watch(supabaseClientProvider);
  final data = await client.from('profiles').select('full_name').eq('id', user.id).maybeSingle();
  return (data?['full_name'] as String?) ?? '';
});

final favoritesCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final user = ref.watch(authUserProvider);
  if (user == null) return 0;

  final client = ref.watch(supabaseClientProvider);
  final data = await client.from('favorites').select('quote_id').eq('user_id', user.id);
  return (data as List).length;
});

final collectionsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final user = ref.watch(authUserProvider);
  if (user == null) return 0;

  final client = ref.watch(supabaseClientProvider);
  final data = await client.from('collections').select('id').eq('user_id', user.id);
  return (data as List).length;
});

final userCollectionsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(authUserProvider);
  if (user == null) return [];

  final client = ref.watch(supabaseClientProvider);
  final data = await client
      .from('collections')
      .select('id, title, color_hex, created_at')
      .eq('user_id', user.id)
      .order('created_at', ascending: false);

  return (data as List).whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
});

final recentCollectionsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(authUserProvider);
  if (user == null) return [];

  final client = ref.watch(supabaseClientProvider);
  final data = await client
      .from('collections')
      .select('id, title, color_hex, created_at')
      .eq('user_id', user.id)
      .order('created_at', ascending: false)
      .limit(4);

  return (data as List).whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
});

final collectionQuotesProvider =
    FutureProvider.family.autoDispose<List<Quote>, int>((ref, collectionId) async {
  final client = ref.watch(supabaseClientProvider);

  final data = await client
      .from('collection_quotes')
      .select('quotes:quotes (id, quote_text, author, category)')
      .eq('collection_id', collectionId);

  final out = <Quote>[];
  for (final row in (data as List)) {
    if (row is Map) {
      final q = row['quotes'];
      if (q is Map) {
        final m = q.cast<String, dynamic>();
        out.add(
          Quote(
            id: (m['id'] as num).toInt(),
            text: (m['quote_text'] as String?) ?? '',
            author: (m['author'] as String?) ?? 'Unknown',
            category: (m['category'] as String?) ?? 'Motivation',
          ),
        );
      }
    }
  }
  return out;
});