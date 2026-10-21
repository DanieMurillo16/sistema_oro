import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/features/orders/providers/order_detail_provider.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/app_error_view.dart';
import 'package:sistema_oro/shared/widgets/app_loader.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';

/// El comprobante de un pago: se descarga con el Bearer y se puede ampliar.
class ReceiptDialog extends ConsumerWidget {
  const ReceiptDialog({super.key, required this.file});

  final String file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipt = ref.watch(receiptProvider(file));
    return AppDialog(
      header: const DialogHeader(
        icon: Icons.receipt_outlined,
        title: 'Comprobante',
      ),
      scrollContent: false,
      content: receipt.when(
        skipLoadingOnReload: true,
        skipLoadingOnRefresh: true,
        loading: () => const SizedBox(
          height: DesignTokens.receiptLoaderHeight,
          child: AppLoader(),
        ),
        error: (error, _) => AppErrorView(
          message: userErrorMessage(error),
          onRetry: () => ref.invalidate(receiptProvider(file)),
        ),
        data: (bytes) => ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: DesignTokens.receiptMaxHeight,
          ),
          child: InteractiveViewer(
            child: Image.memory(bytes, fit: BoxFit.contain),
          ),
        ),
      ),
      actions: DialogActions(
        onConfirm: () => Navigator.of(context).pop(),
        confirmLabel: 'Cerrar',
        confirmIcon: null,
        showCancel: false,
      ),
    );
  }
}
