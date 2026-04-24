enum UserRole {
  entregador,
  admin,
}

extension UserRoleSerialization on UserRole {
  String get asFirestore {
    return switch (this) {
      UserRole.entregador => 'entregador',
      UserRole.admin => 'admin',
    };
  }

  String get displayLabel {
    return switch (this) {
      UserRole.entregador => 'Entregador',
      UserRole.admin => 'Administrador',
    };
  }
}

UserRole? userRoleFromFirestore(Object? v) {
  if (v is! String) return null;
  return switch (v) {
    'entregador' => UserRole.entregador,
    // Valor em documentos antigos; tratar como admin.
    'admin' => UserRole.admin,
    'solicitante' => UserRole.admin,
    _ => null,
  };
}
