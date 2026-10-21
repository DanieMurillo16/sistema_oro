import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/users/data/users_repository.dart';
import 'package:sistema_oro/features/users/models/managed_user.dart';

/// Los usuarios de la administración (solo los ve el dueño).
final usersProvider = AsyncNotifierProvider<UsersNotifier, List<ManagedUser>>(
  UsersNotifier.new,
);

class UsersNotifier extends AsyncNotifier<List<ManagedUser>> {
  @override
  Future<List<ManagedUser>> build() async {
    ref.watch(sessionUserIdProvider);
    if (!ref.watch(canProvider(Permissions.usersManage))) return const [];
    return ref.read(usersRepositoryProvider).list();
  }
}

final rolesProvider = FutureProvider<List<UserRole>>((ref) {
  ref.watch(sessionUserIdProvider);
  if (!ref.watch(canProvider(Permissions.usersManage))) return const [];
  return ref.read(usersRepositoryProvider).roles();
});

/// Crear, editar y cambiar la clave. Tras cada una se recarga la lista (son
/// pocos usuarios) y se conserva lo que se ve mientras llega.
final userActionsProvider =
    AsyncNotifierProvider.autoDispose<UserActionsNotifier, String?>(
      UserActionsNotifier.new,
    );

class UserActionsNotifier extends AsyncNotifier<String?> {
  UsersRepository get _repository => ref.read(usersRepositoryProvider);

  @override
  String? build() => null;

  Future<void> create({
    required String name,
    required String username,
    required String password,
    required int roleId,
  }) => _run(() async {
    await _repository.create(
      name: name,
      username: username,
      password: password,
      roleId: roleId,
    );
    return 'Usuario creado';
  });

  Future<void> edit(
    int id, {
    required String name,
    required int roleId,
    required bool active,
  }) => _run(() async {
    await _repository.edit(id, name: name, roleId: roleId, active: active);
    return 'Usuario actualizado';
  });

  Future<void> changePassword(int id, String password) => _run(() async {
    await _repository.changePassword(id, password);
    return 'Contraseña cambiada. Se cerraron sus sesiones.';
  });

  Future<void> _run(Future<String> Function() action) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final message = await action();
      ref.invalidate(usersProvider);
      return message;
    });
  }
}
