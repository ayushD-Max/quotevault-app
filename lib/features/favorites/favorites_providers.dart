import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quotevault/shared/models/quote.dart';
import 'package:quotevault/supabase/supabase_client_provider.dart';
import 'package:quotevault/features/auth/auth_session_notifier.dart';

final favoriteQuotesProvider = FutureProvider<List<Quote>>((ref) async {
  final user = ref.watch(authUserProvider);
  if (user == null) return [];

  final client = ref.watch(supabaseClientProvider);

  final data = await client
      .from('favorites')
      .select('created_at, quotes:quotes (id, quote_text, author, category)')
      .eq('user_id', user.id)
      .order('created_at', ascending: false);

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
            liked: true,
          ),
        );
      }
    }
  }
  return out;
});