import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/features/orders/providers/order_counters_provider.dart';
import 'package:sistema_oro/features/orders/providers/order_filters_provider.dart';
import 'package:sistema_oro/features/orders/providers/orders_provider.dart';
import 'package:sistema_oro/features/orders/widgets/order_tile.dart';
import 'package:sistema_oro/features/orders/widgets/orders_header.dart';
import 'package:sistema_oro/shared/widgets/app_async_view.dart';
import 'package:sistema_oro/shared/widgets/list_header_padding.dart';
import 'package:sistema_oro/shared/widgets/page_body.dart';
import 'package:sistema_oro/shared/widgets/responsive_cards.dart';

/// Pedidos y solicitudes: lo que Barón revisa, confirma o rechaza.
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  late final OrdersScreenVisibleNotifier _visible;

  @override
  void initState() {
    super.initState();
    _visible = ref.read(ordersScreenVisibleProvider.notifier);
    Future.microtask(() => _visible.set(true));
  }

  @override
  void dispose() {
    Future.microtask(() => _visible.set(false));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(filteredOrdersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      body: PageBody(
        child: Column(
          children: [
            const ListHeaderPadding(child: OrdersHeader()),
            Expanded(
              child: AppAsyncView(
                state: ref.watch(ordersProvider),
                isEmpty: (_) => orders.isEmpty,
                onRetry: () => ref.invalidate(ordersProvider),
                emptyIcon: Icons.receipt_long_outlined,
                emptyTitle: 'Sin pedidos',
                emptyMessage: 'No hay pedidos que coincidan con este filtro.',
                builder: (_) => ResponsiveCards(
                  itemCount: orders.length,
                  itemBuilder: (context, index) => OrderTile(
                    key: ValueKey(orders[index].id),
                    order: orders[index],
                    onTap: () => context.go(AppRoutes.order(orders[index].id)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
