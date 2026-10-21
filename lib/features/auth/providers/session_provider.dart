import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/core/services/session_expiration.dart';
import 'package:sistema_oro/core/services/token_storage.dart';
import 'package:sistema_oro/features/auth/data/auth_repository.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';

/// La sesión de la administración: `null` = sin sesión (ir al login). Se
/// recupera del token guardado; un 401 (el ApiClient avisa por
/// `sessionExpirationProvider`) la reconstruye y queda en `null`.
final sessionProvider = AsyncNotifierProvider<SessionNotifier, AppSession?>(
  SessionNotifier.new,
);

/// Id del usuario en sesión: los providers de datos lo observan para no
/// mezclar cuentas al cerrar sesión o cambiar de usuario.
final sessionUserIdProvider = Provider<int?>(
  (ref) => ref.watch(sessionProvider.select((s) => s.value?.user.id)),
);

/// ¿El usuario en sesión tiene este permiso?
final canProvider = Provider.family<bool, String>(
  (ref, permission) =>
      ref.watch(sessionProvider.select((s) => s.value?.can(permission))) ??
      false,
);

class SessionNotifier extends AsyncNotifier<AppSession?> {
  @override
  Future<AppSession?> build() async {
    ref.watch(sessionExpirationProvider);
    final token = await ref.read(tokenStorageProvider).read();
    if (token == null || token.isEmpty) return null;
    try {
      return await ref.read(authRepositoryProvider).profile();
    } on ApiException catch (error) {
      if (error.statusCode == 401) return null;
      rethrow;
    }
  }

  /// Lo llama el login una vez guardado el token.
  void open(AppSession session) => state = AsyncData(session);

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } on AppException {
      // Se cierra la sesión local aunque el servidor no responda.
    }
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncData(null);
  }
}
