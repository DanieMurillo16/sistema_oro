import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/theme/status_colors.dart';
import 'package:sistema_oro/features/orders/models/order_payment.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';
import 'package:sistema_oro/shared/widgets/app_action_button.dart';
import 'package:sistema_oro/shared/widgets/dot_separated_text.dart';
import 'package:sistema_oro/shared/widgets/status_chip.dart';

/// Un pago o abono: valor, fecha, medio y, si hay, comprobante y anular.
class PaymentTile extends StatelessWidget {
  const PaymentTile({
    super.key,
    required this.payment,
    this.onReceipt,
    this.onVoid,
  });

  final OrderPayment payment;
  final VoidCallback? onReceipt;
  final VoidCallback? onVoid;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: DesignTokens.spaceSm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      payment.amountLabel,
                      style: textTheme.titleSmall?.copyWith(
                        decoration: payment.voided
                            ? TextDecoration.lineThrough
                            : null,
                        color: payment.voided
                            ? textTheme.bodySmall?.color
                            : null,
                      ),
                    ),
                    if (payment.voided)
                      const StatusChip(
                        label: 'Anulado',
                        tone: StatusTone.error,
                      ),
                  ],
                ),
                DotSeparatedText(
                  parts: [
                    payment.kindLabel,
                    payment.dateLabel,
                    payment.methodLabel,
                    if (payment.bank != null) 'Banco: ${payment.bank}',
                  ],
                ),
                if (payment.voided && payment.voidReason != null)
                  Text(
                    '${payment.voidedLabel}: ${payment.voidReason}',
                    style: textTheme.bodySmall,
                  ),
                // Visible y con nombre: antes era un icono suelto que no se encontraba.
                if (onVoid != null)
                  Tooltip(
                    message: 'Anular pago',
                    child: TextButton.icon(
                      onPressed: onVoid,
                      icon: const Icon(Icons.block, size: DesignTokens.iconSm),
                      label: const Text('Anular'),
                      style: TextButton.styleFrom(
                        foregroundColor: statusColor(context, StatusTone.error),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (onReceipt != null)
            AppActionButton(
              icon: Icons.receipt_long_outlined,
              tooltip: 'Ver comprobante',
              onPressed: onReceipt,
            ),
        ],
      ),
    );
  }
}
