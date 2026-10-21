import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/motion.dart';
import 'package:sistema_oro/shared/widgets/app_empty_view.dart';
import 'package:sistema_oro/shared/widgets/app_error_view.dart';
import 'package:sistema_oro/shared/widgets/app_loader.dart';

/// Resuelve los **cuatro estados** de un `AsyncValue` (datos, cargando, error,
/// vacío) sin vaciar la pantalla al refrescar:
///
/// - Primera carga sin datos: [AppLoader].
/// - **Refresco o recarga con datos** (`refresh`, `invalidate`, volver a pedir):
///   se conservan los datos que ya se ven y solo asoma una barra fina arriba.
///   Sin `skipLoadingOnReload` un `ref.invalidate` mostraba el cargador de
///   página completa.
/// - Entre datos / vacío / error el cambio es un fundido, no un salto.
/// - Error con datos previos: se muestra el error (la UI no oculta un fallo).
class AppAsyncView<T> extends StatelessWidget {
  const AppAsyncView({
    super.key,
    required this.state,
    required this.builder,
    required this.isEmpty,
    required this.onRetry,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'Sin registros',
    this.emptyMessage = 'Aún no hay nada por mostrar.',
  });

  final AsyncValue<T> state;
  final Widget Function(T data) builder;
  final bool Function(T data) isEmpty;
  final VoidCallback onRetry;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final refreshing = state.isLoading && state.hasValue;
    final content = state.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      loading: () => const AppLoader(key: ValueKey('loading')),
      error: (error, _) => AppErrorView(
        key: const ValueKey('error'),
        message: userErrorMessage(error),
        onRetry: onRetry,
      ),
      data: (data) => isEmpty(data)
          ? AppEmptyView(
              key: const ValueKey('empty'),
              icon: emptyIcon,
              title: emptyTitle,
              message: emptyMessage,
            )
          : KeyedSubtree(key: const ValueKey('data'), child: builder(data)),
    );
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: motionDuration(context, DesignTokens.animationNormal),
            switchInCurve: DesignTokens.curve,
            child: content,
          ),
        ),
        if (refreshing)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }
}
