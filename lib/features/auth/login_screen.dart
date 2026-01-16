import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/ui/qv_widgets.dart';
import '../../shared/ui/qv_tokens.dart';
import 'auth_service.dart';
import 'signup_screen.dart';
import 'reset_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _email.text.trim();
    final password = _pass.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email & password')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).signInWithEmail(
            email: email,
            password: password,
          );
      // AuthGate will switch screens automatically on session.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
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
            padding: const EdgeInsets.fromLTRB(26, 18, 26, 22),
            children: [
              const SizedBox(height: 18),
              Center(
                child: Text(
                  'QUOTEVault'.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: qvText(context),
                      ),
                ),
              ),
              const SizedBox(height: 26),

              // Hero / Headline (same vibe)
              Column(
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: QVColors.primary.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_open_rounded, color: QVColors.primary, size: 32),
                  ),
                  const SizedBox(height: 18),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Welcome back to your '),
                        TextSpan(
                          text: 'sanctuary',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: QVColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const TextSpan(text: ' of wisdom.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w300,
                          height: 1.18,
                          letterSpacing: -0.4,
                          color: qvText(context),
                        ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // Email
              _FieldLabel('Email Address'),
              const SizedBox(height: 8),
              QVTextField(
                hint: 'name@example.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Icon(Icons.mail_rounded, color: qvText(context).withOpacity(0.35), size: 20),
                ),
              ),

              const SizedBox(height: 16),

              // Password
              _FieldLabel('Password'),
              const SizedBox(height: 8),
              QVTextField(
                hint: 'Enter your password',
                controller: _pass,
                obscure: _hide,
                trailing: IconButton(
                  onPressed: () => setState(() => _hide = !_hide),
                  icon: Icon(_hide ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                  color: qvText(context).withOpacity(0.45),
                ),
              ),

              const SizedBox(height: 10),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
                          );
                        },
                  child: Text(
                    'Forgot Password?',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: qvText(context).withOpacity(0.55),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Primary action
              QVPrimaryButton(
                label: _loading ? 'Please wait…' : 'Enter Vault',
                trailing: Icons.arrow_forward_rounded,
                onPressed: _loading ? null : _login,
              ),

              const SizedBox(height: 26),

              // Divider (keep simple)
              _DividerWithText('Or continue with'),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _SocialCircle(label: 'ios'),
                  SizedBox(width: 14),
                  _SocialCircle(label: 'G'),
                ],
              ),

              const SizedBox(height: 26),

              // Signup link
              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'New to QuoteVault? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: qvText(context).withOpacity(0.55),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: _loading
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                                  );
                                },
                          child: Text(
                            'Create an account',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: QVColors.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: qvText(context).withOpacity(0.45),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _DividerWithText extends StatelessWidget {
  final String text;
  const _DividerWithText(this.text);

  @override
  Widget build(BuildContext context) {
    final line = Container(height: 1, color: qvText(context).withOpacity(0.10));
    return Row(
      children: [
        Expanded(child: line),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: qvText(context).withOpacity(0.35),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                ),
          ),
        ),
        Expanded(child: line),
      ],
    );
  }
}

class _SocialCircle extends StatelessWidget {
  final String label;
  const _SocialCircle({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = qvIsDark(context);
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        color: qvSurface(context),
        shape: BoxShape.circle,
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: qvText(context),
              ),
        ),
      ),
    );
  }
}