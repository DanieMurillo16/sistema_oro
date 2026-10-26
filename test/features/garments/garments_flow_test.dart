import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';

import '../../helpers/garment_fixtures.dart';
import '../../support/fake_image_picker.dart';
import '../../support/form_request.dart';
import '../../support/pump_at_sizes.dart';

Future<(GarmentsServer, FakeImagePicker)> _open(
  WidgetTester tester, {
  List<String> permissions = ownerGarmentPermissions,
  List<Map<String, dynamic>>? rows,
  double width = 390,
  double height = 800,
}) async {
  final server = GarmentsServer(permissions: permissions, rows: rows);
  final picker = FakeImagePicker();
  await pumpAdminApp(
    tester,
    width: width,
    height: height,
    overrides: [
      ...server.harness.overrides,
      imagePickerServiceProvider.overrideWithValue(picker),
    ],
  );
  return (server, picker);
}

/// Baja hasta el botón «Eliminar prenda» del detalle (la lista construye lo
/// que se ve) y lo deja completo a la vista.
Future<void> _revealDelete(WidgetTester tester) async {
  final button = find.widgetWithText(OutlinedButton, 'Eliminar prenda');
  await tester.scrollUntilVisible(
    button,
    200,
    scrollable: find
        .descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
}

/// Deja pasar el aviso (toast) para que no quede un Timer pendiente.
Future<void> _letToastGo(WidgetTester tester) =>
    tester.pump(const Duration(seconds: 3));

Future<void> _openDetail(WidgetTester tester) async {
  await tester.tap(find.text('Cadena cubana'));
  await tester.pumpAndSettle();
}

Future<void> _fillNewGarment(WidgetTester tester) async {
  await tester.tap(find.text('Nueva prenda'));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('garment_name')),
    'Pulsera tejida',
  );
  await tester.tap(find.widgetWithText(TextField, 'Tipo de prenda'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ListTile, 'Pulseras'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('garment_weight')), '4,5');
  await tester.enterText(find.byKey(const Key('garment_sale_price')), '850000');
}

