import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';
import 'package:sistema_oro/features/summary/utils/summary_rules.dart';

import '../../helpers/admin_server.dart';
import '../../support/pump_at_sizes.dart';

// JSON con la forma de backend/docs/API.md → resumen/obtener.php (dinero como texto).
Map<String, dynamic> _summary(String month, {bool profit = true}) => {
  'mes': month,
  'ventas': {'monto': '3450000.00', 'cantidad': 3},
  'ganancia_estimada': profit ? '980000.00' : null,
  'abonos': {'monto': '1200000.00', 'cantidad': 5},
  'por_cobrar': {'saldo': '2750000.00', 'separados': 4},
  'vencidos': {'cantidad': 1, 'recargos': '80000.00', 'por_vencer': 2},
  'solicitudes_pendientes': 2,
  'clientes': {'nuevos': 6, 'total': 41},
  'inventario': {'prendas': 18, 'unidades': 37, 'valor_venta': '52300000.00'},
};

Future<AdminServer> _open(
  WidgetTester tester, {
  List<String> permissions = const ['resumen.ver', 'prendas.ver_costo'],
  bool profit = true,
  double width = 390,
}) async {
  final server = AdminServer(
    permissions: permissions,
    routes: {
      ApiEndpoints.summary: (o) =>
          _summary('${o.queryParameters['mes']}', profit: profit),
    },
  );
  await pumpAdminApp(
    tester,
    overrides: server.harness.overrides,
    width: width,
    height: 1400,
  );
  return server;
}

void main() {
  testWidgets('es la primera pestaña y muestra las cifras del mes actual', (
    tester,
  ) async {
    final server = await _open(tester);

    final now = SummaryRules.firstOfMonth(DateTime.now());
    expect(find.text('Resumen'), findsWidgets);
    expect(find.text(SummaryRules.label(now)), findsOneWidget);
    expect(find.text(r'$ 3.450.000'), findsOneWidget); // ventas
    expect(find.text(r'$ 1.200.000'), findsOneWidget); // abonos
    expect(find.text(r'$ 2.750.000'), findsOneWidget); // por cobrar
    expect(
      find.text(r'$ 980.000'),
      findsOneWidget,
    ); // ganancia (tiene permiso de costos)
    expect(find.text('Pedidos vendidos'), findsOneWidget);
    expect(find.text('Vencen en los próximos 7 días'), findsOneWidget);
    expect(server.harness.adapter.to(ApiEndpoints.summary).single.query, {
      'mes': SummaryRules.key(now),
    });
  });

  testWidgets('sin permiso de ver costos no hay ganancia estimada', (
    tester,
  ) async {
    await _open(tester, permissions: const ['resumen.ver'], profit: false);
    expect(find.text('Ganancia estimada'), findsNothing);
    expect(find.text(r'$ 980.000'), findsNothing);
    expect(find.text('Ventas del mes'), findsOneWidget);
  });

  testWidgets('el selector de mes pide el mes anterior y no pasa del actual', (
    tester,
  ) async {
    final server = await _open(tester);
    final now = SummaryRules.firstOfMonth(DateTime.now());
    // En el mes actual «siguiente» está apagado.
    final next = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right_rounded),
    );
    expect(next.onPressed, isNull);

    await tester.tap(find.byTooltip('Mes anterior'));
    await tester.pumpAndSettle();

    final previous = SummaryRules.shift(now, -1);
    expect(find.text(SummaryRules.label(previous)), findsOneWidget);
    expect(server.harness.adapter.to(ApiEndpoints.summary).last.query, {
      'mes': SummaryRules.key(previous),
    });
    final next2 = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right_rounded),
    );
    expect(next2.onPressed, isNotNull);
  });

  testWidgets('el ojo tapa el dinero y deja visibles las cantidades', (
    tester,
  ) async {
    await _open(tester);
    expect(find.text(r'$ 3.450.000'), findsOneWidget);

    await tester.tap(find.byTooltip('Ocultar cifras').first);
    await tester.pumpAndSettle();

    expect(find.text(r'$ 3.450.000'), findsNothing);
    expect(find.text(r'$ 52.300.000'), findsNothing);
    expect(find.text('••••••'), findsWidgets);
    expect(find.text('37'), findsOneWidget); // unidades: no es dinero
  });

  testWidgets('el resumen no desborda en ningún tamaño ni con letra grande', (
    tester,
  ) async {
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    for (final scale in [1.0, 1.5]) {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      for (final width in [320.0, 390.0, 800.0, 1300.0]) {
        await _open(tester, width: width);
        expect(
          tester.takeException(),
          isNull,
          reason: '$width px · letra $scale',
        );
        await tester.pumpWidget(const SizedBox());
      }
    }
  });
}
