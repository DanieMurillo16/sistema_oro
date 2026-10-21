import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/features/orders/models/order_detail.dart';
import 'package:sistema_oro/features/orders/providers/order_detail_provider.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';
import 'package:sistema_oro/features/orders/widgets/detail/order_actions_bar.dart';
import 'package:sistema_oro/features/orders/widgets/detail/order_detail_body.dart';
import 'package:sistema_oro/shared/widgets/app_async_view.dart';
import 'package:sistema_oro/shared/widgets/page_body.dart';

/// El detalle de un pedido o separado. [backRoute] es la lista de donde vino.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({
    super.key,
    required this.id,
    required this.backRoute,
  });

  final int id;
  final String backRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(orderDetailProvider(id));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(backRoute),
        ),
        title: Text(detail.value?.order.codeLabel ?? 'Pedido'),
      ),
      body: Stack(
        children: [
          PageBody(
            child: AppAsyncView<OrderDetail>(
              state: detail,
              isEmpty: (_) => false,
              onRetry: () => ref.invalidate(orderDetailProvider(id)),
              builder: (data) => OrderDetailBody(detail: data),
            ),
          ),
          if (detail.value != null)
            Align(
              alignment: Alignment.bottomRight,
              child: OrderActionsBar(order: detail.value!.order),
            ),
        ],
      ),
    );
  }
}
