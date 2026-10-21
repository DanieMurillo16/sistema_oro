import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/garments/providers/garments_provider.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';
import 'package:sistema_oro/shared/widgets/dot_separated_text.dart';
import 'package:sistema_oro/shared/widgets/section_card.dart';

/// Resumen de ventas y separados de la prenda: cuántas unidades y a qué
/// clientes (los más recientes primero).
class GarmentSalesCard extends ConsumerWidget {
  const GarmentSalesCard({super.key, required this.garmentId});

  final int garmentId;

  static const _shown = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(garmentSalesProvider(garmentId));
    final textTheme = Theme.of(context).textTheme;
    if (sales.orders.isEmpty) {
      return SectionCard(
        title: 'Ventas',
        child: Text('Aún no se ha vendido.', style: textTheme.bodySmall),
      );
    }
    final units = sales.units;
    final more = sales.orders.length - _shown;
    return SectionCard(
      title: 'Ventas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${units == 1 ? '1 unidad' : '$units unidades'} en '
            '${sales.orders.length == 1 ? '1 pedido' : '${sales.orders.length} pedidos'}',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          for (final order in sales.orders.take(_shown)) _SaleRow(order: order),
          if (more > 0)
            Padding(
              padding: const EdgeInsets.only(top: DesignTokens.spaceXs),
              child: Text('y $more más en Pedidos', style: textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}

class _SaleRow extends StatelessWidget {
  const _SaleRow({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => context.go(
      order.isLayaway
          ? AppRoutes.layaway(
              order.id,
              from: AppRoutes.garment(order.garmentId),
            )
          : AppRoutes.order(order.id, from: AppRoutes.garment(order.garmentId)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.clientLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                DotSeparatedText(
                  parts: [
                    order.type.label,
                    order.quantityLabel,
                    order.createdLabel,
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: DesignTokens.spaceSm),
          Text(
            order.status.label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    ),
  );
}
