import 'package:firebase_auth/firebase_auth.dart';

import '../user/user_role.dart';
import 'auth_exceptions.dart';
import 'package:borderless_app/features/profile/data/user_profile_repository.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  /// Registra o utilizador como entregador, inicia sessão e envia o email de verificação.
  /// A criação de ordens e gestão de contas fica a cargo do painel de administrador.
  Future<void> register(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = cred.user?.uid;
    if (uid != null) {
      await UserProfileRepository().createInitialDocument(
        uid: uid,
        email: email.trim(),
        role: UserRole.entregador,
      );
    }
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

  /// Atualiza o nome de exibição (Firebase Auth). Chama [reload] em seguida.
  Future<void> updateDisplayName(String displayName) async {
    final u = _auth.currentUser;
    if (u == null) {
      throw StateError('Nenhum usuário autenticado.');
    }
    final t = displayName.trim();
    await u.updateDisplayName(t.isEmpty ? null : t);
    await u.reload();
  }

  /// Atualiza a URL da foto (Storage ou provedor). [photoUrl] `null` remove a foto.
  Future<void> updatePhotoUrl(String? photoUrl) async {
    final u = _auth.currentUser;
    if (u == null) {
      throw StateError('Nenhum usuário autenticado.');
    }
    await u.updatePhotoURL(photoUrl);
    await u.reload();
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
