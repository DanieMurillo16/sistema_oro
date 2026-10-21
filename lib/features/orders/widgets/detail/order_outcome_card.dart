import 'package:flutter/material.dart';
import 'package:sistema_oro/features/orders/models/order_detail.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';
import 'package:sistema_oro/shared/widgets/info_grid.dart';
import 'package:sistema_oro/shared/widgets/section_card.dart';

/// Por qué se rechazó o qué se decidió al cancelar (registro inmutable).
class OrderOutcomeCard extends StatelessWidget {
  const OrderOutcomeCard({super.key, required this.detail});

  final OrderDetail detail;

  /// ¿Hay algo que mostrar? (rechazado con motivo o cancelado con decisión).
  static bool applies(OrderDetail detail) =>
      detail.cancellation != null ||
      (detail.order.status == OrderStatus.rejected &&
          detail.order.detail?.rejectReason != null);

  @override
  Widget build(BuildContext context) {
    final cancellation = detail.cancellation;
    if (cancellation == null) {
      return SectionCard(
        title: 'Rechazado',
        child: InfoGrid(
          items: [
            InfoItem(
              'Motivo',
              detail.order.detail?.rejectReason ?? '',
              wide: true,
            ),
          ],
        ),
      );
    }
    return SectionCard(
      title: 'Cancelado',
      child: InfoGrid(
        items: [
          InfoItem('Decisión', cancellation.decision.label),
          InfoItem('Pagado', cancellation.paidLabel),
          InfoItem('Retenido', cancellation.retainedLabel),
          InfoItem('Devuelto', cancellation.returnedLabel),
          InfoItem('Motivo', cancellation.reason, wide: true),
          InfoItem(
            'Por',
            '${cancellation.cancelledBy} · ${cancellation.whenLabel}',
            wide: true,
          ),
        ],
      ),
    );
  }
}
