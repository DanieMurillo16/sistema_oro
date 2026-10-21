import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';
import 'package:sistema_oro/shared/widgets/app_error_view.dart';
import 'package:sistema_oro/shared/widgets/app_loader.dart';

/// Lo que se ve en el diálogo mientras no hay ajustes: cargando o el error con
/// «Intentar nuevamente». Sin ajustes no se puede calcular el monto.
class CheckoutSettingsGate extends ConsumerWidget {
  const CheckoutSettingsGate({super.key, required this.state});

  final AsyncValue<CatalogSettings> state;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SizedBox(
    height: DesignTokens.receiptLoaderHeight,
    child: state.hasError
        ? AppErrorView(
            message: userErrorMessage(state.error),
            onRetry: () => ref.invalidate(catalogSettingsProvider),
          )
        : const AppLoader(),
  );
}
