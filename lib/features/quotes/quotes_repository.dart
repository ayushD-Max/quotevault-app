import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quotevault/shared/models/quote.dart';

class QuotesRepository {
  final SupabaseClient _client;
  QuotesRepository(this._client);

  Future<List<Quote>> fetchQuotes({
    required String category, // 'All' allowed
    required String query, // '' allowed
    required Set<int> favoriteIds,
    int limit = 60,
  }) async {
    // ✅ dynamic => avoids FilterBuilder/TransformBuilder assignment issues
    dynamic req = _client.from('quotes').select('id, quote_text, author, category');

    if (category != 'All') {
      req = req.eq('category', category);
    }

    final q = query.trim();
    if (q.isNotEmpty) {
      req = req.or('quote_text.ilike.%$q%,author.ilike.%$q%');
    }

    // ✅ do NOT re-type the builder; dynamic handles it safely
    req = req.order('id', ascending: true);
    req = req.limit(limit);

    final data = await req;

    final list = <Quote>[];
    for (final row in (data as List)) {
      if (row is Map) {
        final m = row.cast<String, dynamic>();
        final id = (m['id'] as num).toInt();

        list.add(
          Quote(
            id: id,
            text: (m['quote_text'] as String?) ?? '',
            author: (m['author'] as String?) ?? 'Unknown',
            category: (m['category'] as String?) ?? 'Motivation',
            liked: favoriteIds.contains(id),
          ),
        );
      }
    }
    return list;
  }

  Future<List<Quote>> fetchQuotesByIds({required List<int> ids}) async {
    if (ids.isEmpty) return [];

    dynamic req = _client
        .from('quotes')
        .select('id, quote_text, author, category')
        .inFilter('id', ids);

    final data = await req;

    final list = <Quote>[];
    for (final row in (data as List)) {
      if (row is Map) {
        final m = row.cast<String, dynamic>();
        list.add(
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
    return list;
  }
}