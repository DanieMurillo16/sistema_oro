import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/theme/status_colors.dart';
import 'package:sistema_oro/features/orders/models/order_detail.dart';
import 'package:sistema_oro/features/orders/providers/order_counters_provider.dart';
import 'package:sistema_oro/features/orders/providers/order_filters_provider.dart';
import 'package:sistema_oro/features/orders/utils/order_rules.dart';
import 'package:sistema_oro/shared/widgets/app_toggle_option.dart';
import 'package:sistema_oro/shared/widgets/kpi_cards_row.dart';
import 'package:sistema_oro/shared/widgets/list_filter_bar.dart';

/// Indicadores, búsqueda y pestañas de la pantalla de pedidos.
class OrdersHeader extends ConsumerWidget {
  const OrdersHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counters =
        ref.watch(orderCountersProvider).value ?? OrderCounters.empty;
    final filter = ref.watch(ordersFilterProvider);
    // Los indicadores repiten las pestañas: en teléfono y con el teclado
    // abierto se esconden para dejarle el sitio a la lista.
    final showKpis =
        MediaQuery.sizeOf(context).width >= DesignTokens.compactLayoutWidth &&
        MediaQuery.viewInsetsOf(context).bottom == 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showKpis) ...[
          KpiCardsRow(
            gridOnPhone: true,
            cards: [
              KpiCardData(
                title: 'Por revisar',
                text: counters.pendingText,
                icon: Icons.pending_actions_outlined,
                color: statusColor(context, StatusTone.warning),
              ),
              KpiCardData(
                title: 'Separados activos',
                text: counters.activeLayawaysText,
                icon: Icons.bookmark_border,
                color: statusColor(context, StatusTone.info),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceMd),
        ],
        ListFilterBar<OrdersTab>(
          hint: 'Buscar cliente, prenda o código',
          selected: filter.tab,
          options: [
            for (final tab in OrdersTab.values)
              AppToggleOption(value: tab, label: tab.label),
          ],
          onSelected: ref.read(ordersFilterProvider.notifier).selectTab,
          onSearch: ref.read(ordersFilterProvider.notifier).search,
        ),
      ],
    );
  }
}
