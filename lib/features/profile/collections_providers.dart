import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quotevault/supabase/supabase_client_provider.dart';
import 'package:quotevault/features/auth/auth_session_notifier.dart';
import 'collections_service.dart';

final collectionsServiceProvider = Provider<CollectionsService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CollectionsService(client);
});

final collectionsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final user = ref.watch(authUserProvider);
  if (user == null) return 0;

  final client = ref.watch(supabaseClientProvider);
  final data = await client
      .from('collections')
      .select('id')
      .eq('user_id', user.id);

  return (data as List).length;
});

final userCollectionsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(authUserProvider);
  if (user == null) return [];

  final client = ref.watch(supabaseClientProvider);
  final data = await client
      .from('collections')
      .select('id, title, color_hex, created_at')
      .eq('user_id', user.id)
      .order('created_at', ascending: false);

  return (data as List)
      .whereType<Map>()
      .map((e) => e.cast<String, dynamic>())
      .toList();
});

final recentCollectionsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(authUserProvider);
  if (user == null) return [];

  final client = ref.watch(supabaseClientProvider);
  final data = await client
      .from('collections')
      .select('id, title, color_hex, created_at')
      .eq('user_id', user.id)
      .order('created_at', ascending: false)
      .limit(4);

  return (data as List)
      .whereType<Map>()
      .map((e) => e.cast<String, dynamic>())
      .toList();
});