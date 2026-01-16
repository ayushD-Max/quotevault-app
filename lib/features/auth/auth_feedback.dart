import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateProvider;

final authFeedbackProvider = StateProvider<AuthFeedback?>((ref) => null);

class AuthFeedback {
  final String title;
  final String message;
  final bool goToProfile;

  const AuthFeedback({
    required this.title,
    required this.message,
    this.goToProfile = false,
  });
}