import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';
import 'package:sistema_oro/features/orders/utils/order_rules.dart';
import 'package:sistema_oro/features/orders/widgets/dialogs/edit_delivery_dialog.dart';
import 'package:sistema_oro/shared/widgets/app_action_button.dart';
import 'package:sistema_oro/shared/widgets/info_grid.dart';
import 'package:sistema_oro/shared/widgets/section_card.dart';

/// Cómo recibe el cliente: recoge o envío (con ciudad, dirección y guía).
class OrderDeliveryCard extends ConsumerWidget {
  const OrderDeliveryCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = order.detail;
    final canEdit =
        OrderRules.canEditDelivery(order) &&
        ref.watch(canProvider(Permissions.ordersReview));
    return SectionCard(
      title: 'Entrega',
      trailing: canEdit
          ? AppActionButton(
              icon: Icons.edit_outlined,
              tooltip: 'Editar entrega',
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => EditDeliveryDialog(order: order),
              ),
            )
          : null,
      child: InfoGrid(
        items: [
          InfoItem('Modalidad', order.delivery.label),
          if (detail?.trackingNumber != null)
            InfoItem('Guía', detail!.trackingNumber!),
          if (detail != null && detail.deliveredLabel.isNotEmpty)
            InfoItem('Entregado', detail.deliveredLabel),
          if (detail != null && detail.addressLabel.isNotEmpty)
            InfoItem('Dirección', detail.addressLabel, wide: true),
        ],
      ),
    );
  }
}
