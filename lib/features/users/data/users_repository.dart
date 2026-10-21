import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/network/api_client.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';
import 'package:sistema_oro/core/utils/json_helpers.dart';
import 'package:sistema_oro/features/users/models/managed_user.dart';

final usersRepositoryProvider = Provider<UsersRepository>(
  (ref) => UsersRepository(ref.watch(apiClientProvider)),
);

class UsersRepository {
  const UsersRepository(this._api);

  final ApiClient _api;

  Future<List<ManagedUser>> list() async =>
      jsonMapList(await _api.getList(ApiEndpoints.usersList))
          .map(ManagedUser.fromJson)
          .toList();

  Future<List<UserRole>> roles() async =>
      jsonMapList(await _api.getList(ApiEndpoints.usersRoles))
          .map(UserRole.fromJson)
          .toList();

  Future<void> create({
    required String name,
    required String username,
    required String password,
    required int roleId,
  }) => _api.post(
    ApiEndpoints.usersCreate,
    data: {
      'nombre': name,
      'usuario': username,
      'clave': password,
      'id_rol': roleId,
    },
  );

  Future<void> edit(
    int id, {
    required String name,
    required int roleId,
    required bool active,
  }) => _api.post(
    ApiEndpoints.usersEdit,
    data: {'id': id, 'nombre': name, 'id_rol': roleId, 'activo': active},
  );

  Future<void> changePassword(int id, String password) => _api.post(
    ApiEndpoints.usersChangePassword,
    data: {'id': id, 'clave': password},
  );
}
