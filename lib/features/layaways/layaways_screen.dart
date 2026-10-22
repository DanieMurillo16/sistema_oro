import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/features/layaways/widgets/layaways_header.dart';
import 'package:sistema_oro/features/layaways/widgets/layaways_tabs_bar.dart';
import 'package:sistema_oro/features/layaways/widgets/reminder_tile.dart';
import 'package:sistema_oro/features/orders/utils/order_rules.dart';
import 'package:sistema_oro/features/orders/providers/order_filters_provider.dart';
import 'package:sistema_oro/features/orders/providers/orders_provider.dart';
import 'package:sistema_oro/features/orders/widgets/order_tile.dart';
import 'package:sistema_oro/shared/widgets/app_async_view.dart';
import 'package:sistema_oro/shared/widgets/list_header_padding.dart';
import 'package:sistema_oro/shared/widgets/page_body.dart';
import 'package:sistema_oro/shared/widgets/responsive_cards.dart';

/// Separados: saldo, fecha límite y meses vencidos de cada prenda apartada.
class LayawaysScreen extends ConsumerWidget {
  const LayawaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layaways = ref.watch(filteredLayawaysProvider);
    final tab = ref.watch(layawaysFilterProvider).tab;
    return Scaffold(
      appBar: AppBar(title: const Text('Separados')),
      bottomNavigationBar: const LayawaysTabsBar(),
      body: PageBody(
        child: Column(
          children: [
            const ListHeaderPadding(child: LayawaysHeader()),
            Expanded(
              child: AppAsyncView(
                state: ref.watch(ordersProvider),
                isEmpty: (_) => layaways.isEmpty,
                onRetry: () => ref.invalidate(ordersProvider),
                emptyIcon: Icons.bookmark_border,
                emptyTitle: 'Sin separados',
                emptyMessage: 'No hay separados que coincidan con este filtro.',
                builder: (_) => ResponsiveCards(
                  itemCount: layaways.length,
                  itemBuilder: (context, index) {
                    final order = layaways[index];
                    void open() => context.go(AppRoutes.layaway(order.id));
                    return tab == LayawaysTab.remind
                        ? ReminderTile(
                            key: ValueKey(order.id),
                            order: order,
                            onTap: open,
                          )
                        : OrderTile(
                            key: ValueKey(order.id),
                            order: order,
                            onTap: open,
                          );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