void main() {
  group('confirmación antes de eliminar', () {
    testWidgets(
      'eliminar: nada se envía hasta confirmar; Cancelar y tocar fuera no envían',
      (tester) async {
        final (server, _) = await _open(tester);
        server.writes[ApiEndpoints.garmentsDelete] = () => {'id_prenda': 11};
        await _openDetail(tester);
        await _revealDelete(tester);

        await tester.tap(
          find.widgetWithText(OutlinedButton, 'Eliminar prenda'),
        );
        await tester.pumpAndSettle();
        expect(server.harness.adapter.to(ApiEndpoints.garmentsDelete), isEmpty);
        await tester.tap(find.widgetWithText(OutlinedButton, 'Cancelar'));
        await tester.pumpAndSettle();
        expect(server.harness.adapter.to(ApiEndpoints.garmentsDelete), isEmpty);
        expect(
          find.byKey(const Key('delete_reason')),
          findsNothing,
        ); // se cerró

        await tester.tap(
          find.widgetWithText(OutlinedButton, 'Eliminar prenda'),
        );
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(5, 5)); // fuera del diálogo
        await tester.pumpAndSettle();
        expect(server.harness.adapter.to(ApiEndpoints.garmentsDelete), isEmpty);
        expect(find.text('Cadena cubana'), findsWidgets); // sigue ahí
      },
    );

    testWidgets('el menú ⋮ y el menú de la lista abren el MISMO diálogo', (
      tester,
    ) async {
      final (server, _) = await _open(tester);
      server.writes[ApiEndpoints.garmentsDelete] = () => {'id_prenda': 11};

      await tester.longPress(find.text('Cadena cubana'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Eliminar prenda'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('delete_reason')), findsOneWidget);
      expect(server.harness.adapter.to(ApiEndpoints.garmentsDelete), isEmpty);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancelar'));
      await tester.pumpAndSettle();

      await _openDetail(tester);
      await tester.tap(find.byTooltip('Más acciones'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar prenda').last);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('delete_reason')), findsOneWidget);
      expect(server.harness.adapter.to(ApiEndpoints.garmentsDelete), isEmpty);
    });

    testWidgets(
      'eliminar varias: Cancelar no envía; confirmar envía una por prenda',
      (tester) async {
        final (server, _) = await _open(
          tester,
          rows: [
            garmentRow(),
            garmentRow(id: 12, name: 'dije corazón'),
          ],
        );
        server.writes[ApiEndpoints.garmentsDelete] = () => {'id_prenda': 0};
        await tester.longPress(find.text('Cadena cubana'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ListTile, 'Seleccionar varias'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Dije corazón'));
        await tester.pumpAndSettle();

        await tester.tap(
          find.widgetWithText(FilledButton, 'Eliminar 2 seleccionadas'),
        );
        await tester.pumpAndSettle();
        expect(server.harness.adapter.to(ApiEndpoints.garmentsDelete), isEmpty);
        await tester.tap(find.widgetWithText(OutlinedButton, 'Cancelar'));
        await tester.pumpAndSettle();
        expect(server.harness.adapter.to(ApiEndpoints.garmentsDelete), isEmpty);
        expect(find.text('Cadena cubana'), findsOneWidget); // ninguna salió
        expect(find.text('Dije corazón'), findsOneWidget);

        await tester.tap(
          find.widgetWithText(FilledButton, 'Eliminar 2 seleccionadas'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Eliminar 2'));
        await tester.pumpAndSettle();
        expect(
          server.harness.adapter.to(ApiEndpoints.garmentsDelete),
          hasLength(2),
        );
        await _letToastGo(tester);
      },
    );

    testWidgets(
      'quitar una foto: Cancelar no envía; confirmar envía una sola vez',
      (tester) async {
        final (server, _) = await _open(tester);
        server.images = [
          {
            'id_imagen': 5,
            'orden': 1,
            'url_miniatura': 'https://x.test/m.jpg',
            'url_grande': 'https://x.test/g.jpg',
          },
        ];
        server.writes[ApiEndpoints.garmentsImageRemove] = () => {
          'id_imagen': 5,
        };
        await _openDetail(tester);

        await tester.tap(find.byTooltip('Quitar foto'));
        await tester.pumpAndSettle();
        expect(
          server.harness.adapter.to(ApiEndpoints.garmentsImageRemove),
          isEmpty,
        );
        await tester.tap(find.widgetWithText(OutlinedButton, 'Cancelar'));
        await tester.pumpAndSettle();
        expect(
          server.harness.adapter.to(ApiEndpoints.garmentsImageRemove),
          isEmpty,
        );

        await tester.tap(find.byTooltip('Quitar foto'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Quitar foto'));
        await tester.pumpAndSettle();
        final calls = server.harness.adapter.to(
          ApiEndpoints.garmentsImageRemove,
        );
        expect(calls, hasLength(1));
        expect(calls.single.bodyMap, {'id_imagen': 5});
        await dismissToasts(tester);
      },
    );

    testWidgets(
      'el diálogo de confirmar no desborda a 320 y 390 con letra 1.5',
      (tester) async {
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        for (final width in [320.0, 390.0]) {
          final (server, _) = await _open(tester, width: width);
          server.images = [
            {
              'id_imagen': 5,
              'orden': 1,
              'url_miniatura': 'https://x.test/m.jpg',
              'url_grande': 'https://x.test/g.jpg',
            },
          ];
          await _openDetail(tester);
          await tester.tap(find.byTooltip('Quitar foto'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$width');
          await tester.pumpWidget(const SizedBox());
        }
      },
    );
  });

  group('eliminar prenda', () {
    Future<void> confirmDelete(WidgetTester tester, {String? reason}) async {
      await _revealDelete(tester);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Eliminar prenda'));
      await tester.pumpAndSettle();
      if (reason != null) {
        await tester.enterText(find.byKey(const Key('delete_reason')), reason);
      }
      await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
      await tester.pumpAndSettle();
    }

    testWidgets('envía el cuerpo del contrato, avisa y sale de la lista', (
      tester,
    ) async {
      final (server, _) = await _open(
        tester,
        rows: [
          garmentRow(),
          garmentRow(id: 12, name: 'dije corazón'),
        ],
      );
      server.writes[ApiEndpoints.garmentsDelete] = () => {'id_prenda': 11};
      final gate = server.hold(ApiEndpoints.garmentsDelete);
      await _openDetail(tester);

      await confirmDelete(tester, reason: 'Duplicada');
      gate.complete();
      await tester.pumpAndSettle();

      final request = server.harness.adapter
          .to(ApiEndpoints.garmentsDelete)
          .single;
      expect(request.method, 'POST');
      expect(request.authorization, 'Bearer tok');
      expect(request.bodyMap, {'id': 11, 'motivo': 'Duplicada'});
      expect(find.text('Prenda eliminada'), findsOneWidget);
      // De vuelta en el inventario, sin la prenda eliminada.
      expect(find.text('Cadena cubana'), findsNothing);
      expect(find.text('Dije corazón'), findsOneWidget);
      await _letToastGo(tester);
    });

    testWidgets('sin motivo no envía el campo', (tester) async {
      final (server, _) = await _open(tester);
      server.writes[ApiEndpoints.garmentsDelete] = () => {'id_prenda': 11};
      final gate = server.hold(ApiEndpoints.garmentsDelete);
      await _openDetail(tester);

      await confirmDelete(tester);
      gate.complete();
      await tester.pumpAndSettle();

      expect(
        server.harness.adapter.to(ApiEndpoints.garmentsDelete).single.bodyMap,
        {'id': 11},
      );
      await _letToastGo(tester);
    });

    testWidgets('sale de la lista al instante, sin esperar al servidor', (
      tester,
    ) async {
      final (server, _) = await _open(tester);
      final gate = server.hold(ApiEndpoints.garmentsDelete);
      server.writes[ApiEndpoints.garmentsDelete] = () => {'id_prenda': 11};
      await _openDetail(tester);

      await confirmDelete(tester);

      // El servidor aún no contestó, pero la prenda ya no está y se volvió al inventario.
      expect(find.text('Sin prendas'), findsOneWidget);
      expect(find.text('Prenda eliminada'), findsNothing);
      gate.complete();
      await tester.pumpAndSettle();
      expect(find.text('Prenda eliminada'), findsOneWidget);
      await _letToastGo(tester);
    });

    testWidgets(
      'con pendientes el servidor la rechaza: vuelve con el mensaje',
      (tester) async {
        final (server, _) = await _open(tester);
        const message =
            'Esta prenda tiene 2 solicitudes o separados pendientes. '
            'Resuélvelos antes de eliminarla.';
        final gate = server.hold(ApiEndpoints.garmentsDelete);
        server.rejects[ApiEndpoints.garmentsDelete] = (422, message);
        await _openDetail(tester);

        await confirmDelete(tester);
        expect(find.text('Sin prendas'), findsOneWidget); // salió al instante

        gate.complete();
        await tester.pumpAndSettle();
        expect(find.text(message), findsOneWidget);
        expect(find.text('Cadena cubana'), findsOneWidget); // volvió a su sitio
        expect(find.text('Sin prendas'), findsNothing);
        await _letToastGo(tester);
      },
    );

    testWidgets('mantener pulsada la tarjeta abre el menú con Eliminar', (
      tester,
    ) async {
      final (server, _) = await _open(tester);
      server.writes[ApiEndpoints.garmentsDelete] = () => {'id_prenda': 11};
      final gate = server.hold(ApiEndpoints.garmentsDelete);

      await tester.longPress(find.text('Cadena cubana'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Eliminar prenda'));
      await tester.pumpAndSettle();
      // Ocultar (reversible) y eliminar son acciones distintas y claras.
      expect(
        find.widgetWithText(TextButton, 'Ocultar en vez de eliminar'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
      await tester.pumpAndSettle();
      gate.complete();
      await tester.pumpAndSettle();

      expect(
        server.harness.adapter.to(ApiEndpoints.garmentsDelete),
        hasLength(1),
      );
      expect(find.text('Cadena cubana'), findsNothing);
      expect(find.text('Sin prendas'), findsOneWidget);
      await _letToastGo(tester);
    });

    testWidgets('quien no tiene el permiso no ve dónde eliminar', (
      tester,
    ) async {
      await _open(tester, permissions: viewerGarmentPermissions);
      // Sin permiso no hay menú: mantener pulsada solo abre la prenda.
      await tester.longPress(find.text('Cadena cubana'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('Eliminar prenda'), findsNothing);
      expect(
        find.text('Cadena de eslabones cubanos'),
        findsOneWidget,
      ); // detalle
      expect(find.byTooltip('Más acciones'), findsNothing);
    });

    testWidgets('el diálogo no desborda a 320 y 390 con letra 1.5', (
      tester,
    ) async {
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      for (final width in [320.0, 390.0]) {
        await _open(tester, width: width);
        await _openDetail(tester);
        await _revealDelete(tester);
        await tester.tap(
          find.widgetWithText(OutlinedButton, 'Eliminar prenda'),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$width');
        expect(
          find.widgetWithText(TextButton, 'Ocultar en vez de eliminar'),
          findsOneWidget,
        );
        // Con el teclado abierto también.
        await tester.tap(find.byKey(const Key('delete_reason')));
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$width + teclado');
        tester.view.resetViewInsets();
        await tester.pumpWidget(const SizedBox());
      }
    });
  });

  group('ocultar vs eliminar y selección múltiple', () {
    Future<void> revealButton(WidgetTester tester, String label) async {
      final button = find.widgetWithText(OutlinedButton, label);
      await tester.scrollUntilVisible(
        button,
        200,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
    }

    testWidgets('ocultar reenvía la prenda COMPLETA con activa en falso', (
      tester,
    ) async {
      final (server, _) = await _open(tester);
      server.writes[ApiEndpoints.garmentsEdit] = () => {'id_prenda': 11};
      await _openDetail(tester);

      await revealButton(tester, 'Ocultar del catálogo');
      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Ocultar del catálogo'),
      );
      await tester.pumpAndSettle();

      final body = server.harness.adapter
          .to(ApiEndpoints.garmentsEdit)
          .single
          .bodyMap;
      expect(body['id'], 11);
      expect(body['activa'], false);
      // La descripción viaja: la fila de la lista no la trae, el detalle sí.
      expect(body['descripcion'], 'Cadena de eslabones cubanos');
      expect(body.containsKey('precio_compra'), isFalse); // el costo no se toca
      expect(find.text('Prenda oculta del catálogo'), findsOneWidget);
      await _letToastGo(tester);
    });

    testWidgets('desde el diálogo de eliminar también se puede ocultar', (
      tester,
    ) async {
      final (server, _) = await _open(tester);
      server.writes[ApiEndpoints.garmentsEdit] = () => {'id_prenda': 11};

      await tester.longPress(find.text('Cadena cubana'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Eliminar prenda'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(TextButton, 'Ocultar en vez de eliminar'),
      );
      await tester.pumpAndSettle();

      expect(server.harness.adapter.to(ApiEndpoints.garmentsDelete), isEmpty);
      final body = server.harness.adapter
          .to(ApiEndpoints.garmentsEdit)
          .single
          .bodyMap;
      expect(body['descripcion'], 'Cadena de eslabones cubanos');
      await _letToastGo(tester);
    });

    testWidgets('«Ocultas» lista solo las ocultas y se pueden eliminar', (
      tester,
    ) async {
      final (server, _) = await _open(
        tester,
        rows: [
          garmentRow(),
          garmentRow(id: 12, name: 'dije corazón', active: false),
        ],
      );
      server.writes[ApiEndpoints.garmentsDelete] = () => {'id_prenda': 12};

      await tester.tap(find.text('Ocultas'));
      await tester.pumpAndSettle();
      expect(find.text('Cadena cubana'), findsNothing);
      expect(find.text('Dije corazón'), findsOneWidget);
      expect(find.text('Oculta'), findsOneWidget); // chip

      await tester.longPress(find.text('Dije corazón'));
      await tester.pumpAndSettle();
      // Una oculta ya no ofrece ocultar, sí mostrar y eliminar.
      expect(find.text('Mostrar en el catálogo'), findsOneWidget);
      await tester.tap(find.widgetWithText(ListTile, 'Eliminar prenda'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(TextButton, 'Ocultar en vez de eliminar'),
        findsNothing,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
      await tester.pumpAndSettle();

      expect(
        server.harness.adapter.to(ApiEndpoints.garmentsDelete).single.bodyMap,
        {'id': 12},
      );
      expect(find.text('Dije corazón'), findsNothing);
      await _letToastGo(tester);
    });

    Future<GarmentsServer> selectTwo(
      WidgetTester tester, {
      Map<int, (int, String)> rejects = const {},
    }) async {
      final (server, _) = await _open(
        tester,
        rows: [
          garmentRow(),
          garmentRow(id: 12, name: 'dije corazón'),
          garmentRow(id: 13, name: 'topos perla'),
        ],
      );
      server.writes[ApiEndpoints.garmentsDelete] = () => {'id_prenda': 0};
      server.deleteRejects.addAll(rejects);
      await tester.longPress(find.text('Topos perla'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Seleccionar varias'));
      await tester.pumpAndSettle();
      expect(find.text('1 seleccionada'), findsOneWidget);
      await tester.tap(find.text('Dije corazón')); // ya en modo selección
      await tester.pumpAndSettle();
      expect(find.text('2 seleccionadas'), findsOneWidget);
      return server;
    }

    testWidgets('«Eliminar seleccionadas» las elimina una por una', (
      tester,
    ) async {
      final server = await selectTwo(tester);
      await tester.tap(
        find.widgetWithText(FilledButton, 'Eliminar 2 seleccionadas'),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('delete_reason')),
        'Vendidas',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Eliminar 2'));
      await tester.pumpAndSettle();

      final bodies = server.harness.adapter
          .to(ApiEndpoints.garmentsDelete)
          .map((r) => r.bodyMap)
          .toList();
      // Una por una, en el orden de la lista.
      expect(bodies, [
        {'id': 12, 'motivo': 'Vendidas'},
        {'id': 13, 'motivo': 'Vendidas'},
      ]);
      expect(find.text('2 prendas eliminadas'), findsOneWidget);
      expect(find.text('Cadena cubana'), findsOneWidget);
      expect(find.text('Topos perla'), findsNothing);
      expect(find.text('Dije corazón'), findsNothing);
      expect(find.text('2 seleccionadas'), findsNothing); // salió del modo
      await _letToastGo(tester);
    });

    testWidgets('si una se rechaza: resumen con el motivo y vuelve a la lista', (
      tester,
    ) async {
      const reason =
          'Esta prenda tiene 1 solicitud o separado pendiente. Resuélvelo antes de eliminarla.';
      final server = await selectTwo(tester, rejects: {12: (422, reason)});
      await tester.tap(
        find.widgetWithText(FilledButton, 'Eliminar 2 seleccionadas'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Eliminar 2'));
      await tester.pumpAndSettle();

      expect(
        server.harness.adapter.to(ApiEndpoints.garmentsDelete),
        hasLength(2),
      );
      expect(
        find.text('Se eliminaron 1, 1 no se pudo: $reason'),
        findsOneWidget,
      );
      expect(find.text('Dije corazón'), findsOneWidget); // volvió
      expect(find.text('Topos perla'), findsNothing); // esa sí se eliminó
      await _letToastGo(tester);
    });

    testWidgets('entrar en selección no cambia el alto de la tarjeta', (
      tester,
    ) async {
      final (_, _) = await _open(tester);
      final card = find.ancestor(
        of: find.text('Cadena cubana'),
        matching: find.byType(Card),
      );
      final before = tester.getSize(card.first);
      await tester.longPress(find.text('Cadena cubana'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Seleccionar varias'));
      await tester.pumpAndSettle();
      expect(tester.getSize(card.first), before);
    });

    testWidgets('cambiar de pestaña descarta la selección', (tester) async {
      final (_, _) = await _open(
        tester,
        rows: [
          garmentRow(),
          garmentRow(id: 12, name: 'dije corazón', stock: 0),
        ],
      );
      await tester.longPress(find.text('Cadena cubana'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Seleccionar varias'));
      await tester.pumpAndSettle();
      expect(find.text('1 seleccionada'), findsOneWidget);

      await tester.tap(find.text('Agotadas'));
      await tester.pumpAndSettle();
      // Nada que ya no se vea queda marcado (ni se podría eliminar).
      expect(find.text('1 seleccionada'), findsNothing);
      expect(find.textContaining('Eliminar 1 seleccionada'), findsNothing);
    });

    testWidgets('con el teclado abierto la barra «Eliminar N» se esconde', (
      tester,
    ) async {
      final (_, _) = await _open(tester);
      await tester.longPress(find.text('Cadena cubana'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Seleccionar varias'));
      await tester.pumpAndSettle();
      expect(find.text('Eliminar 1 seleccionada'), findsOneWidget);

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(find.text('Eliminar 1 seleccionada'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('selección y pestaña de cuatro opciones sin desbordes', (
      tester,
    ) async {
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      for (final width in [320.0, 390.0]) {
        await _open(tester, width: width);
        expect(tester.takeException(), isNull, reason: 'pestañas $width');
        await tester.longPress(find.text('Cadena cubana'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'menú $width');
        await tester.tap(find.widgetWithText(ListTile, 'Seleccionar varias'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'selección $width');
        await tester.tap(
          find.widgetWithText(FilledButton, 'Eliminar 1 seleccionada'),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'diálogo $width');
        await tester.pumpWidget(const SizedBox());
      }
    });
  });

  group('lista de prendas', () {
    testWidgets('muestra el inventario con precio, stock y pestañas', (
      tester,
    ) async {
      await _open(
        tester,
        rows: [
          garmentRow(),
          garmentRow(id: 12, name: 'dije corazón', stock: 0),
        ],
      );

      expect(find.text('Cadena cubana'), findsOneWidget);
      expect(find.text(r'$ 1.000.000'), findsWidgets);
      expect(find.text('2 unidades'), findsOneWidget);
      expect(find.text('Agotada'), findsOneWidget);

      await tester.tap(find.text('Agotadas'));
      await tester.pumpAndSettle();
      expect(find.text('Cadena cubana'), findsNothing);
      expect(find.text('Dije corazón'), findsOneWidget);
    });

    testWidgets('sin prendas muestra el vacío', (tester) async {
      await _open(tester, rows: []);
      expect(find.text('Sin prendas'), findsOneWidget);
    });
  });

  group('crear y editar', () {
    testWidgets('crear envía el cuerpo del contrato y abre el detalle', (
      tester,
    ) async {
      final (server, _) = await _open(tester);
      server.writes[ApiEndpoints.garmentsCreate] = () {
        server.rows.add(garmentRow(id: 12, name: 'pulsera tejida'));
        return {'id_prenda': 12};
      };

      await _fillNewGarment(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Crear prenda'));
      await tester.pumpAndSettle();

      final request = server.harness.adapter
          .to(ApiEndpoints.garmentsCreate)
          .single;
      expect(request.method, 'POST');
      expect(request.authorization, 'Bearer tok');
      expect(request.bodyMap, {
        'id_tipo': 2,
        'nombre': 'Pulsera tejida',
        'tipo_oro': 'NACIONAL',
        'peso_gramos': '4.50',
        'precio_venta': '850000.00',
        'stock': 1,
      });
      expect(find.text('Prenda creada'), findsOneWidget);
      expect(find.text('Fotos'), findsOneWidget); // abrió el detalle
      await dismissToasts(tester);
    });

    testWidgets(
      'crear con fotos: sube cada foto, cierra el diálogo y abre el detalle',
      (tester) async {
        final (server, picker) = await _open(tester);
        picker.result = PickResult(image: FakeImagePicker.sample);
        server.writes[ApiEndpoints.garmentsCreate] = () {
          server.rows.add(garmentRow(id: 12, name: 'pulsera tejida'));
          return {'id_prenda': 12};
        };
        server.writes[ApiEndpoints.garmentsImageAdd] = () => {
          'id_imagen': 1,
          'orden': 1,
          'url_miniatura': 'https://x.test/m.jpg',
          'url_grande': 'https://x.test/g.jpg',
        };

        await _fillNewGarment(tester);
        for (var i = 0; i < 2; i++) {
          await tester.ensureVisible(find.byIcon(Icons.add_a_photo_outlined));
          await tester.tap(find.byIcon(Icons.add_a_photo_outlined));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.widgetWithText(FilledButton, 'Crear prenda'));
        await tester.pumpAndSettle();

        final uploads = server.harness.adapter.to(
          ApiEndpoints.garmentsImageAdd,
        );
        // La primera sale sola (con ella ya hay miniatura) y luego la segunda.
        expect(uploads.map((r) => r.formFields['orden']).toList(), ['1', '2']);
        expect(
          find.text('Prenda creada. Las fotos se suben en segundo plano.'),
          findsOneWidget,
        );
        expect(
          find.text('Crear prenda'),
          findsNothing,
          reason: 'el diálogo debe cerrarse (antes se quedaba cargando)',
        );
        expect(find.text('Fotos'), findsOneWidget); // abrió el detalle
        await dismissToasts(tester);
      },
    );

    testWidgets(
      'si las fotos fallan, la prenda queda creada y se puede reintentar',
      (tester) async {
        final (server, picker) = await _open(tester);
        picker.result = PickResult(image: FakeImagePicker.sample);
        server.writes[ApiEndpoints.garmentsCreate] = () {
          server.rows.add(garmentRow(id: 12, name: 'pulsera tejida'));
          return {'id_prenda': 12};
        };
        server.failing.add(ApiEndpoints.garmentsImageAdd);

        await _fillNewGarment(tester);
        await tester.ensureVisible(find.byIcon(Icons.add_a_photo_outlined));
        await tester.tap(find.byIcon(Icons.add_a_photo_outlined));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Crear prenda'));
        await tester.pumpAndSettle();
        // Tres intentos con espera entre ellos.
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();

        expect(find.text('Crear prenda'), findsNothing); // no queda colgado
        expect(find.text('Fotos'), findsOneWidget); // abrió el detalle
        expect(
          server.harness.adapter.to(ApiEndpoints.garmentsImageAdd),
          hasLength(3),
        );
        expect(
          find.text('Algunas fotos no se pudieron subir.'),
          findsOneWidget,
        );

        // Vuelve la red: «Reintentar» la sube y el aviso desaparece.
        server.failing.clear();
        server.writes[ApiEndpoints.garmentsImageAdd] = () => {
          'id_imagen': 1,
          'orden': 1,
          'url_miniatura': 'https://x.test/m.jpg',
          'url_grande': 'https://x.test/g.jpg',
        };
        await tester.tap(find.text('Reintentar'));
        await tester.pumpAndSettle();
        expect(find.text('Algunas fotos no se pudieron subir.'), findsNothing);
        await dismissToasts(tester);
      },
    );

    testWidgets('un precio anterior menor al de venta no se envía', (
      tester,
    ) async {
      final (server, _) = await _open(tester);
      await _fillNewGarment(tester);
      await tester.enterText(
        find.byKey(const Key('garment_previous_price')),
        '500000',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Crear prenda'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Debe ser mayor al precio de venta'),
        findsOneWidget,
      );
      expect(server.harness.adapter.to(ApiEndpoints.garmentsCreate), isEmpty);
    });

    testWidgets(
      'editar envía el id, la actividad y deja el costo si no se toca',
      (tester) async {
        final (server, _) = await _open(tester);
        server.writes[ApiEndpoints.garmentsEdit] = () => {'id_prenda': 11};
        await _openDetail(tester);

        await tester.tap(find.byTooltip('Editar prenda'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('garment_name')),
          'Cadena cubana 18k',
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Guardar cambios'));
        await tester.pumpAndSettle();

        final request = server.harness.adapter
            .to(ApiEndpoints.garmentsEdit)
            .single;
        expect(request.bodyMap['id'], 11);
        expect(request.bodyMap['nombre'], 'Cadena cubana 18k');
        expect(request.bodyMap['activa'], true);
        expect(request.bodyMap['precio_compra'], '700000.00');
        expect(request.bodyMap.containsKey('precio_anterior'), isFalse);
        expect(request.bodyMap.containsKey('stock'), isFalse);
        expect(find.text('Prenda actualizada'), findsOneWidget);
        await dismissToasts(tester);
      },
    );

    testWidgets(
      'sin permiso de costo no se ve ni se envía el precio de compra',
      (tester) async {
        final (server, _) = await _open(
          tester,
          permissions: ['prendas.ver', 'prendas.crear', 'tipos.gestionar'],
          rows: [garmentRow(purchase: null)],
        );
        server.writes[ApiEndpoints.garmentsCreate] = () => {'id_prenda': 12};

        await _fillNewGarment(tester);
        expect(find.byKey(const Key('garment_purchase_price')), findsNothing);
        await tester.tap(find.widgetWithText(FilledButton, 'Crear prenda'));
        await tester.pumpAndSettle();

        final body = server.harness.adapter
            .to(ApiEndpoints.garmentsCreate)
            .single
            .bodyMap;
        expect(body.containsKey('precio_compra'), isFalse);
        await dismissToasts(tester);
      },
    );
  });

  group('stock y fotos', () {
    testWidgets('ajustar stock envía la cantidad y el motivo', (tester) async {
      final (server, _) = await _open(tester);
      server.writes[ApiEndpoints.garmentsAdjustStock] = () => {
        'id_prenda': 11,
        'stock': 5,
      };
      await _openDetail(tester);

      await tester.scrollUntilVisible(find.byTooltip('Ajustar stock'), 200);
      await tester.ensureVisible(find.byTooltip('Ajustar stock'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Ajustar stock'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('stock_delta')), '3');
      await tester.enterText(
        find.byKey(const Key('stock_reason')),
        'Llegó mercancía',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar ajuste'));
      await tester.pumpAndSettle();

      final request = server.harness.adapter
          .to(ApiEndpoints.garmentsAdjustStock)
          .single;
      expect(request.bodyMap, {
        'id': 11,
        'cantidad': 3,
        'motivo': 'Llegó mercancía',
      });
      expect(find.text('Stock actualizado'), findsOneWidget);
      await dismissToasts(tester);
    });

    testWidgets('quitar más unidades de las que hay no se envía', (
      tester,
    ) async {
      final (server, _) = await _open(tester);
      await _openDetail(tester);

      await tester.scrollUntilVisible(find.byTooltip('Ajustar stock'), 200);
      await tester.ensureVisible(find.byTooltip('Ajustar stock'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Ajustar stock'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('stock_delta')), '-5');
      await tester.enterText(
        find.byKey(const Key('stock_reason')),
        'Error de conteo',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar ajuste'));
      await tester.pumpAndSettle();

      expect(find.textContaining('No puedes quitar más'), findsOneWidget);
      expect(
        server.harness.adapter.to(ApiEndpoints.garmentsAdjustStock),
        isEmpty,
      );
    });

    testWidgets('agregar una foto la sube como multipart con su orden', (
      tester,
    ) async {
      final (server, picker) = await _open(tester);
      server.writes[ApiEndpoints.garmentsImageAdd] = () => {
        'id_imagen': 1,
        'orden': 1,
        'url_miniatura': 'https://x.test/m.jpg',
        'url_grande': 'https://x.test/g.jpg',
      };
      await _openDetail(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Agregar foto'));
      await tester.pumpAndSettle();

      expect(picker.picks, 1);
      final request = server.harness.adapter
          .to(ApiEndpoints.garmentsImageAdd)
          .single;
      expect(request.formFields, {'id': '11', 'orden': '1'});
      expect(request.formFileNames, ['imagen']);
      expect(find.text('Foto agregada'), findsOneWidget);
      await dismissToasts(tester);
    });

    testWidgets('quien solo ve no tiene botones de edición', (tester) async {
      await _open(tester, permissions: viewerGarmentPermissions);
      expect(find.text('Nueva prenda'), findsNothing);
      await _openDetail(tester);
      expect(find.byTooltip('Editar prenda'), findsNothing);
      expect(find.text('Agregar foto'), findsNothing);
    });
  });

  testWidgets(
    'el formulario de prenda no desborda en teléfono pequeño con teclado',
    (tester) async {
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await _open(tester, width: 320, height: 700);

      await tester.tap(find.text('Nueva prenda'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );
}
