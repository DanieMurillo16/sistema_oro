// Afirmaciones de layout con las fuentes reales (Inter / Plus Jakarta Sans):
// con Ahem, la de las pruebas, todo mide ~1,8× más ancho. Va en su propio
// archivo porque las fuentes deben cargarse antes de la primera medición.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_card.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_brand.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_chat_button.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_header.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_type_chip.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_type_strip.dart';
import 'package:sistema_oro/features/catalog/widgets/checkout/checkout_summary.dart';
import 'package:sistema_oro/features/catalog/widgets/checkout/quantity_stepper.dart';

import '../../helpers/catalog_fixtures.dart';
import '../../support/pump_at_sizes.dart';
import '../../support/real_fonts.dart';

Future<void> _open(
  WidgetTester tester, {
  required double width,
  double scale = 1,
  CatalogServer? server,
}) async {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await pumpCatalogApp(
    tester,
    width: width,
    height: 800,
    overrides: (server ?? CatalogServer()).harness.overrides,
  );
}

void main() {
  setUpAll(loadRealFonts);

  testWidgets('los chips de tipos miden ≤ 48 px de alto al bajar la lista', (
    tester,
  ) async {
    for (final (width, scale) in [
      (800.0, 1.0),
      (800.0, 1.5),
      (1300.0, 1.0),
      (1300.0, 1.5),
    ]) {
      await _open(tester, width: width, scale: scale);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      final chips = find.byType(CatalogTypeChip);
      expect(chips, findsNWidgets(3), reason: 'Todas + 2 tipos');
      for (var i = 0; i < 3; i++) {
        expect(
          tester.getSize(chips.at(i)).height,
          lessThanOrEqualTo(48),
          reason: 'chip $i · $width px · texto $scale',
        );
      }
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets(
    'cabecera: logo centrado arriba; compacta sin cortes y sin saltos',
    (tester) async {
      for (final (width, scale) in [
        (320.0, 2.0),
        (390.0, 1.0),
        (390.0, 1.5),
        (800.0, 1.0),
        (1300.0, 1.5),
      ]) {
        final reason = '$width px · texto $scale';
        await _open(tester, width: width, scale: scale);
        final header = find.byType(CatalogHeader);
        final brand = find.byType(CatalogBrand);
        final topHeight = tester.getSize(header).height;
        expect(
          tester.getCenter(brand).dx,
          closeTo(width / 2, 1),
          reason: reason,
        );

        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: reason);
        expect(
          tester.getSize(header).height,
          topHeight,
          reason: 'sin saltos $reason',
        );
        final box = tester.getRect(header);
        for (final f in [
          brand,
          find.byType(CatalogTypeChip).first,
          find.byType(CatalogChatButton),
        ]) {
          final r = tester.getRect(f);
          expect(
            r.top,
            greaterThanOrEqualTo(box.top),
            reason: 'dentro $reason',
          );
          expect(
            r.bottom,
            lessThanOrEqualTo(box.bottom),
            reason: 'dentro $reason',
          );
        }
        if (width >= 800) {
          // Los tipos, en el centro de la pantalla (3 chips).
          final strip = tester.getRect(find.byType(CatalogTypeStrip));
          expect(
            strip.center.dx,
            closeTo(width / 2, 2),
            reason: 'tipos $reason',
          );
        }
        await tester.pumpWidget(const SizedBox());
      }
    },
  );

  testWidgets('comprar: un nombre largo no pasa de 3 líneas a 390 px', (
    tester,
  ) async {
    final server = CatalogServer(
      rows: [
        publicGarment(
          name: 'Cadena cubana gruesa de eslabones macizos para caballero',
        ),
      ],
    );
    await _open(tester, width: 390, server: server);
    final card = find.descendant(
      of: find.byType(CatalogCard),
      matching: find.textContaining('Cadena cubana gruesa'),
    );
    await tester.scrollUntilVisible(
      card,
      200,
      scrollable: find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Comprar ahora'));
    await tester.pumpAndSettle();

    final name = find.descendant(
      of: find.byType(CheckoutSummary),
      matching: find.textContaining('Cadena cubana gruesa'),
    );
    final lines =
        tester.renderObject<RenderParagraph>(name).size.height /
        tester.renderObject<RenderParagraph>(name).text.style!.fontSize!;
    expect(lines, lessThan(4.5), reason: 'alto/tamaño de letra ≈ líneas');
    // Con un nombre largo la cantidad baja y va en una línea.
    expect(
      tester.getCenter(find.text('Cantidad')).dy,
      moreOrLessEquals(
        tester.getCenter(find.byType(QuantityStepper)).dy,
        epsilon: 2,
      ),
    );
  });

  testWidgets(
    'comprar: el nombre conserva ancho junto a la cantidad y «Banco (opcional)» no se corta',
    (tester) async {
      for (final width in [320.0, 390.0]) {
        await _open(tester, width: width);
        final card = find.descendant(
          of: find.byType(CatalogCard),
          matching: find.text('Cadena cubana'),
        );
        await tester.scrollUntilVisible(
          card,
          200,
          scrollable: find
              .descendant(
                of: find.byType(CustomScrollView),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await tester.tap(card);
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Comprar ahora'));
        await tester.pumpAndSettle();

        // Con shrinkWrap: 36 + 36 + 36 de cantidad, no los 132 px de antes.
        expect(
          tester.getSize(find.byType(QuantityStepper)).width,
          moreOrLessEquals(108, epsilon: 4),
          reason: '$width px',
        );
        final name = find.descendant(
          of: find.byType(CheckoutSummary),
          matching: find.text('Cadena cubana'),
        );
        final label = find.text('Cantidad');
        if (width >= 390) {
          // A la derecha: etiqueta y control en un solo eje, centrados con la fila.
          final block = Rect.fromPoints(
            tester.getTopLeft(label),
            tester.getBottomRight(find.byType(QuantityStepper)),
          );
          expect(
            block.center.dy,
            moreOrLessEquals(
              tester.getCenter(find.byType(CheckoutSummary)).dy,
              epsilon: 4,
            ),
            reason: 'cantidad centrada en la fila ($width px)',
          );
        } else {
          // Debajo del precio: etiqueta y control en una sola línea.
          expect(
            tester.getCenter(label).dy,
            moreOrLessEquals(
              tester.getCenter(find.byType(QuantityStepper)).dy,
              epsilon: 2,
            ),
            reason: 'etiqueta y control en una línea ($width px)',
          );
        }
        // La columna del nombre (Expanded) es el ancho que queda a la prenda.
        final nameColumn = find.ancestor(
          of: name,
          matching: find.byType(Expanded),
        );
        expect(
          tester.getSize(nameColumn.first).width,
          greaterThanOrEqualTo(100),
          reason: 'ancho del nombre a $width px',
        );

        await tester.ensureVisible(find.byKey(const Key('checkout_bank')));
        await tester.pumpAndSettle();
        final bankLabel = tester.renderObject<RenderParagraph>(
          find.descendant(
            of: find.byKey(const Key('checkout_bank')),
            matching: find.text('Banco (opcional)'),
          ),
        );
        expect(
          bankLabel.didExceedMaxLines,
          isFalse,
          reason: 'elipsis a $width px',
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    },
  );
}
