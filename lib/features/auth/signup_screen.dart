import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/ui/qv_widgets.dart';
import '../../shared/ui/qv_tokens.dart';
import 'auth_service.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  int _strength(String p) {
    var s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(p)) s++;
    if (RegExp(r'[0-9]').hasMatch(p)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    return s.clamp(0, 4);
  }

  Future<void> _signup() async {
    final fullName = _name.text.trim();
    final email = _email.text.trim();
    final password = _pass.text;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).signUpWithEmail(
            fullName: fullName,
            email: email,
            password: password,
          );
      // If email confirm is OFF => session created => AuthGate routes automatically
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = _strength(_pass.text);
    final label = switch (score) {
      0 || 1 => 'Weak',
      2 => 'Okay',
      3 => 'Strong',
      _ => 'Very strong',
    };

    return Scaffold(
      backgroundColor: qvBg(context),
      body: Stack(
        children: [
          // Background blobs (same)
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                color: QVColors.primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 160,
            left: -70,
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A65).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          QVConstrained(
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                children: [
                  Row(
                    children: [
                      QVCircleIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: _loading ? null : () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      Text(
                        'QuoteVault'.toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: QVColors.primary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Stack(
                    children: [
                      Positioned(
                        top: -18,
                        left: -8,
                        child: Text(
                          '“',
                          style: TextStyle(
                            fontSize: 70,
                            color: QVColors.primary.withOpacity(0.10),
                            fontFamilyFallback: const ['serif'],
                          ),
                        ),
                      ),
                      Text(
                        'Start your journey\nof inspiration.',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.06,
                              letterSpacing: -0.6,
                              color: qvText(context),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Join a community of curators collecting daily wisdom.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: qvText(context).withOpacity(0.55),
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                  ),

                  const SizedBox(height: 22),

                  _Label('Full Name'),
                  const SizedBox(height: 8),
                  QVTextField(hint: 'e.g. Maya Angelou', controller: _name, roundedFull: false),

                  const SizedBox(height: 14),
                  _Label('Email'),
                  const SizedBox(height: 8),
                  QVTextField(
                    hint: 'name@example.com',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    roundedFull: false,
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(Icons.mail_rounded, color: qvText(context).withOpacity(0.35), size: 20),
                    ),
                  ),

                  const SizedBox(height: 14),
                  _Label('Password'),
                  const SizedBox(height: 8),
                  QVTextField(
                    hint: '••••••••',
                    controller: _pass,
                    obscure: _hide,
                    roundedFull: false,
                    trailing: IconButton(
                      onPressed: () => setState(() => _hide = !_hide),
                      icon: Icon(_hide ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                      color: qvText(context).withOpacity(0.45),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Strength bar (same)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.20),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              height: 6,
                              width: 60 + (score * 40),
                              decoration: BoxDecoration(
                                color: QVColors.primary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: qvText(context).withOpacity(0.55),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  QVPrimaryButton(
                    label: _loading ? 'Creating…' : 'Create Account',
                    trailing: Icons.arrow_forward_rounded,
                    onPressed: _loading ? null : _signup,
                  ),

                  const SizedBox(height: 18),

                  Center(
                    child: TextButton(
                      onPressed: _loading ? null : () => Navigator.of(context).maybePop(),
                      child: Text(
                        'Already a member? Log in',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: qvText(context).withOpacity(0.55),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: qvText(context).withOpacity(0.85),
            ),
      ),
    );
  }
}