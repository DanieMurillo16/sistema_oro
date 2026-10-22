// Layout de la tarjeta de «Pedidos» con las fuentes reales (con Ahem todo mide
// ~1,8× más ancho). Archivo propio: las fuentes se cargan antes de medir.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/theme/app_theme.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/providers/order_detail_provider.dart';
import 'package:sistema_oro/features/orders/widgets/order_tile.dart';
import 'package:sistema_oro/features/orders/widgets/order_type_chip.dart';
import 'package:sistema_oro/features/orders/widgets/receipt_thumb.dart';

import '../../helpers/order_fixtures.dart';
import '../../support/expect_layout.dart';
import '../../support/fake_image_picker.dart';
import '../../support/real_fonts.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, dynamic> row, {
  double width = 390,
  double scale = 1,
  bool detailed = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 900);
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final Uint8List bytes = FakeImagePicker.sample.bytes;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        receiptThumbProvider('c1.jpg').overrideWith((ref) async => bytes),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OrderTile(
                order: Order.fromJson(row),
                onTap: () {},
                showTypeAndReceipt: detailed,
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadRealFonts);

  testWidgets('compra pendiente con comprobante y banco: ≤ 4 líneas a 390', (
    tester,
  ) async {
    await _pump(tester, orderRow(receipt: 'c1.jpg', bank: 'Bancolombia'));
    expect(
      tester.getSize(find.byType(OrderTile)).height,
      lessThanOrEqualTo(124),
    );
    expectSingleLine(tester, find.text(r'$ 1.012.000'));
    expectSingleLine(tester, find.text('Bancolombia'));
    expectRightEdge(tester, find.text(r'$ 1.012.000'), find.byType(OrderTile));
    // La miniatura no se monta sobre el título ni el monto.
    final thumb = tester.getRect(find.byType(ReceiptThumb));
    expect(thumb.size, const Size(44, 44));
    expect(thumb.overlaps(tester.getRect(find.text(r'$ 1.012.000'))), isFalse);
    expect(thumb.overlaps(tester.getRect(find.text('Juan Pérez'))), isFalse);
  });

  testWidgets('separado activo: saldo y plazo comparten línea; sin desbordes', (
    tester,
  ) async {
    for (final (width, scale) in [(390.0, 1.0), (360.0, 1.0), (320.0, 1.5)]) {
      await _pump(
        tester,
        orderRow(
          type: 'SEPARADO',
          status: 'ACTIVO',
          balance: '800000.00',
          deadline: '2026-11-19',
          receipt: 'c1.jpg',
          bank: 'Banco de Bogotá',
        ),
        width: width,
        scale: scale,
      );
      expect(tester.takeException(), isNull, reason: '$width × $scale');
      if (scale == 1.0 && width >= 360) {
        expectSameRow(
          tester,
          find.textContaining('Saldo'),
          find.textContaining('Vence'),
        );
      }
      expectSingleLine(tester, find.text(r'$ 1.012.000'));
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('sin la bandera (Separados) no hay chip de tipo ni miniatura', (
    tester,
  ) async {
    await _pump(
      tester,
      orderRow(
        type: 'SEPARADO',
        status: 'ACTIVO',
        balance: '800000.00',
        deadline: '2026-11-19',
        receipt: 'c1.jpg',
        bank: 'Nequi',
      ),
      detailed: false,
    );
    expect(find.byType(OrderTypeChip), findsNothing);
    expect(find.byType(ReceiptThumb), findsNothing);
    expect(find.text('Nequi'), findsNothing);
    expect(find.text('Separado · Activo'), findsOneWidget);
  });
}
