import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';
import 'package:sistema_oro/features/orders/providers/order_counters_provider.dart';

import '../../helpers/order_fixtures.dart';
import '../../support/pump_at_sizes.dart';

Future<OrdersServer> _open(
  WidgetTester tester, {
  List<String> permissions = ownerPermissions,
  List<Map<String, dynamic>>? rows,
  double width = 390,
}) async {
  final server = OrdersServer(permissions: permissions, rows: rows);
  await pumpAdminApp(
    tester,
    width: width,
    overrides: [
      ...server.harness.overrides,
      orderRefreshIntervalProvider.overrideWithValue(null),
    ],
  );
  return server;
}

Future<void> _openFirstOrder(WidgetTester tester) async {
  await tester.tap(find.text('Juan Pérez'));
  await tester.pumpAndSettle();
}

void main() {
  group('lista de pedidos', () {
    testWidgets('muestra lo que dice el contrato y cambia de pestaña', (
      tester,
    ) async {
      final server = await _open(
        tester,
        rows: [
          orderRow(),
          orderRow(
            id: 8,
            code: 'ZZ99YY88',
            status: 'CONFIRMADO',
            client: 'ana gómez',
          ),
        ],
      );

      expect(
        server.harness.adapter.to(ApiEndpoints.ordersList).first.authorization,
        'Bearer tok',
      );
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.textContaining('Cadena cubana'), findsWidgets);
      expect(find.text(r'$ 1.012.000'), findsWidgets);
      expect(find.text('Por revisar'), findsWidgets); // KPI + chip + pestaña
      expect(find.text('Ana Gómez'), findsNothing); // no está por revisar

      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();
      expect(find.text('Ana Gómez'), findsOneWidget);
    });

    testWidgets('sin pedidos muestra el vacío', (tester) async {
      await _open(tester, rows: []);
      expect(find.text('Sin pedidos'), findsOneWidget);
    });

    testWidgets('la insignia del menú cuenta los pendientes', (tester) async {
      await _open(tester);
      expect(find.widgetWithText(Badge, '1'), findsWidgets);
    });
  });

  group('acciones sobre un pedido', () {
    testWidgets('confirmar envía el id, avisa y actualiza la lista', (
      tester,
    ) async {
      final server = OrdersServer();
      server.writes[ApiEndpoints.ordersConfirm] = () {
        server.rows[0] = orderRow(status: 'CONFIRMADO');
        return {
          'id_pedido': 7,
          'codigo': 'AB12CD34',
          'tipo': 'COMPRA',
          'estado': 'CONFIRMADO',
          'plazo_desde': null,
        };
      };
      await pumpAdminApp(
        tester,
        overrides: [
          ...server.harness.overrides,
          orderRefreshIntervalProvider.overrideWithValue(null),
        ],
      );

      await _openFirstOrder(tester);
      expect(find.text('Pedido AB12CD34'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Confirmar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Confirmar').last);
      await tester.pumpAndSettle();

      final request = server.harness.adapter
          .to(ApiEndpoints.ordersConfirm)
          .single;
      expect(request.method, 'POST');
      expect(request.authorization, 'Bearer tok');
      expect(request.bodyMap, {'id': 7});
      expect(find.text('Solicitud confirmada'), findsOneWidget);
      expect(find.text('Confirmado'), findsWidgets);
      await dismissToasts(tester);
    });

    testWidgets('rechazar exige el motivo y lo envía', (tester) async {
      final server = OrdersServer();
      server.writes[ApiEndpoints.ordersReject] = () {
        server.rows[0] = orderRow(status: 'RECHAZADO');
        return {
          'id_pedido': 7,
          'codigo': 'AB12CD34',
          'estado': 'RECHAZADO',
          'monto_a_devolver': '1012000.00',
        };
      };
      await pumpAdminApp(
        tester,
        overrides: [
          ...server.harness.overrides,
          orderRefreshIntervalProvider.overrideWithValue(null),
        ],
      );
      await _openFirstOrder(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Rechazar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Rechazar solicitud'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Cuéntanos el motivo'), findsOneWidget);
      expect(server.harness.adapter.to(ApiEndpoints.ordersReject), isEmpty);

      await tester.enterText(
        find.byKey(const Key('reject_reason')),
        'Comprobante ilegible',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Rechazar solicitud'));
      await tester.pumpAndSettle();

      final request = server.harness.adapter
          .to(ApiEndpoints.ordersReject)
          .single;
      expect(request.bodyMap, {'id': 7, 'motivo': 'Comprobante ilegible'});
      expect(find.textContaining(r'Devuelve $ 1.012.000'), findsOneWidget);
      await dismissToasts(tester);
    });

    testWidgets(
      'cancelar con devolución parcial envía la decisión y el valor',
      (tester) async {
        final server = OrdersServer(rows: [orderRow(status: 'CONFIRMADO')]);
        server.writes[ApiEndpoints.ordersCancel] = () {
          server.rows[0] = orderRow(status: 'CANCELADO');
          return {
            'id_pedido': 7,
            'codigo': 'AB12CD34',
            'estado': 'CANCELADO',
            'monto_pagado': '1012000.00',
            'monto_retenido': '712000.00',
            'monto_devuelto': '300000.00',
          };
        };
        await pumpAdminApp(
          tester,
          overrides: [
            ...server.harness.overrides,
            orderRefreshIntervalProvider.overrideWithValue(null),
          ],
        );
        await tester.tap(find.text('Todos'));
        await tester.pumpAndSettle();
        await _openFirstOrder(tester);

        await tester.tap(find.widgetWithText(FilledButton, 'Cancelar pedido'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Parcial'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('cancel_refund')),
          '300000',
        );
        await tester.enterText(
          find.byKey(const Key('cancel_reason')),
          'El cliente no responde',
        );
        await tester.tap(
          find.widgetWithText(FilledButton, 'Cancelar pedido').last,
        );
        await tester.pumpAndSettle();

        final request = server.harness.adapter
            .to(ApiEndpoints.ordersCancel)
            .single;
        expect(request.bodyMap, {
          'id': 7,
          'decision': 'DEVOLUCION_PARCIAL',
          'monto_devuelto': '300000.00',
          'motivo': 'El cliente no responde',
        });
        expect(find.text('Pedido cancelado'), findsOneWidget);
        await dismissToasts(tester);
      },
    );

    testWidgets('el empleado no ve confirmar, rechazar ni cancelar', (
      tester,
    ) async {
      await _open(tester, permissions: employeePermissions);
      await _openFirstOrder(tester);

      expect(find.text('Pedido AB12CD34'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Confirmar'), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Rechazar'), findsNothing);
    });
  });

  testWidgets('la lista y el detalle no desbordan', (tester) async {
    for (final (width, scale) in [(320.0, 1.5), (390.0, 1.0), (800.0, 1.0)]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 700);
      addTearDown(tester.view.reset);
      final server = OrdersServer(
        rows: [
          orderRow(
            client: 'maría de los ángeles rodríguez de la cruz',
            garment: 'cadena cubana con dije de la virgen del carmen',
          ),
        ],
      );
      await pumpAdminApp(
        tester,
        width: width,
        height: 700,
        overrides: [
          ...server.harness.overrides,
          orderRefreshIntervalProvider.overrideWithValue(null),
        ],
      );
      expect(tester.takeException(), isNull, reason: 'lista $width');
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'detalle $width × $scale');
      await tester.pumpWidget(const SizedBox());
    }
  });
}
