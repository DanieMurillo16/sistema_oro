import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/features/clients/models/client.dart';
import 'package:sistema_oro/features/clients/widgets/client_order_tile.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';
import 'package:sistema_oro/shared/widgets/section_card.dart';

/// Todos los pedidos y separados del cliente; tocar uno abre su detalle.
class ClientHistoryCard extends StatelessWidget {
  const ClientHistoryCard({
    super.key,
    required this.history,
    required this.from,
  });

  final List<ClientOrder> history;

  /// La ficha del cliente: a ella vuelve la flecha «atrás» del pedido.
  final String from;

  @override
  Widget build(BuildContext context) => SectionCard(
    title: 'Pedidos y separados',
    child: history.isEmpty
        ? Text(
            'Aún no tiene pedidos.',
            style: Theme.of(context).textTheme.bodySmall,
          )
        : Column(
            children: [
              for (final order in history)
                ClientOrderTile(
                  key: ValueKey(order.id),
                  order: order,
                  onTap: () => context.go(
                    order.type == OrderType.layaway
                        ? AppRoutes.layaway(order.id, from: from)
                        : AppRoutes.order(order.id, from: from),
                  ),
                ),
            ],
          ),
  );
}
