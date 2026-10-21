import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/summary/models/monthly_summary.dart';
import 'package:sistema_oro/features/summary/providers/summary_provider.dart';
import 'package:sistema_oro/features/summary/widgets/summary_kpis.dart';
import 'package:sistema_oro/features/summary/widgets/summary_month_selector.dart';
import 'package:sistema_oro/features/summary/widgets/summary_sections.dart';
import 'package:sistema_oro/shared/widgets/app_async_view.dart';
import 'package:sistema_oro/shared/widgets/page_body.dart';

/// Resumen del negocio por mes: ventas, abonos, por cobrar, separados, clientes
/// e inventario. Primera pestaña del menú.
class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(balancesHiddenProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Resumen')),
      body: PageBody(
        child: AppAsyncView<MonthlySummary?>(
          state: ref.watch(summaryProvider),
          isEmpty: (summary) => summary == null,
          onRetry: () => ref.invalidate(summaryProvider),
          emptyIcon: Icons.insights_outlined,
          emptyTitle: 'Sin resumen',
          emptyMessage: 'Tu usuario no tiene permiso para ver el resumen.',
          builder: (summary) => ListView(
            padding: DesignTokens.pagePaddingFor(
              MediaQuery.sizeOf(context).width,
            ),
            children: [
              const SummaryMonthSelector(),
              const SizedBox(height: DesignTokens.spaceMd),
              SummaryKpis(summary: summary!, hidden: hidden),
              const SizedBox(height: DesignTokens.spaceMd),
              SummarySections(summary: summary, hidden: hidden),
            ],
          ),
        ),
      ),
    );
  }
}
