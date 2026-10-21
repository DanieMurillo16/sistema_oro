import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/core/services/link_launcher.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';
import 'package:sistema_oro/shared/widgets/app_action_button.dart';

/// Quién hizo el pedido: abre su ficha (con permiso) y su WhatsApp.
class OrderClientRow extends ConsumerWidget {
  const OrderClientRow({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final canClients = ref.watch(canProvider(Permissions.clientsView));
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: canClients
                ? () => context.go(AppRoutes.client(order.clientId))
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.clientLabel, style: textTheme.titleSmall),
                Text(order.whatsapp, style: textTheme.bodySmall),
              ],
            ),
          ),
        ),
        AppActionButton(
          icon: Icons.chat_outlined,
          tooltip: 'Escribir por WhatsApp',
          onPressed: () => ref
              .read(linkLauncherProvider)
              .openWhatsApp(order.whatsapp, message: order.whatsappMessage),
        ),
      ],
    );
  }
}
