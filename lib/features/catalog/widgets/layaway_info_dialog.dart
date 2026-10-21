import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/models/checkout_draft.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';
import 'package:sistema_oro/features/catalog/widgets/checkout/checkout_dialog.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';

/// «Reservar» desde la tarjeta: primero explica cómo funciona el separado (cuánto
/// se paga hoy, el saldo y el plazo) y, si la persona quiere seguir, abre el
/// formulario de separar.
Future<void> showLayawayInfo(BuildContext context, CatalogGarment garment) =>
    showDialog<void>(
      context: context,
      builder: (_) => LayawayInfoDialog(
        garment: garment,
        onContinue: () {
          if (!context.mounted) return;
          showDialog<void>(
            context: context,
            builder: (_) =>
                CheckoutDialog(garment: garment, kind: RequestKind.layaway),
          );
        },
      ),
    );

class LayawayInfoDialog extends ConsumerWidget {
  const LayawayInfoDialog({
    super.key,
    required this.garment,
    required this.onContinue,
  });

  final CatalogGarment garment;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(catalogSettingsProvider).value;
    final percent = settings?.layawayPercent ?? 20;
    final surcharge = settings?.monthlySurcharge ?? 0;
    final textTheme = Theme.of(context).textTheme;
    return AppDialog(
      header: DialogHeader(
        icon: Icons.bookmark_border,
        title: 'Reservar con el ${percent.round()} %',
        subtitle: garment.nameLabel,
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _Figure(
                  'Pagas hoy',
                  formatCop(garment.depositFor(percent)),
                ),
              ),
              Expanded(
                child: _Figure(
                  'Saldo para abonar',
                  formatCop(garment.balanceFor(percent)),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          const _Point(
            Icons.bookmark_added_outlined,
            'La apartamos a tu nombre y sale del catálogo.',
          ),
          const _Point(
            Icons.payments_outlined,
            'Completas el saldo con abonos, del valor que quieras.',
          ),
          _Point(
            Icons.event_outlined,
            surcharge > 0
                ? 'Tienes 1 mes. Si pasa, se suma ${formatCop(surcharge)} '
                      'al saldo por cada mes vencido.'
                : 'Tienes 1 mes para completar el pago.',
          ),
          Text(
            'Barón revisa tu comprobante y te confirma por WhatsApp.',
            style: textTheme.bodySmall,
          ),
        ],
      ),
      actions: DialogActions(
        onConfirm: () {
          Navigator.of(context).pop();
          onContinue();
        },
        confirmLabel: 'Continuar',
        confirmIcon: Icons.arrow_forward_rounded,
        cancelLabel: 'Cerrar',
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodySmall),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: textTheme.titleLarge),
        ),
      ],
    );
  }
}

class _Point extends StatelessWidget {
  const _Point(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppCatalogColors.goldText),
        const SizedBox(width: DesignTokens.spaceSm),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    ),
  );
}
