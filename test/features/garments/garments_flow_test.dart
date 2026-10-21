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
        expect(uploads.map((r) => r.formFields['orden']).toList(), ['1', '2']);
        expect(
          find.text('Crear prenda'),
          findsNothing,
          reason: 'el diálogo debe cerrarse (antes se quedaba cargando)',
        );
        expect(find.text('Fotos'), findsOneWidget); // abrió el detalle
        await dismissToasts(tester);
      },
    );

    testWidgets('si las fotos fallan, la prenda queda creada y se avisa', (
      tester,
    ) async {
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

      expect(find.textContaining('1 foto no se pudo subir'), findsOneWidget);
      expect(find.text('Crear prenda'), findsNothing); // no queda colgado
      expect(
        find.text('Fotos'),
        findsOneWidget,
      ); // abrió el detalle para reintentar
      await dismissToasts(tester);
    });

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
