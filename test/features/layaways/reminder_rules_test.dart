import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/utils/garment_sales.dart';
import 'package:sistema_oro/features/garments/utils/garment_summary.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';
import 'package:sistema_oro/features/orders/utils/order_rules.dart';

import '../../helpers/garment_fixtures.dart';
import '../../helpers/order_fixtures.dart';

Order _layaway(int id, {String? lastPayment, String status = 'ACTIVO'}) =>
    Order.fromJson({
      ...orderRow(
        id: id,
        type: 'SEPARADO',
        status: status,
        client: 'cliente $id',
        balance: '${id * 100000}.00',
      ),
      'ultimo_pago': lastPayment,
    });

void main() {
  final now = DateTime(2026, 10, 20, 15);

  group('Recordar', () {
    test('ordena por más días sin abonar; sin fecha de pago cuenta desde el pedido', () {
      final orders = [
        _layaway(1, lastPayment: '2026-10-18'), // 2 días
        _layaway(2, lastPayment: '2026-09-10'), // 40 días
        _layaway(3), // sin ultimo_pago: desde creado_en 2026-10-19 → 1 día
        _layaway(4, lastPayment: '2026-10-01', status: 'PAGADO'), // no cuenta
      ];
      final list = OrderRules.forLayawaysTab(
        orders,
        LayawaysTab.remind,
        '',
        now: now,
      );
      expect(list.map((o) => o.id), [2, 1, 3]);
      expect(OrderRules.daysWithoutPayment(orders[1], now), 40);
      expect(OrderRules.daysWithoutPayment(orders[2], now), 1);
    });

    test(
      'hoy no es un día negativo y el mensaje es amable y trae el saldo',
      () {
        final order = _layaway(5, lastPayment: '2026-10-20');
        expect(OrderRules.daysWithoutPayment(order, now), 0);
        expect(idleDaysLabel(0), 'Abonó hoy');
        expect(idleDaysLabel(1), 'Hace 1 día sin abonar');
        expect(idleDaysLabel(12), 'Hace 12 días sin abonar');
        expect(order.reminderMessage, contains('Cliente 5'));
        expect(order.reminderMessage, contains(r'$ 500.000'));
        expect(order.reminderMessage, contains('cuando te quede cómodo'));
      },
    );
  });

  test('el pedido abierto desde una ficha recuerda a dónde volver', () {
    expect(AppRoutes.order(7), '/pedidos/7');
    expect(
      AppRoutes.order(7, from: AppRoutes.client(3)),
      '/pedidos/7?from=%2Fclientes%2F3',
    );
    expect(
      Uri.parse(AppRoutes.layaway(7, from: '/clientes/3'))
          .queryParameters['from'],
      '/clientes/3',
    );
  });

  group('prendas', () {
    test('el resumen suma prendas, unidades, peso y valor por su stock', () {
      final garments = [
        Garment.fromJson(garmentRow(id: 1, stock: 2)),
        Garment.fromJson(garmentRow(id: 2, stock: 3)),
        Garment.fromJson(garmentRow(id: 3, stock: 0)),
      ];
      final summary = GarmentSummary.of(garments);
      expect(summary.garments, 3);
      expect(summary.units, 5);
      expect(summary.grams, closeTo(26, 0.001)); // 5,2 g × 5 unidades
      expect(summary.value, 5000000); // 1.000.000 × 5
    });

    test('las ventas cuentan lo confirmado y separado, no lo rechazado ni pendiente', () {
      final orders = [
        _layaway(1),
        Order.fromJson(orderRow(id: 2, status: 'ENTREGADO')),
        Order.fromJson(orderRow(id: 3, status: 'RECHAZADO')),
        Order.fromJson(orderRow(id: 4, status: 'PENDIENTE')),
        Order.fromJson({
          ...orderRow(id: 5, status: 'ENTREGADO'),
          'id_prenda': 99,
        }),
      ];
      final sales = GarmentSales.of(orders, 11);
      expect(sales.orders.map((o) => o.id).toSet(), {1, 2});
      expect(sales.units, 2);
    });
  });
}
