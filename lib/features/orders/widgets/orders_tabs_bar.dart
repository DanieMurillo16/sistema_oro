import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/orders/providers/order_filters_provider.dart';
import 'package:sistema_oro/features/orders/utils/order_rules.dart';
import 'package:sistema_oro/shared/widgets/app_toggle_option.dart';
import 'package:sistema_oro/shared/widgets/bottom_toggle_bar.dart';

/// Pestañas de Pedidos (Por revisar · Compras · Todos), al pie de la pantalla.
class OrdersTabsBar extends ConsumerWidget {
  const OrdersTabsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      BottomToggleBar<OrdersTab>(
        selected: ref.watch(ordersFilterProvider.select((f) => f.tab)),
        options: [
          for (final tab in OrdersTab.values)
            AppToggleOption(value: tab, label: tab.label),
        ],
        onSelected: ref.read(ordersFilterProvider.notifier).selectTab,
      );
}
