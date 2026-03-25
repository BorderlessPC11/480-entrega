import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';
import 'widgets/auth_primary_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({
    super.key,
    required this.onRecheck,
  });

  final Future<void> Function() onRecheck;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _auth = AuthService();
  bool _sending = false;
  bool _checking = false;

  Future<void> _resend() async {
    setState(() => _sending = true);
    try {
      await _auth.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email de verificação reenviado.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_auth.messageForError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _check() async {
    setState(() => _checking = true);
    try {
      await widget.onRecheck();
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final maxW = math.min(MediaQuery.sizeOf(context).width, 520.0);
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 400),
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
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.mark_email_unread_rounded,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Verifique seu email',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Enviamos um link para $email. Abra o email e toque no link para ativar sua conta.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.78),
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthPrimaryButton(
                              label: _checking
                                  ? 'Verificando…'
                                  : 'Já verifiquei — atualizar',
                              loading: _checking,
                              onPressed: _checking ? null : _check,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _sending ? null : _resend,
                              child: _sending
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Reenviar email'),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _signOut,
                              child: const Text('Sair'),
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
    );
  }
}
