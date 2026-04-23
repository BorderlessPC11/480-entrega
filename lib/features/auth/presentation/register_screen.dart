import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/user/user_role.dart';
import 'auth_validators.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  UserRole _role = UserRole.entregador;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await _auth.register(
        _email.text,
        _password.text,
        role: _role,
      );
      // O utilizador fica com sessão iniciada: o AuthGate mostra a verificação de email.
      // Remove esta rota da pilha; caso contrário o formulário fica à frente da nova árvore.
      if (mounted) {
        Navigator.of(context).pop();
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
      appBar: AppBar(
        title: const Text('Criar conta'),
      ),
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) {
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, (1 - t) * 10),
                child: child,
              ),
            );
          },
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Cadastro',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Você receberá um email para confirmar o endereço.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.72),
                            ),
                      ),
                      const SizedBox(height: 20),
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
                                obscureText: _obscure1,
                                textInputAction: TextInputAction.next,
                                validator: validatePassword,
                                showObscureToggle: true,
                                onToggleObscure: () =>
                                    setState(() => _obscure1 = !_obscure1),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Papel',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<UserRole>(
                                value: _role,
                                decoration: const InputDecoration(
                                  labelText: 'Conta de',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: UserRole.entregador,
                                    child: Text('Entregador — vê e aceita rotas'),
                                  ),
                                  DropdownMenuItem(
                                    value: UserRole.solicitante,
                                    child: Text('Solicitante — cria rotas (OS)'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _role = v);
                                  }
                                },
                              ),
                              const SizedBox(height: 14),
                              AuthTextField(
                                controller: _confirm,
                                label: 'Confirmar senha',
                                obscureText: _obscure2,
                                textInputAction: TextInputAction.done,
                                validator: (v) =>
                                    validateConfirmPassword(v, _password.text),
                                showObscureToggle: true,
                                onToggleObscure: () =>
                                    setState(() => _obscure2 = !_obscure2),
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
                                label: 'Registrar',
                                loading: _loading,
                                onPressed: _submit,
                              ),
                            ],
                          ),
                        ),
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
