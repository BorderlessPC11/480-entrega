import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_directory_entry.dart';

class UserDirectoryRepository {
  UserDirectoryRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const _kUsers = 'users';

  /// Todos os documentos de utilizadores (requer regras Firestore apropriadas).
  Stream<List<UserDirectoryEntry>> watchAllUsers() {
    return _db.collection(_kUsers).snapshots().map((s) {
      final list = <UserDirectoryEntry>[];
      for (final d in s.docs) {
        final e = UserDirectoryEntry.fromMap(d.id, d.data());
        if (e != null) {
          list.add(e);
        }
      }
      list.sort((a, b) => a.email.toLowerCase().compareTo(b.email.toLowerCase()));
      return list;
    });
  }
}
