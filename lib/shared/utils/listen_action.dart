import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter/foundation.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/core/services/app_toast.dart';

/// Reacciona a la transición «estaba cargando → terminó» de un notifier de
/// escritura (`AsyncNotifier<String?>`, cuyo dato es el mensaje de éxito):
/// éxito → aviso verde y [onSuccess]; error → aviso rojo. Se llama dentro de
/// `build`. Así la vista no tiene `try/catch`.
void listenAction(
  WidgetRef ref,
  ProviderListenable<AsyncValue<String?>> provider, {
  VoidCallback? onSuccess,
}) {
  ref.listen<AsyncValue<String?>>(provider, (previous, next) {
    if (previous?.isLoading != true || next.isLoading) return;
    if (next.hasError) {
      AppToast.error(userErrorMessage(next.error));
      return;
    }
    final message = next.value;
    if (message != null) AppToast.success(message);
    onSuccess?.call();
  });
}
