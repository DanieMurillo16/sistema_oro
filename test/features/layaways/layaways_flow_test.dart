import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/features/orders/providers/order_counters_provider.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';

import '../../helpers/order_fixtures.dart';
import '../../support/fake_image_picker.dart';
import '../../support/form_request.dart';
import '../../support/pump_at_sizes.dart';

Map<String, dynamic> _layaway({
  String balance = '800000.00',
  String paid = '200000.00',
}) => orderRow(
  id: 8,
  code: 'LY000008',
  type: 'SEPARADO',
  status: 'ACTIVO',
  client: 'ana gómez',
  total: '1000000.00',
  paid: paid,
  balance: balance,
  deadline: '2026-11-19',
);

Future<(OrdersServer, FakeImagePicker)> _open(WidgetTester tester) async {
  final server = OrdersServer(rows: [_layaway()])..payments = [paymentRow()];
  final picker = FakeImagePicker();
  await pumpAdminApp(
    tester,
    overrides: [
      ...server.harness.overrides,
      orderRefreshIntervalProvider.overrideWithValue(null),
      imagePickerServiceProvider.overrideWithValue(picker),
    ],
  );
  await tester.tap(find.text('Separados').last);
  await tester.pumpAndSettle();
  return (server, picker);
}

void main() {
  testWidgets('la lista de separados muestra saldo y fecha límite', (
    tester,
  ) async {
    await _open(tester);

    expect(find.text('Ana Gómez'), findsOneWidget);
    expect(find.textContaining(r'Saldo $ 800.000'), findsOneWidget);
    expect(find.text('Vence 19/11/2026'), findsOneWidget);
  });

  testWidgets('registrar un abono envía el formulario con el comprobante', (
    tester,
  ) async {
    final (server, picker) = await _open(tester);
    server.writes[ApiEndpoints.paymentsRegister] = () {
      server.rows[0] = _layaway(balance: '500000.00', paid: '500000.00');
      return {
        'id_pago': 2,
        'estado': 'ACTIVO',
        'total_pagado': '500000.00',
        'saldo': '500000.00',
      };
    };
    await tester.tap(find.text('Ana Gómez'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Registrar abono'));
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const Key('payment_amount')),
        matching: find.byType(TextField),
      ),
    );
    expect(field.decoration!.prefixText, r'$ '); // sin barra invertida
    await tester.enterText(find.byKey(const Key('payment_amount')), '300000');
    await tester.tap(
      find.widgetWithText(OutlinedButton, 'Adjuntar comprobante'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar abono').last);
    await tester.pumpAndSettle();

    expect(picker.picks, 1);
    final request = server.harness.adapter
        .to(ApiEndpoints.paymentsRegister)
        .single;
    expect(request.method, 'POST');
    expect(request.authorization, 'Bearer tok');
    expect(request.formFields['id_pedido'], '8');
    expect(request.formFields['monto'], '300000.00');
    expect(request.formFields['medio'], 'TRANSFERENCIA');
    expect(request.formFields['fecha'], matches(r'^\d{4}-\d{2}-\d{2}$'));
    expect(request.formFileNames, ['comprobante']);
    expect(find.text('Abono registrado'), findsOneWidget);
    await dismissToasts(tester);
  });

  testWidgets('una transferencia sin comprobante no se envía', (tester) async {
    final (server, _) = await _open(tester);
    await tester.tap(find.text('Ana Gómez'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Registrar abono'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('payment_amount')), '300000');
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar abono').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('Adjunta el comprobante'), findsOneWidget);
    expect(server.harness.adapter.to(ApiEndpoints.paymentsRegister), isEmpty);
  });

  testWidgets('un abono mayor al saldo se rechaza antes de enviar', (
    tester,
  ) async {
    final (server, _) = await _open(tester);
    await tester.tap(find.text('Ana Gómez'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Registrar abono'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('payment_amount')), '900000');
    await tester.tap(find.widgetWithText(FilledButton, 'Registrar abono').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('No puede superar el saldo'), findsOneWidget);
    expect(server.harness.adapter.to(ApiEndpoints.paymentsRegister), isEmpty);
  });

  testWidgets('anular un pago: abrir el diálogo y «Cancelar» no envían nada', (
    tester,
  ) async {
    final (server, _) = await _open(tester);
    await tester.tap(find.text('Ana Gómez'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.byTooltip('Anular pago'), 200);
    await tester.ensureVisible(find.byTooltip('Anular pago'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Anular pago'));
    await tester.pumpAndSettle();
    expect(server.harness.adapter.to(ApiEndpoints.paymentsVoid), isEmpty);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Cancelar'));
    await tester.pumpAndSettle();
    expect(server.harness.adapter.to(ApiEndpoints.paymentsVoid), isEmpty);
    expect(find.byKey(const Key('void_reason')), findsNothing); // se cerró
  });

  testWidgets('anular un pago envía el id y el motivo', (tester) async {
    final (server, _) = await _open(tester);
    server.writes[ApiEndpoints.paymentsVoid] = () {
      server.payments = [
        paymentRow()
          ..['estado'] = 'ANULADO'
          ..['motivo_anulacion'] = 'Duplicado',
      ];
      return {
        'id_pedido': 8,
        'estado': 'ACTIVO',
        'total_pagado': '0.00',
        'saldo': '1000000.00',
      };
    };
    await tester.tap(find.text('Ana Gómez'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.byTooltip('Anular pago'), 200);
    await tester.ensureVisible(find.byTooltip('Anular pago'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Anular pago'));
    await tester.pumpAndSettle();
    // El subtítulo del diálogo es solo el monto (sin fecha ni medio de pago).
    final header = find.byType(DialogHeader);
    expect(
      find.descendant(of: header, matching: find.byType(Text)),
      findsNWidgets(2),
    );
    expect(
      find.descendant(of: header, matching: find.text(r'$ 200.000')),
      findsOneWidget,
    );
    await tester.enterText(find.byKey(const Key('void_reason')), 'Duplicado');
    await tester.tap(find.widgetWithText(FilledButton, 'Anular pago'));
    await tester.pumpAndSettle();

    final request = server.harness.adapter.to(ApiEndpoints.paymentsVoid).single;
    expect(request.bodyMap, {'id_pago': 1, 'motivo': 'Duplicado'});
    expect(find.text('Pago anulado'), findsOneWidget);
    expect(find.text('Anulado'), findsWidgets);
    await dismissToasts(tester);
  });

  testWidgets(
    'anular el abono de un separado PAGADO lo reabre: vuelve a tener saldo y ya no se entrega',
    (tester) async {
      // Caso del pedido 10F03850: pagado por completo, listo para entregar.
      final paid = orderRow(
        id: 8,
        code: '10F03850',
        type: 'SEPARADO',
        status: 'PAGADO',
        client: 'ana gómez',
        total: '1012000.00',
        paid: '1012000.00',
        balance: '0.00',
      );
      final server = OrdersServer(rows: [paid])
        ..payments = [
          paymentRow(amount: '212000.00', banco: 'Nequi'),
          paymentRow(id: 2, amount: '800000.00', initial: false, receipt: null),
        ];
      server.writes[ApiEndpoints.paymentsVoid] = () {
        server.rows[0] = orderRow(
          id: 8,
          code: '10F03850',
          type: 'SEPARADO',
          status: 'ACTIVO',
          client: 'ana gómez',
          total: '1012000.00',
          paid: '212000.00',
          balance: '800000.00',
          deadline: '2026-11-19',
        );
        server.payments = [
          server.payments[0],
          paymentRow(id: 2, amount: '800000.00', initial: false, receipt: null)
            ..['estado'] = 'ANULADO'
            ..['motivo_anulacion'] = 'Comprobante falso',
        ];
        return {
          'id_pedido': 8,
          'estado': 'ACTIVO',
          'total_pagado': '212000.00',
          'saldo': '800000.00',
        };
      };
      await pumpAdminApp(
        tester,
        height: 1400,
        overrides: [
          ...server.harness.overrides,
          orderRefreshIntervalProvider.overrideWithValue(null),
        ],
      );
      await tester.tap(find.text('Separados').last);
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('Todos'),
      ); // un separado pagado no está en «Activos»
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ana Gómez'));
      await tester.pumpAndSettle();

      // Pagado: se puede entregar, y cada pago vigente tiene su botón «Anular» visible.
      expect(find.text('Marcar entregado'), findsOneWidget);
      expect(find.text('Banco: Nequi'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Anular'), findsNWidgets(2));

      await tester.tap(find.widgetWithText(TextButton, 'Anular').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('vuelve a «Activo»'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('void_reason')),
        'Comprobante falso',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Anular pago'));
      await tester.pumpAndSettle();

      final request = server.harness.adapter
          .to(ApiEndpoints.paymentsVoid)
          .single;
      expect(request.bodyMap, {'id_pago': 2, 'motivo': 'Comprobante falso'});
      expect(find.text('Pago anulado'), findsOneWidget);
      // Reabierto: con saldo, sin «Marcar entregado» y con «Registrar abono».
      expect(find.text('Marcar entregado'), findsNothing);
      expect(find.text('Registrar abono'), findsWidgets);
      expect(find.text('Anulado'), findsWidgets);
      expect(
        find.widgetWithText(TextButton, 'Anular'),
        findsOneWidget,
      ); // solo el vigente
      await dismissToasts(tester);
    },
  );

  testWidgets('el pago inicial de un separado también se puede anular', (
    tester,
  ) async {
    await _open(tester);
    await tester.tap(find.text('Ana Gómez'));
    await tester.pumpAndSettle();
    // El único pago es el inicial: antes el servidor lo rechazaba y no había cómo corregirlo.
    expect(find.textContaining('Pago inicial'), findsWidgets);
    expect(find.widgetWithText(TextButton, 'Anular'), findsOneWidget);
  });

  testWidgets(
    'en una compra no hay «Anular» (se cancela o se rechaza el pedido)',
    (tester) async {
      final server = OrdersServer(rows: [orderRow(status: 'CONFIRMADO')])
        ..payments = [paymentRow()];
      await pumpAdminApp(tester, overrides: server.harness.overrides);
      await tester.tap(find.text('Compras').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Juan Pérez'));
      await tester.pumpAndSettle();
      expect(find.text('Pagos'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Anular'), findsNothing);
    },
  );

  testWidgets('el empleado puede abonar pero no anular', (tester) async {
    final server = OrdersServer(
      permissions: employeePermissions,
      rows: [_layaway()],
    )..payments = [paymentRow()];
    await pumpAdminApp(
      tester,
      overrides: [
        ...server.harness.overrides,
        orderRefreshIntervalProvider.overrideWithValue(null),
      ],
    );
    await tester.tap(find.text('Separados').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ana Gómez'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(FilledButton, 'Registrar abono'),
      findsOneWidget,
    );
    expect(find.byTooltip('Anular pago'), findsNothing);
  });
}
