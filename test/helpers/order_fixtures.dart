import 'package:sistema_oro/core/network/api_endpoints.dart';

import '../support/api_harness.dart';
import '../support/fake_api_adapter.dart';

// JSON copiado de la forma que documenta backend/docs/API.md (dinero como texto).

/// Permisos del dueño (todo lo de pedidos y pagos).
const ownerPermissions = [
  'pedidos.ver',
  'pedidos.revisar',
  'pedidos.entregar',
  'pedidos.cancelar',
  'pagos.registrar',
  'pagos.anular',
  'clientes.ver',
];

/// Permisos del empleado: ver pedidos y registrar abonos.
const employeePermissions = ['pedidos.ver', 'pagos.registrar', 'clientes.ver'];

Map<String, dynamic> profileJson(List<String> permissions) => {
  'success': true,
  'data': {
    'perfil': {
      'id_usuario': 1,
      'nombre_completo': 'barón joyero',
      'usuario': 'baron',
      'rol': 'ADMINISTRADOR',
    },
    'permisos': permissions,
  },
};

Map<String, dynamic> orderRow({
  int id = 7,
  String code = 'AB12CD34',
  String type = 'COMPRA',
  String status = 'PENDIENTE',
  String client = 'juan pérez',
  String garment = 'cadena cubana',
  String total = '1012000.00',
  String paid = '1012000.00',
  String balance = '0.00',
  int overdue = 0,
  String? deadline,
}) => {
  'id_pedido': id,
  'codigo': code,
  'tipo': type,
  'estado': status,
  'cantidad': 1,
  'entrega_tipo': 'RECOGE',
  'creado_en': '2026-10-19 10:00:00',
  'id_cliente': 3,
  'cliente': client,
  'whatsapp': '573001234567',
  'id_prenda': 11,
  'prenda': garment,
  'referencia': 'CAD-11',
  'miniatura': null,
  'total_a_pagar': total,
  'total_pagado': paid,
  'saldo': balance,
  'meses_vencidos': overdue,
  'fecha_limite': deadline,
};

Map<String, dynamic> orderDetailJson(
  Map<String, dynamic> row, {
  List<Map<String, dynamic>> payments = const [],
  Map<String, dynamic>? cancellation,
}) => {
  'success': true,
  'data': {
    'pedido': {
      ...row,
      'precio_unitario': '1000000.00',
      'caja': 'DECORADA',
      'precio_caja': '12000.00',
      'porcentaje_separado': '20.00',
      'recargo_mes': '80000.00',
      'ciudad': null,
      'direccion': null,
      'guia_envio': null,
      'plazo_desde': null,
      'pagado_en': null,
      'revisado_en': null,
      'motivo_rechazo': null,
      'entregado_en': null,
      'nota_interna': null,
      'imagen': null,
      'subtotal': '1000000.00',
      'recargos': '0.00',
      'monto_separado_minimo': '200000.00',
    },
    'pagos': payments,
    'cancelacion': cancellation,
  },
};

Map<String, dynamic> paymentRow({
  int id = 1,
  String amount = '200000.00',
  bool initial = true,
  String? receipt = 'comp_1.jpg',
  String? banco,
}) => {
  'id_pago': id,
  'monto': amount,
  'fecha_pago': '2026-10-19',
  'medio': 'TRANSFERENCIA',
  'comprobante': receipt,
  'banco': banco,
  'es_inicial': initial,
  'origen': 'CLIENTE',
  'estado': 'VIGENTE',
  'registrado_por': null,
  'motivo_anulacion': null,
  'anulado_en': null,
};

Map<String, dynamic> listJson(List<Map<String, dynamic>> rows) => {
  'success': true,
  'data': rows,
  'meta': {'total': rows.length, 'limite': 200, 'desplazamiento': 0},
};

Map<String, dynamic> okJson(Map<String, dynamic> data) => {
  'success': true,
  'data': data,
};

Map<String, dynamic> countersJson({int pending = 1}) => okJson({
  'pendientes': pending,
  'separados_activos': 1,
  'separados_vencidos': 0,
});

/// Un servidor falso de pedidos: guarda las filas y responde por ruta. Las
/// escrituras que la prueba programa en [writes] cambian lo que responde.
class OrdersServer {
  OrdersServer({
    this.permissions = ownerPermissions,
    List<Map<String, dynamic>>? rows,
  }) : rows = rows ?? [orderRow()];

  final List<String> permissions;
  final List<Map<String, dynamic>> rows;
  List<Map<String, dynamic>> payments = [];
  Map<String, dynamic>? cancellation;

  /// Respuesta por ruta de escritura: `(options) => {data}`.
  final Map<String, Map<String, dynamic> Function()> writes = {};

  late final ApiHarness harness = ApiHarness(
    FakeApiAdapter((o) async {
      final write = writes[o.path];
      if (write != null) {
        return FakeApiAdapter.jsonResponse(okJson(write()), 200);
      }
      return switch (o.path) {
        ApiEndpoints.profile => FakeApiAdapter.jsonResponse(
          profileJson(permissions),
          200,
        ),
        ApiEndpoints.ordersCounters => FakeApiAdapter.jsonResponse(
          countersJson(),
          200,
        ),
        ApiEndpoints.ordersList => FakeApiAdapter.jsonResponse(
          listJson(rows),
          200,
        ),
        ApiEndpoints.ordersGet => FakeApiAdapter.jsonResponse(
          orderDetailJson(
            rows.firstWhere(
              (r) => r['id_pedido'].toString() == '${o.queryParameters['id']}',
            ),
            payments: payments,
            cancellation: cancellation,
          ),
          200,
        ),
        _ => FakeApiAdapter.jsonResponse({
          'success': false,
          'codigo': 'NO_ENCONTRADO',
          'error': 'Ruta de prueba no programada: ${o.path}',
        }, 404),
      };
    }),
  );
}
