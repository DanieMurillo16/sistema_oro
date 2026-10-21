import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/summary/models/monthly_summary.dart';
import 'package:sistema_oro/features/summary/widgets/summary_stat_row.dart';
import 'package:sistema_oro/shared/widgets/section_card.dart';

/// El detalle del mes en tarjetas: movimiento, separados, clientes e
/// inventario. Las cifras vienen del servidor; aquí solo se muestran.
class SummarySections extends StatelessWidget {
  const SummarySections({
    super.key,
    required this.summary,
    required this.hidden,
  });

  final MonthlySummary summary;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final cards = [
      SectionCard(
        title: 'Movimiento del mes',
        child: Column(
          children: [
            SummaryStatRow(
              label: 'Pedidos vendidos',
              value: summary.salesCount,
            ),
            SummaryStatRow(
              label: 'Abonos recibidos',
              value: summary.paymentsCount,
            ),
            SummaryStatRow(label: 'Clientes nuevos', value: summary.newClients),
          ],
        ),
      ),
      SectionCard(
        title: 'Separados',
        child: Column(
          children: [
            SummaryStatRow(label: 'Activos', value: summary.activeLayaways),
            SummaryStatRow(label: 'Vencidos', value: summary.overdueLayaways),
            SummaryStatRow(
              label: 'Recargos acumulados',
              value: summary.surcharges,
              money: true,
              hidden: hidden,
            ),
            SummaryStatRow(
              label: 'Vencen en los próximos 7 días',
              value: summary.dueSoonLayaways,
            ),
          ],
        ),
      ),
      SectionCard(
        title: 'Pendientes y clientes',
        child: Column(
          children: [
            SummaryStatRow(
              label: 'Solicitudes por revisar',
              value: summary.pendingRequests,
            ),
            SummaryStatRow(
              label: 'Total de clientes',
              value: summary.totalClients,
            ),
          ],
        ),
      ),
      SectionCard(
        title: 'Inventario',
        child: Column(
          children: [
            SummaryStatRow(label: 'Prendas activas', value: summary.garments),
            SummaryStatRow(label: 'Unidades', value: summary.units),
            SummaryStatRow(
              label: 'Valor a precio de venta',
              value: summary.inventoryValue,
              money: true,
              hidden: hidden,
            ),
          ],
        ),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 2 : 1;
        final width =
            (constraints.maxWidth - DesignTokens.spaceMd * (columns - 1)) /
            columns;
        return Wrap(
          spacing: DesignTokens.spaceMd,
          runSpacing: DesignTokens.spaceMd,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        );
      },
    );
  }
}
