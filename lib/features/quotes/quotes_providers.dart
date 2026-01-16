import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quotevault/shared/models/quote.dart';
import 'package:quotevault/supabase/supabase_client_provider.dart';
import 'quotes_repository.dart';

final quotesRepositoryProvider = Provider<QuotesRepository>((ref) {
  return QuotesRepository(ref.watch(supabaseClientProvider));
});

final homeCategoryProvider = StateProvider<String>((ref) => 'All');
final searchQueryProvider = StateProvider<String>((ref) => '');

final homeQuotesProvider = FutureProvider<List<Quote>>((ref) async {
  final repo = ref.watch(quotesRepositoryProvider);
  final category = ref.watch(homeCategoryProvider);
  return repo.fetchQuotes(category: category, query: '', favoriteIds: const <int>{}, limit: 80);
});

final searchResultsProvider = FutureProvider.family<List<Quote>, String>((ref, query) async {
  final q = query.trim();
  if (q.isEmpty) return [];
  final repo = ref.watch(quotesRepositoryProvider);
  return repo.fetchQuotes(category: 'All', query: q, favoriteIds: const <int>{}, limit: 80);
});