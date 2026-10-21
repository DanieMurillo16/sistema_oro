import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/services/token_storage.dart';
import 'package:sistema_oro/features/auth/data/auth_repository.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';

/// Iniciar sesión. Sigue vivo mientras dura la petición: al abrirse la sesión
/// el login se cierra y, sin esto, el provider se liberaría a medio camino.
final loginProvider = AsyncNotifierProvider.autoDispose<LoginNotifier, void>(
  LoginNotifier.new,
);

class LoginNotifier extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> submit(String username, String password) async {
    if (state.isLoading) return;
    final link = ref.keepAlive();
    state = const AsyncLoading();
    try {
      state = await AsyncValue.guard(() async {
        final result = await ref
            .read(authRepositoryProvider)
            .login(username.trim(), password);
        await ref.read(tokenStorageProvider).save(result.token);
        ref.read(sessionProvider.notifier).open(result.session);
      });
    } finally {
      link.close();
    }
  }
}
