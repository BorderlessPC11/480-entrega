import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/auth/auth_exceptions.dart';
import '../../../core/auth/auth_service.dart';
import 'auth_validators.dart';
import 'register_screen.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await _auth.signIn(_email.text, _password.text);
    } on EmailNotVerifiedException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Confirme seu email para acessar o app.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = _auth.messageForError(e));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxW = math.min(MediaQuery.sizeOf(context).width, 520.0);

    return Scaffold(
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) {
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, (1 - t) * 12),
                child: child,
              ),
            );
          },
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Drive Home',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Entre com sua conta',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.75),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 28),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthTextField(
                                controller: _email,
                                label: 'Email',
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                validator: validateEmail,
                              ),
                              const SizedBox(height: 14),
                              AuthTextField(
                                controller: _password,
                                label: 'Senha',
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                validator: validatePassword,
                                showObscureToggle: true,
                                onToggleObscure: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  _error!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context).colorScheme.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                              const SizedBox(height: 18),
                              AuthPrimaryButton(
                                label: 'Entrar',
                                loading: _loading,
                                onPressed: _submit,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                        child: const Text('Criar conta'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
