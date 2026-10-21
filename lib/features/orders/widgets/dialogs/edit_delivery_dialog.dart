import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';
import 'package:sistema_oro/features/orders/providers/order_actions_provider.dart';
import 'package:sistema_oro/features/orders/widgets/dialogs/delivery_address_fields.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';
import 'package:sistema_oro/shared/utils/listen_action.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/app_toggle.dart';
import 'package:sistema_oro/shared/widgets/app_toggle_option.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';

/// Corregir cómo recibe el cliente: recoge en tienda o envío (ciudad y
/// dirección son obligatorias para enviar).
class EditDeliveryDialog extends ConsumerStatefulWidget {
  const EditDeliveryDialog({super.key, required this.order});

  final Order order;

  @override
  ConsumerState<EditDeliveryDialog> createState() => _EditDeliveryDialogState();
}

class _EditDeliveryDialogState extends ConsumerState<EditDeliveryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _city = TextEditingController(text: widget.order.detail?.city);
  late final _address = TextEditingController(
    text: widget.order.detail?.address,
  );
  late var _delivery = widget.order.delivery;

  @override
  void dispose() {
    _city.dispose();
    _address.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final shipping = _delivery == DeliveryType.shipping;
    ref
        .read(orderActionsProvider.notifier)
        .editDelivery(
          widget.order.id,
          delivery: _delivery,
          city: shipping ? _city.text.trim() : null,
          address: shipping ? _address.text.trim() : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    listenAction(
      ref,
      orderActionsProvider,
      onSuccess: () => Navigator.of(context).pop(),
    );
    return AppDialog(
      header: DialogHeader(
        icon: Icons.edit_location_alt_outlined,
        title: 'Editar entrega',
        subtitle: widget.order.codeLabel,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppToggle<DeliveryType>(
              options: [
                AppToggleOption(
                  value: DeliveryType.pickup,
                  label: 'Recoge',
                  icon: Icons.storefront_outlined,
                ),
                AppToggleOption(
                  value: DeliveryType.shipping,
                  label: 'Envío',
                  icon: Icons.local_shipping_outlined,
                ),
              ],
              selected: _delivery,
              onSelected: (value) => setState(() => _delivery = value),
            ),
            DeliveryAddressFields(
              delivery: _delivery,
              city: _city,
              address: _address,
            ),
          ],
        ),
      ),
      actions: DialogActions(
        onConfirm: _submit,
        isLoading: ref.watch(orderActionsProvider).isLoading,
        confirmLabel: 'Guardar entrega',
      ),
    );
  }
}
