import 'package:supabase_flutter/supabase_flutter.dart';

class CollectionsService {
  final SupabaseClient _client;
  CollectionsService(this._client);

  Future<Map<String, dynamic>> createCollection({
    required String userId,
    required String title,
    String colorHex = 'EA2A33',
  }) async {
    final row = await _client
        .from('collections')
        .insert({
          'user_id': userId,
          'title': title,
          'color_hex': colorHex,
        })
        .select('id, title, color_hex, created_at')
        .single();

    return (row as Map).cast<String, dynamic>();
  }

  Future<void> addQuoteToCollection({
    required int collectionId,
    required int quoteId,
  }) async {
    
    await _client.from('collection_quotes').upsert(
      {
        'collection_id': collectionId,
        'quote_id': quoteId,
      },
      onConflict: 'collection_id,quote_id',
    );
  }
}