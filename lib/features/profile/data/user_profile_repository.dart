import 'package:cloud_firestore/cloud_firestore.dart';

/// Perfil adicional (telefone) em `users/{uid}`.
class UserProfileRepository {
  UserProfileRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  /// Telefone exibido no app (texto livre, ex. máscara BR).
  Stream<String?> watchPhone(String uid) {
    return _doc(uid).snapshots().map((s) {
      if (!s.exists) return null;
      final p = s.data()?['phone'];
      if (p is String) {
        final t = p.trim();
        return t.isEmpty ? null : t;
      }
      return null;
    });
  }

  Future<void> setPhone(String uid, String phone) async {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) {
      await _doc(uid).set(
        <String, dynamic>{'phone': FieldValue.delete()},
        SetOptions(merge: true),
      );
    } else {
      await _doc(uid).set(
        <String, dynamic>{
          'phone': trimmed,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
  }
}
