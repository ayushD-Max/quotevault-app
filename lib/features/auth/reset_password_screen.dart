import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/ui/qv_widgets.dart';
import '../../shared/ui/qv_tokens.dart';
import 'auth_service.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).resetPassword(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recovery link sent. Check your email.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: qvBg(context),
      body: QVConstrained(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: QVCircleIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: _loading ? null : () => Navigator.of(context).maybePop(),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Reset your\npassword',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                      letterSpacing: -0.6,
                      color: qvText(context),
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your email to receive a recovery link.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: qvText(context).withOpacity(0.70),
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
              ),

              const SizedBox(height: 28),

              QVTextField(
                hint: 'name@example.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                leading: Icons.mail_rounded,
              ),

              const SizedBox(height: 20),

              QVPrimaryButton(
                label: _loading ? 'Sending…' : 'Send Link',
                trailing: Icons.arrow_forward_rounded,
                onPressed: _loading ? null : _send,
              ),

              const SizedBox(height: 14),

              Center(
                child: TextButton(
                  onPressed: _loading ? null : () => Navigator.of(context).maybePop(),
                  child: Text(
                    'Back to Login',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: qvText(context).withOpacity(0.60),
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationThickness: 1,
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              Opacity(
                opacity: qvIsDark(context) ? 0.18 : 0.20,
                child: Center(
                  child: Icon(Icons.lock_open_rounded, size: 44, color: qvText(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}