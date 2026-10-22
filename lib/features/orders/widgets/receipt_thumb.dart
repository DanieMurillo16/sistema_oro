import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/orders/providers/order_detail_provider.dart';
import 'package:sistema_oro/features/orders/widgets/dialogs/receipt_dialog.dart';

/// Miniatura del comprobante en la tarjeta del pedido; al tocarla abre el
/// visor con zoom. Mientras baja muestra un cuadro tenue con el icono y, si
/// falla, el mismo cuadro con un icono de imagen rota (el visor reintenta).
class ReceiptThumb extends ConsumerWidget {
  const ReceiptThumb({super.key, required this.file});

  final String file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final thumb = ref.watch(receiptThumbProvider(file));
    final placeholder = ColoredBox(
      color: scheme.surfaceContainerHigh,
      child: Icon(
        thumb.hasError
            ? Icons.broken_image_outlined
            : Icons.receipt_long_outlined,
        size: DesignTokens.iconSm,
        color: scheme.onSurfaceVariant,
      ),
    );
    return Semantics(
      button: true,
      label: 'Ver comprobante',
      child: Tooltip(
        message: 'Ver comprobante',
        child: InkWell(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          onTap: () async {
            await showDialog<void>(
              context: context,
              builder: (_) => ReceiptDialog(file: file),
            );
            // Si la miniatura había fallado, se vuelve a intentar al volver.
            if (thumb.hasError) ref.invalidate(receiptThumbProvider(file));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            child: SizedBox.square(
              dimension: DesignTokens.receiptThumbSize,
              child: thumb.maybeWhen(
                data: (bytes) => Image.memory(
                  bytes,
                  fit: BoxFit.cover,
                  cacheWidth: (DesignTokens.receiptThumbSize * 2).round(),
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) => placeholder,
                ),
                orElse: () => placeholder,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
