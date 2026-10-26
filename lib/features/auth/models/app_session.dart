import 'package:sistema_oro/core/utils/json_helpers.dart';

/// Quién entró: lo que dice `auth/login.php` y `auth/perfil.php`.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: jsonInt(json['id_usuario']),
    name: jsonString(json['nombre_completo']),
    username: jsonString(json['usuario']),
    role: jsonString(json['rol']),
  );

  final int id;
  final String name;
  final String username;
  final String role;
}

/// El usuario y los permisos (`modulo.accion`) que dio el servidor. La app
/// esconde lo que no corresponde; el servidor igual lo impide.
class AppSession {
  const AppSession({required this.user, required this.permissions});

  factory AppSession.fromJson(Map<String, dynamic> json) => AppSession(
    user: AppUser.fromJson(jsonMap(json['perfil'])),
    permissions: {
      for (final code in (json['permisos'] as List? ?? const []))
        code.toString(),
    },
  );

  final AppUser user;
  final Set<String> permissions;

  bool can(String permission) => permissions.contains(permission);
}

/// Resultado de iniciar sesión: la sesión y el token que se guarda.
class LoginResult {
  const LoginResult({required this.session, required this.token});

  final AppSession session;
  final String token;
}

/// Códigos de permiso del servidor (backend/docs/BD.md §6).
abstract final class Permissions {
  static const usersManage = 'usuarios.gestionar';
  static const garmentsView = 'prendas.ver';
  static const garmentsCreate = 'prendas.crear';
  static const garmentsEdit = 'prendas.editar';
  static const garmentsCost = 'prendas.ver_costo';
  static const garmentsStock = 'prendas.ajustar_stock';
  static const garmentsDelete = 'prendas.eliminar';
  static const typesManage = 'tipos.gestionar';
  static const ordersView = 'pedidos.ver';
  static const ordersReview = 'pedidos.revisar';
  static const ordersDeliver = 'pedidos.entregar';
  static const ordersCancel = 'pedidos.cancelar';
  static const paymentsRegister = 'pagos.registrar';
  static const paymentsVoid = 'pagos.anular';
  static const clientsView = 'clientes.ver';
  static const clientsEdit = 'clientes.editar';
  static const settingsView = 'ajustes.ver';
  static const settingsEdit = 'ajustes.editar';
  static const summaryView = 'resumen.ver';
}
