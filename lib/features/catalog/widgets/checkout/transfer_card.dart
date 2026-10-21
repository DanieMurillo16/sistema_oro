import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_oro/core/services/app_toast.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/shared/widgets/info_row.dart';

/// Los datos para transferir (banco, cuenta, titular) y cuánto transferir. La
/// cuenta se copia con un toque.
class TransferCard extends StatelessWidget {
  const TransferCard({super.key, required this.settings, required this.amount});

  final CatalogSettings settings;

  /// Lo que hay que transferir (compra: el total; separado: el mínimo).
  final int amount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Transfiere a', style: Theme.of(context).textTheme.titleSmall),
            if (settings.bank.isNotEmpty)
              InfoRow(label: 'Banco', value: settings.bank),
            if (settings.account.isNotEmpty)
              InfoRow(label: 'Cuenta', value: settings.account),
            if (settings.holder.isNotEmpty)
              InfoRow(label: 'Titular', value: settings.holder),
            InfoRow(label: 'Valor', value: formatCop(amount), strong: true),
            if (settings.transferNote.isNotEmpty)
              Text(
                settings.transferNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (settings.account.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: settings.account),
                    );
                    AppToast.info('Número de cuenta copiado');
                  },
                  icon: const Icon(
                    Icons.copy_outlined,
                    size: DesignTokens.iconSm,
                  ),
                  label: const Text('Copiar cuenta'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
