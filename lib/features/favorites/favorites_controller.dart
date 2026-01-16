import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quotevault/supabase/supabase_client_provider.dart';
import 'package:quotevault/features/auth/auth_session_notifier.dart';

final favoritesControllerProvider =
    AsyncNotifierProvider<FavoritesController, Set<int>>(FavoritesController.new);

class FavoritesController extends AsyncNotifier<Set<int>> {
  late final SupabaseClient _client;

  @override
  Future<Set<int>> build() async {
    _client = ref.watch(supabaseClientProvider);
    final user = ref.watch(authUserProvider);
    if (user == null) return <int>{};
    return _fetch(user.id);
  }

  Future<Set<int>> _fetch(String userId) async {
    final data = await _client.from('favorites').select('quote_id').eq('user_id', userId);
    final ids = <int>{};
    for (final row in (data as List)) {
      if (row is Map) {
        final qid = row['quote_id'];
        if (qid is num) ids.add(qid.toInt());
      }
    }
    return ids;
  }

  /// ✅ No AsyncLoading -> no UI reload spinner flicker
  Future<void> toggle(int quoteId) async {
    final user = ref.read(authUserProvider);
    if (user == null) return;

    final current = state.value ?? <int>{};
    final isFav = current.contains(quoteId);

    final next = {...current};
    if (isFav) {
      next.remove(quoteId);
    } else {
      next.add(quoteId);
    }
    state = AsyncData(next);

    try {
      if (isFav) {
        await _client.from('favorites').delete().eq('user_id', user.id).eq('quote_id', quoteId);
      } else {
        await _client.from('favorites').insert({'user_id': user.id, 'quote_id': quoteId});
      }
    } catch (_) {
      state = AsyncData(current); // revert
    }
  }

  Future<void> refresh() async {
    final user = ref.read(authUserProvider);
    if (user == null) {
      state = const AsyncData(<int>{});
      return;
    }
    state = AsyncData(await _fetch(user.id));
  }
}