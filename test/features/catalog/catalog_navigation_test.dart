import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/features/catalog/catalog_garment_screen.dart';
import 'package:sistema_oro/features/catalog/catalog_screen.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_back_button.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_card.dart';
import 'package:sistema_oro/features/catalog/widgets/related_garments.dart';

import '../../helpers/catalog_fixtures.dart';
import '../../support/pump_at_sizes.dart';

/// Nombre de la prenda que muestra el detalle de arriba de la pila.
Finder _detailTitle(String name) => find.descendant(
  of: find.byType(CatalogGarmentScreen),
  matching: find.text(name),
);

Future<void> _openRelated(WidgetTester tester, String name) async {
  final card = find.descendant(
    of: find.byType(RelatedGarments),
    matching: find.text(name),
  );
  await tester.scrollUntilVisible(
    card,
    200,
    scrollable: find
        .descendant(
          of: find.byType(CatalogGarmentScreen),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
  await tester.tap(card);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'atrás del navegador vuelve prenda por prenda: inicio → A → B → C',
    (tester) async {
      final server = CatalogServer(
        rows: [
          publicGarment(id: 11, name: 'Cadena A'),
          publicGarment(id: 12, name: 'Cadena B'),
          publicGarment(id: 13, name: 'Cadena C'),
        ],
      );
      await pumpCatalogApp(tester, overrides: server.harness.overrides);

      final cardA = find.descendant(
        of: find.byType(CatalogCard),
        matching: find.text('Cadena A'),
      );
      await tester.scrollUntilVisible(
        cardA,
        200,
        scrollable: find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(cardA);
      await tester.pumpAndSettle();
      expect(_detailTitle('Cadena A'), findsWidgets);

      await _openRelated(tester, 'Cadena B');
      expect(_detailTitle('Cadena B'), findsWidgets);
      await _openRelated(tester, 'Cadena C');
      expect(_detailTitle('Cadena C'), findsWidgets);

      // Atrás del navegador / gesto del teléfono: prenda por prenda.
      for (final previous in ['Cadena B', 'Cadena A']) {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(CatalogGarmentScreen), findsOneWidget);
        expect(
          _detailTitle(previous),
          findsWidgets,
          reason: 'vuelve a $previous',
        );
      }
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(CatalogGarmentScreen), findsNothing);
      expect(find.byType(CatalogScreen), findsOneWidget);
    },
  );

  testWidgets(
    'la flecha de la pantalla lleva al inicio de una vez, con su scroll y tipo',
    (tester) async {
      final server = CatalogServer(
        rows: [
          for (var i = 0; i < 12; i++)
            publicGarment(
              id: 11 + i,
              name: 'Cadena ${String.fromCharCode(65 + i)}',
            ),
        ],
      );
      await pumpCatalogApp(tester, overrides: server.harness.overrides);

      final listScroll = find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first;
      final cardF = find.descendant(
        of: find.byType(CatalogCard),
        matching: find.text('Cadena F'),
      );
      await tester.scrollUntilVisible(cardF, 200, scrollable: listScroll);
      await tester.pumpAndSettle();
      final offset = tester.state<ScrollableState>(listScroll).position.pixels;
      expect(offset, greaterThan(0));
      await tester.tap(cardF);
      await tester.pumpAndSettle();
      await _openRelated(tester, 'Cadena B');
      await _openRelated(tester, 'Cadena C');
      await _openRelated(tester, 'Cadena D');

      await tester.tap(find.byType(CatalogBackButton).last);
      await tester.pumpAndSettle();

      // Un solo toque: sin detalles en la pila y el listado como se dejó.
      expect(find.byType(CatalogGarmentScreen), findsNothing);
      expect(find.byType(CatalogScreen), findsOneWidget);
      expect(tester.state<ScrollableState>(listScroll).position.pixels, offset);
    },
  );

  testWidgets('un enlace directo a una prenda deja el catálogo debajo', (
    tester,
  ) async {
    final server = CatalogServer(
      rows: [publicGarment(id: 11, name: 'Cadena A')],
    );
    await pumpCatalogApp(tester, overrides: server.harness.overrides);

    GoRouter.of(tester.element(find.byType(CatalogScreen))).go('/prenda/11');
    await tester.pumpAndSettle();
    expect(find.byType(CatalogGarmentScreen), findsOneWidget);

    await tester.tap(find.byType(CatalogBackButton));
    await tester.pumpAndSettle();
    expect(find.byType(CatalogGarmentScreen), findsNothing);
    expect(find.byType(CatalogScreen), findsOneWidget);
  });
}
