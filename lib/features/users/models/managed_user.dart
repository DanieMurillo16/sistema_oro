import 'package:sistema_oro/core/utils/json_helpers.dart';

/// Un usuario de la administración (lo ve y gestiona solo el dueño).
class ManagedUser {
  const ManagedUser({
    required this.id,
    required this.name,
    required this.username,
    required this.active,
    required this.roleId,
    required this.role,
    required this.createdAt,
  });

  factory ManagedUser.fromJson(Map<String, dynamic> json) => ManagedUser(
    id: jsonInt(json['id_usuario']),
    name: jsonString(json['nombre_completo'] ?? json['nombre']),
    username: jsonString(json['usuario']),
    active: jsonBool(json['activo']),
    roleId: jsonInt(json['id_rol']),
    role: jsonString(json['rol']),
    createdAt: jsonDateOrNull(json['creado_en']),
  );

  final int id;
  final String name;
  final String username;
  final bool active;
  final int roleId;
  final String role;
  final DateTime? createdAt;
}

class UserRole {
  const UserRole({required this.id, required this.name});

  factory UserRole.fromJson(Map<String, dynamic> json) =>
      UserRole(id: jsonInt(json['id_rol']), name: jsonString(json['nombre']));

  final int id;
  final String name;
}
