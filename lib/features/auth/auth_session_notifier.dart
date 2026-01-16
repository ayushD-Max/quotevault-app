import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../supabase/supabase_client_provider.dart';

final authSessionProvider =
    StateNotifierProvider<AuthSessionNotifier, Session?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final notifier = AuthSessionNotifier(client);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final authUserProvider = Provider<User?>((ref) {
  return ref.watch(authSessionProvider)?.user;
});

class AuthSessionNotifier extends StateNotifier<Session?> {
  final SupabaseClient _client;
  StreamSubscription<AuthState>? _sub;

  AuthSessionNotifier(this._client) : super(_client.auth.currentSession) {
    _sub = _client.auth.onAuthStateChange.listen((event) {
      state = event.session;
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}