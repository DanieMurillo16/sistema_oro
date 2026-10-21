import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/orders/utils/order_rules.dart';

/// El botón de una acción de la barra del pedido: principal (relleno) o
/// secundario, y en rojo si es rechazar o cancelar.
class OrderActionButton extends StatelessWidget {
  const OrderActionButton({
    super.key,
    required this.action,
    required this.onPressed,
  });

  final OrderAction action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final (label, icon, primary) = switch (action) {
      OrderAction.confirm => ('Confirmar', Icons.check_circle_outline, true),
      OrderAction.registerPayment => (
        'Registrar abono',
        Icons.payments_outlined,
        true,
      ),
      OrderAction.ship => (
        'Marcar enviado',
        Icons.local_shipping_outlined,
        false,
      ),
      OrderAction.deliver => (
        'Marcar entregado',
        Icons.inventory_2_outlined,
        false,
      ),
      OrderAction.reject => ('Rechazar', Icons.close_rounded, false),
      OrderAction.cancel => ('Cancelar pedido', Icons.cancel_outlined, false),
    };
    final destructive =
        action == OrderAction.reject || action == OrderAction.cancel;
    final scheme = Theme.of(context).colorScheme;
    // Pequeños y con sombra suave: flotan sobre el contenido.
    final shape = StadiumBorder(
      side: primary
          ? BorderSide.none
          : BorderSide(color: destructive ? scheme.error : scheme.outline),
    );
    final style = FilledButton.styleFrom(
      minimumSize: const Size(0, 38),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd),
      textStyle: Theme.of(context).textTheme.labelMedium,
      elevation: 4,
      shadowColor: Colors.black,
      shape: shape,
      backgroundColor: primary ? null : scheme.surface,
      foregroundColor: primary
          ? null
          : (destructive ? scheme.error : scheme.onSurface),
    );
    return FilledButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon, size: DesignTokens.iconSm),
      label: Text(label),
    );
  }
}
