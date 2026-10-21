import 'package:flutter/material.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';
import 'package:sistema_oro/shared/widgets/status_chip.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status, this.prefix});

  final OrderStatus status;

  /// Texto antes del estado, p. ej. «Separado · Activo».
  final String? prefix;

  @override
  Widget build(BuildContext context) => StatusChip(
    label: prefix == null ? status.label : '$prefix · ${status.label}',
    tone: status.tone,
  );
}
