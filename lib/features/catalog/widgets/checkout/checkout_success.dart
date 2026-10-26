import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_oro/core/services/app_toast.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/theme/status_colors.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/models/checkout_draft.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';

/// Confirmación tras enviar: el código del pedido (lo único que ve el
/// público) y qué sigue.
class CheckoutSuccess extends StatelessWidget {
  const CheckoutSuccess({super.key, required this.receipt, required this.kind});

  final RequestReceipt receipt;
  final RequestKind kind;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: DesignTokens.logoSize,
          color: statusColor(context, StatusTone.success),
        ),
        const SizedBox(height: DesignTokens.spaceMd),
        Text(
          kind.successTitle,
          style: textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DesignTokens.spaceSm),
        Text('Tu código es', style: textTheme.bodySmall),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SelectableText(
                receipt.code,
                style: textTheme.headlineSmall,
              ),
            ),
            IconButton(
              tooltip: 'Copiar código',
              icon: const Icon(Icons.copy_rounded),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: receipt.code));
                AppToast.success('Código copiado');
              },
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spaceMd),
        Text(
          'Envíanos el código por WhatsApp para que revisemos tu comprobante y '
          'confirmemos más rápido. También te escribimos nosotros.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium,
        ),
        if (kind == RequestKind.layaway) ...[
          const SizedBox(height: DesignTokens.spaceMd),
          Text(
            LayawayRule.rule,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppCatalogColors.goldText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}
