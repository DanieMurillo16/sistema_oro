// Pestañas al pie (zona del pulgar) con las fuentes reales: toque cómodo, 4
// opciones sin desbordes y la lista siempre por encima de la barra.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/features/orders/providers/order_counters_provider.dart';
import 'package:sistema_oro/features/orders/widgets/order_tile.dart';
import 'package:sistema_oro/shared/widgets/bottom_toggle_bar.dart';

import '../../helpers/order_fixtures.dart';
import '../../support/pump_at_sizes.dart';
import '../../support/real_fonts.dart';

final _bar = find.byWidgetPredicate((w) => w is BottomToggleBar);

Future<void> _open(
  WidgetTester tester, {
  required double width,
  double scale = 1,
  bool layaways = false,
}) async {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final server = OrdersServer(
    rows: [
      for (var i = 0; i < 8; i++)
        orderRow(
          id: 20 + i,
          code: 'AB12CD3$i',
          type: layaways ? 'SEPARADO' : 'COMPRA',
          status: layaways ? 'ACTIVO' : 'PENDIENTE',
          deadline: layaways ? '2026-11-19' : null,
        ),
    ],
  );
  await pumpAdminApp(
    tester,
    width: width,
    overrides: [
      ...server.harness.overrides,
      orderRefreshIntervalProvider.overrideWithValue(null),
    ],
  );
  if (layaways) {
    await tester.tap(find.text('Separados').last);
    await tester.pumpAndSettle();
  }
}

void main() {
  setUpAll(loadRealFonts);

  testWidgets('las opciones se tocan cómodas (≥ 44) y no desbordan', (
    tester,
  ) async {
    for (final (width, scale, layaways) in [
      (320.0, 1.5, true), // 4 opciones, el caso más apretado
      (390.0, 1.0, false),
      (800.0, 1.5, false),
    ]) {
      await _open(tester, width: width, scale: scale, layaways: layaways);
      final options = find.descendant(of: _bar, matching: find.byType(InkWell));
      expect(options, findsWidgets, reason: '$width');
      for (var i = 0; i < tester.widgetList(options).length; i++) {
        expect(
          tester.getSize(options.at(i)).height,
          greaterThanOrEqualTo(44),
          reason: 'opción $i · $width px · texto $scale',
        );
      }
      expect(tester.takeException(), isNull, reason: '$width × $scale');
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('la última tarjeta queda por encima de la barra', (tester) async {
    await _open(tester, width: 390, scale: 1.5);
    final scrollable = find.byType(Scrollable).last;
    await tester.drag(scrollable, const Offset(0, -3000));
    await tester.pumpAndSettle();
    final barTop = tester.getTopLeft(_bar).dy;
    final lastTile = tester.getRect(find.byType(OrderTile).last);
    expect(lastTile.bottom, lessThanOrEqualTo(barTop));
  });

  testWidgets(
    'con el teclado abierto se esconden la barra y los KPI (800 px)',
    (tester) async {
      await _open(tester, width: 800);
      expect(_bar, findsOneWidget);
      expect(find.text('Separados activos'), findsWidgets); // KPI

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(find.text('Compras'), findsNothing);
      expect(find.text('Separados activos'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
