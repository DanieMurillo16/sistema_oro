// Layout del formulario de prenda con las fuentes reales (Inter): con Ahem, la
// de las pruebas, todo mide ~1,8× más ancho. Archivo aparte porque las fuentes
// se cargan antes de la primera medición.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/garment_fixtures.dart';
import '../../support/expect_layout.dart';
import '../../support/pump_at_sizes.dart';
import '../../support/real_fonts.dart';

void main() {
  setUpAll(loadRealFonts);

  testWidgets(
    'Nombre y Tipo de prenda van en pareja a 390 px y el tipo elegido se ve entero',
    (tester) async {
      final server = GarmentsServer(permissions: ownerGarmentPermissions);
      await pumpAdminApp(tester, overrides: server.harness.overrides);

      await tester.tap(find.text('Nueva prenda'));
      await tester.pumpAndSettle();
      final name = find.byKey(const Key('garment_name'));
      final type = find.widgetWithText(TextField, 'Tipo de prenda');
      expectSameRow(tester, name, type);

      await tester.tap(type);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Pulseras'));
      await tester.pumpAndSettle();

      expectSameRow(tester, name, type); // elegir no cambia la distribución
      final field = find.descendant(
        of: type,
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(field).controller.text, 'Pulseras');
      // El texto cabe sin desplazarse dentro del campo (nada oculto a la derecha).
      final scroll = tester.state<ScrollableState>(
        find.descendant(of: field, matching: find.byType(Scrollable)),
      );
      expect(scroll.position.maxScrollExtent, 0);
      expect(tester.takeException(), isNull);
    },
  );
}
