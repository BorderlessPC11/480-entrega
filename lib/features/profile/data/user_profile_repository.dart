import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/user/user_role.dart';

/// Dados de perfil em `users/{uid}` (telefone, papel, estatísticas, veículo).
class UserProfileRepository {
  UserProfileRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

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

  Stream<UserRole> watchRole(String uid) {
    return _doc(uid).snapshots().map((s) {
      if (!s.exists) return UserRole.entregador;
      return userRoleFromFirestore(s.data()?['role']) ??
          UserRole.entregador;
    });
  }

  /// Campos de perfil exibidos na tela (incl. mock migrado p/ entregador).
  Stream<Map<String, dynamic>> watchUserProfile(String uid) {
    return _doc(uid).snapshots().map((s) => s.data() ?? <String, dynamic>{});
  }

  /// Nome mostrado em listagens admin (sincronizado a partir de "Editar perfil").
  Future<void> setDisplayName(String uid, String name) async {
    final t = name.trim();
    if (t.isEmpty) {
      await _doc(uid).set(
        <String, dynamic>{'displayName': FieldValue.delete()},
        SetOptions(merge: true),
      );
    } else {
      await _doc(uid).set(
        <String, dynamic>{
          'displayName': t,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
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

  /// Chamado após o cadastro (com Auth já criado).
  Future<void> createInitialDocument({
    required String uid,
    required String email,
    required UserRole role,
  }) async {
    final data = <String, dynamic>{
      'email': email,
      'role': role.asFirestore,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (role == UserRole.entregador) {
      data.addAll(_entregadorDefaultStats);
    } else {
      data['admin'] = true;
    }
    await _doc(uid).set(data, SetOptions(merge: true));
  }

  static const _entregadorDefaultStats = <String, dynamic>{
    'rating': 4.8,
    'reviewCount': 128,
    'totalTrips': 842,
    'completedOrders': 806,
    'experienceMonths': 14,
    'vehicleModel': 'Fiat Strada • Prata',
    'vehiclePlate': 'ABC1D23',
    'vehicleStatus': 'Ativo',
  };
}
