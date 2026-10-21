import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/status_colors.dart';
import 'package:sistema_oro/features/summary/models/monthly_summary.dart';
import 'package:sistema_oro/shared/widgets/kpi_cards_row.dart';

/// Las cifras grandes del mes: ventas, abonos, por cobrar y, solo con permiso
/// de ver costos, la ganancia estimada. En teléfono van en cuadrícula de dos.
class SummaryKpis extends StatelessWidget {
  const SummaryKpis({super.key, required this.summary, required this.hidden});

  final MonthlySummary summary;
  final bool hidden;

  @override
  Widget build(BuildContext context) => KpiCardsRow(
    gridOnPhone: true,
    cards: [
      KpiCardData(
        title: 'Ventas del mes',
        icon: Icons.shopping_bag_outlined,
        color: statusColor(context, StatusTone.success),
        amount: summary.salesAmount,
        hidden: hidden,
      ),
      KpiCardData(
        title: 'Abonos recibidos',
        icon: Icons.payments_outlined,
        color: statusColor(context, StatusTone.info),
        amount: summary.paymentsAmount,
        hidden: hidden,
      ),
      KpiCardData(
        title: 'Por cobrar',
        icon: Icons.account_balance_wallet_outlined,
        color: statusColor(context, StatusTone.warning),
        amount: summary.receivable,
        hidden: hidden,
      ),
      if (summary.canSeeProfit)
        KpiCardData(
          title: 'Ganancia estimada',
          icon: Icons.trending_up_rounded,
          color: statusColor(context, StatusTone.success),
          amount: summary.estimatedProfit,
          hidden: hidden,
        ),
    ],
  );
}
