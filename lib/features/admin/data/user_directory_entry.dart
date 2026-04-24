import '../../../core/user/user_role.dart' show UserRole, userRoleFromFirestore;

/// Uma linha do diretório `users/{uid}` para listagens de admin.
class UserDirectoryEntry {
  const UserDirectoryEntry({
    required this.uid,
    required this.email,
    this.displayName,
    this.phone,
    this.disponivelSaqueCents,
    this.role = UserRole.entregador,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? phone;
  /// Saldo ajustado manualmente no Firestore (centavos). Se null, a UI infere a partir do total.
  final int? disponivelSaqueCents;
  final UserRole role;

  String get nameOrFallback {
    final n = displayName?.trim() ?? '';
    if (n.isNotEmpty) {
      return n;
    }
    if (email.isNotEmpty) {
      return email.split('@').first;
    }
    return 'Utilizador';
  }

  String get initials {
    final n = displayName?.trim() ?? '';
    if (n.length >= 2) {
      return n.substring(0, 2).toUpperCase();
    }
    if (n.isNotEmpty) {
      return n[0].toUpperCase();
    }
    if (email.isNotEmpty) {
      final l = email.split('@').first;
      if (l.length >= 2) {
        return l.substring(0, 2).toUpperCase();
      }
      if (l.isNotEmpty) {
        return l[0].toUpperCase();
      }
    }
    if (uid.length >= 2) {
      return uid.substring(0, 2).toUpperCase();
    }
    return '?';
  }

  static UserDirectoryEntry? fromMap(String docId, Map<String, dynamic> m) {
    final email = (m['email'] as String?)?.trim() ?? '';
    if (email.isEmpty) {
      return null;
    }
    return UserDirectoryEntry(
      uid: docId,
      email: email,
      displayName: () {
        final d = m['displayName'];
        if (d is! String) {
          return null;
        }
        final t = d.trim();
        return t.isEmpty ? null : t;
      }(),
      phone: () {
        final p = m['phone'];
        if (p is! String) {
          return null;
        }
        final t = p.trim();
        return t.isEmpty ? null : t;
      }(),
      disponivelSaqueCents: (m['disponivelSaqueCents'] as num?)?.toInt(),
      role: userRoleFromFirestore(m['role']) ?? UserRole.entregador,
    );
  }
}
