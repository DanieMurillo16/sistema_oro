import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/core/services/app_toast.dart';
import 'package:sistema_oro/core/services/link_launcher.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/models/checkout_draft.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';
import 'package:sistema_oro/features/catalog/providers/checkout_provider.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';
import 'package:sistema_oro/features/catalog/widgets/checkout/checkout_form.dart';
import 'package:sistema_oro/features/catalog/widgets/checkout/checkout_settings_gate.dart';
import 'package:sistema_oro/features/catalog/widgets/checkout/checkout_success.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';

/// Comprar o separar una prenda. Al enviar muestra el código del pedido.
class CheckoutDialog extends ConsumerStatefulWidget {
  const CheckoutDialog({super.key, required this.garment, required this.kind});

  final CatalogGarment garment;
  final RequestKind kind;

  @override
  ConsumerState<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends ConsumerState<CheckoutDialog> {
  final _formKey = GlobalKey<CheckoutFormState>();

  bool get _isLayaway => widget.kind == RequestKind.layaway;

  @override
  Widget build(BuildContext context) {
    ref.listen(checkoutProvider, (previous, next) {
      if (previous?.isLoading == true && next.hasError) {
        AppToast.error(userErrorMessage(next.error));
      }
    });
    // Si mientras llena el formulario otra persona se lleva la prenda, se
    // cierra solo con un aviso. Con el envío en curso o ya enviado no: la
    // persona necesita ver su código.
    ref.listen(catalogGarmentProvider(widget.garment.id), (_, next) {
      final sending = ref.read(checkoutProvider);
      if (isGarmentGone(next) && !sending.isLoading && sending.value == null) {
        Navigator.of(context).pop();
        AppToast.warning('Otra persona acaba de llevarse esta prenda.');
      }
    });
    final checkout = ref.watch(checkoutProvider);
    final settingsState = ref.watch(catalogSettingsProvider);
    final settings = settingsState.value;
    final receipt = checkout.value;
    final router = GoRouter.of(context);
    // Ya reservó: al cerrar la confirmación (botón, X o tocando fuera) lo lleva a
    // la vista principal, sin dejarlo en el detalle de una prenda que ya reservó.
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && receipt != null) router.go(AppRoutes.catalog);
      },
      child: AppDialog(
        header: DialogHeader(
          icon: _isLayaway
              ? Icons.bookmark_border
              : Icons.shopping_bag_outlined,
          title: _isLayaway
              ? 'Separar con el ${settings?.percentLabel ?? '20 %'}'
              : 'Comprar',
          subtitle: widget.garment.nameLabel,
        ),
        content: receipt != null
            ? CheckoutSuccess(receipt: receipt, kind: widget.kind)
            : settings == null
            ? CheckoutSettingsGate(state: settingsState)
            : CheckoutForm(
                key: _formKey,
                garment: widget.garment,
                kind: widget.kind,
                settings: settings,
                onSubmit: (draft, image) =>
                    ref.read(checkoutProvider.notifier).submit(draft, image),
              ),
        actions: receipt != null
            ? settings?.hasWhatsapp ?? false
                  ? DialogActions(
                      onConfirm: () => ref
                          .read(linkLauncherProvider)
                          .openWhatsApp(
                            settings!.whatsapp,
                            message: widget.kind.whatsappMessage(
                              widget.garment.nameLabel,
                              receipt.code,
                            ),
                          ),
                      confirmLabel: 'Enviar por WhatsApp',
                      confirmIcon: Icons.chat_outlined,
                      cancelLabel: 'Cerrar',
                    )
                  : DialogActions(
                      onConfirm: () => Navigator.of(context).pop(),
                      confirmLabel: 'Cerrar',
                      confirmIcon: null,
                      showCancel: false,
                    )
            : DialogActions(
                onConfirm: settings == null
                    ? null
                    : () => _formKey.currentState?.submit(),
                isLoading: checkout.isLoading,
                confirmLabel: _isLayaway ? 'Enviar separado' : 'Enviar compra',
                confirmIcon: Icons.send_outlined,
              ),
      ),
    );
  }
}
