enum UserRole {
  entregador,
  solicitante,
}

extension UserRoleSerialization on UserRole {
  String get asFirestore {
    return switch (this) {
      UserRole.entregador => 'entregador',
      UserRole.solicitante => 'solicitante',
    };
  }

  String get displayLabel {
    return switch (this) {
      UserRole.entregador => 'Entregador',
      UserRole.solicitante => 'Solicitante',
    };
  }
}

UserRole? userRoleFromFirestore(Object? v) {
  if (v is! String) return null;
  return switch (v) {
    'entregador' => UserRole.entregador,
    'solicitante' => UserRole.solicitante,
    _ => null,
  };
}
