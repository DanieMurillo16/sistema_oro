import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/network/api_client.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';
import 'package:sistema_oro/core/utils/json_helpers.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/models/order_detail.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => OrdersRepository(ref.watch(apiClientProvider)),
);

class OrdersRepository {
  const OrdersRepository(this._api);

  final ApiClient _api;

  static const _pageSize = 200;
  static const _maxPages = 25;

  /// Todos los pedidos: se pide por páginas de 200 y se guarda todo para
  /// buscar y filtrar localmente.
  Future<List<Order>> fetchAll({int? clientId}) async {
    final orders = <Order>[];
    for (var page = 0; page < _maxPages; page++) {
      final result = await _api.getPage(
        ApiEndpoints.ordersList,
        queryParameters: {
          'limite': _pageSize,
          'desplazamiento': orders.length,
          'id_cliente': ?clientId,
        },
      );
      orders.addAll(jsonMapList(result.items).map(Order.fromJson));
      if (result.items.length < _pageSize || orders.length >= result.total) {
        break;
      }
    }
    return orders;
  }

  Future<OrderDetail> getDetail(int id) async => OrderDetail.fromJson(
    await _api.get(ApiEndpoints.ordersGet, queryParameters: {'id': id}),
  );

  Future<OrderCounters> counters() async =>
      OrderCounters.fromJson(await _api.get(ApiEndpoints.ordersCounters));

  /// Bytes del comprobante (privado: exige el Bearer).
  Future<Uint8List> receipt(String file) => _api.getBytes(
    ApiEndpoints.ordersReceipt,
    queryParameters: {'archivo': file},
  );

  /// Devuelve lo que contesta el servidor (p. ej. `monto_a_devolver`).
  Future<Map<String, dynamic>> confirm(int id) =>
      _api.post(ApiEndpoints.ordersConfirm, data: {'id': id});

  Future<Map<String, dynamic>> reject(int id, String reason) =>
      _api.post(ApiEndpoints.ordersReject, data: {'id': id, 'motivo': reason});

  Future<Map<String, dynamic>> cancel(
    int id, {
    required CancelDecision decision,
    required String reason,
    String? returnedAmount,
  }) => _api.post(
    ApiEndpoints.ordersCancel,
    data: {
      'id': id,
      'decision': decision.api,
      'monto_devuelto': ?returnedAmount,
      'motivo': reason,
    },
  );

  Future<Map<String, dynamic>> ship(int id, {String? tracking}) =>
      _api.post(ApiEndpoints.ordersShip, data: {'id': id, 'guia': ?tracking});

  Future<Map<String, dynamic>> deliver(int id) =>
      _api.post(ApiEndpoints.ordersDeliver, data: {'id': id});

  Future<Map<String, dynamic>> editDelivery(
    int id, {
    required DeliveryType delivery,
    String? city,
    String? address,
  }) => _api.post(
    ApiEndpoints.ordersEditDelivery,
    data: {
      'id': id,
      'entrega': delivery.api,
      'ciudad': ?city,
      'direccion': ?address,
    },
  );
}
