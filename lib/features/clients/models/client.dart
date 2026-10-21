import 'package:sistema_oro/core/utils/json_helpers.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';

/// Un cliente en la lista, con sus totales ya calculados por el servidor.
class Client {
  const Client({
    required this.id,
    required this.name,
    required this.whatsapp,
    required this.createdAt,
    required this.orders,
    required this.activeLayaways,
    required this.totalPaid,
    required this.pendingBalance,
    this.notes,
    this.history = const [],
  });

  factory Client.fromJson(Map<String, dynamic> json) => Client(
    id: jsonInt(json['id_cliente']),
    name: jsonString(json['nombre']),
    whatsapp: jsonString(json['whatsapp']),
    createdAt: jsonDateOrNull(json['creado_en']),
    orders: json['pedidos'] is List
        ? (json['pedidos'] as List).length
        : jsonInt(json['pedidos']),
    activeLayaways: jsonInt(json['separados_activos']),
    totalPaid: jsonDecimal(json['total_pagado']),
    pendingBalance: jsonDecimal(json['saldo_pendiente']),
    notes: jsonStringOrNull(json['notas']),
    history: jsonMapList(json['pedidos'] is List ? json['pedidos'] : null)
        .map(ClientOrder.fromJson)
        .toList(),
  );

  final int id;
  final String name;
  final String whatsapp;
  final DateTime? createdAt;
  final int orders;
  final int activeLayaways;
  final double totalPaid;
  final double pendingBalance;
  final String? notes;

  /// Solo en la ficha (`clientes/obtener.php`): sus pedidos y separados.
  final List<ClientOrder> history;
}

/// Un pedido en la ficha de un cliente.
class ClientOrder {
  const ClientOrder({
    required this.id,
    required this.code,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.garment,
    required this.total,
    required this.paid,
    required this.balance,
    required this.monthsOverdue,
    required this.deadline,
  });

  factory ClientOrder.fromJson(Map<String, dynamic> json) => ClientOrder(
    id: jsonInt(json['id_pedido']),
    code: jsonString(json['codigo']),
    type: OrderType.fromApi(jsonStringOrNull(json['tipo'])),
    status: OrderStatus.fromApi(jsonStringOrNull(json['estado'])),
    createdAt: jsonDateOrNull(json['creado_en']),
    garment: jsonString(json['prenda']),
    total: jsonDecimal(json['total_a_pagar']),
    paid: jsonDecimal(json['total_pagado']),
    balance: jsonDecimal(json['saldo']),
    monthsOverdue: jsonInt(json['meses_vencidos']),
    deadline: jsonDateOrNull(json['fecha_limite']),
  );

  final int id;
  final String code;
  final OrderType type;
  final OrderStatus status;
  final DateTime? createdAt;
  final String garment;
  final double total;
  final double paid;
  final double balance;
  final int monthsOverdue;
  final DateTime? deadline;
}
