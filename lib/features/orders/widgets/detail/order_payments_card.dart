import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/layaways/widgets/dialogs/void_payment_dialog.dart';
import 'package:sistema_oro/features/orders/models/order_detail.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';
import 'package:sistema_oro/features/orders/utils/order_rules.dart';
import 'package:sistema_oro/features/orders/widgets/detail/payment_tile.dart';
import 'package:sistema_oro/features/orders/widgets/dialogs/receipt_dialog.dart';
import 'package:sistema_oro/shared/widgets/section_card.dart';

/// Los pagos del pedido, con su comprobante y la opción de anular.
class OrderPaymentsCard extends ConsumerWidget {
  const OrderPaymentsCard({super.key, required this.detail});

  final OrderDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canVoid = ref.watch(canProvider(Permissions.paymentsVoid));
    return SectionCard(
      title: 'Pagos',
      child: detail.payments.isEmpty
          ? Text(
              'Aún no hay pagos.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          : Column(
              children: [
                for (final payment in detail.payments)
                  PaymentTile(
                    key: ValueKey(payment.id),
                    payment: payment,
                    onReceipt: payment.receipt == null
                        ? null
                        : () => showDialog<void>(
                            context: context,
                            builder: (_) =>
                                ReceiptDialog(file: payment.receipt!),
                          ),
                    onVoid:
                        canVoid &&
                            OrderRules.canVoidPayment(detail.order, payment)
                        ? () => showDialog<void>(
                            context: context,
                            builder: (_) => VoidPaymentDialog(
                              payment: payment,
                              reopens: detail.order.status == OrderStatus.paid,
                            ),
                          )
                        : null,
                  ),
              ],
            ),
    );
  }
}
