import 'package:firebase_auth/firebase_auth.dart';

import 'auth_exceptions.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  /// Registers, signs the user in, and sends the verification email.
  Future<void> register(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user?.sendEmailVerification();
  }

  /// Signs in and reloads the user. If email is not verified, throws
  /// [EmailNotVerifiedException] (user stays signed in for verification UI).
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _auth.currentUser?.reload();
    final u = _auth.currentUser;
    if (u != null && !u.emailVerified) {
      throw const EmailNotVerifiedException();
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendEmailVerification() async {
    final u = _auth.currentUser;
    if (u != null && !u.emailVerified) {
      await u.sendEmailVerification();
    }
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  String messageForError(Object error) {
    if (error is EmailNotVerifiedException) {
      return 'Confirme seu email para continuar. Enviamos um link para você.';
    }
    if (error is FirebaseAuthException) {
      return _mapCode(error.code);
    }
    return 'Algo deu errado. Tente novamente.';
  }

  String _mapCode(String code) {
    return switch (code) {
      'invalid-email' => 'Email inválido.',
      'user-disabled' => 'Esta conta foi desativada.',
      'user-not-found' => 'Nenhuma conta encontrada com este email.',
      'wrong-password' => 'Senha incorreta.',
      'invalid-credential' => 'Email ou senha inválidos.',
      'email-already-in-use' => 'Este email já está em uso.',
      'weak-password' => 'Senha fraca. Use pelo menos 6 caracteres.',
      'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde.',
      'network-request-failed' => 'Sem conexão. Verifique a internet.',
      _ => 'Erro de autenticação. Tente novamente.',
    };
  }
}
