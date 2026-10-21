import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';

import 'package:sistema_oro/features/settings/widgets/brand_logo_preview.dart';
import 'package:sistema_oro/shared/widgets/brand_logo_image.dart';

import '../../helpers/admin_server.dart';
import '../../helpers/order_fixtures.dart';
import '../../support/api_harness.dart';
import '../../support/fake_api_adapter.dart';
import '../../support/fake_image_picker.dart';
import '../../support/form_request.dart';
import '../../support/pump_at_sizes.dart';

Map<String, dynamic> _setting(
  String key,
  String value,
  String type, [
  String description = '',
]) => {
  'clave': key,
  'valor': value,
  'tipo': type,
  'descripcion': description,
  'publico': true,
  'actualizado_en': null,
};

final _list = [
  _setting('whatsapp_baron', '573001234567', 'TEXTO'),
  _setting('transferencia_banco', 'Bancolombia', 'TEXTO'),
  _setting('porcentaje_separado', '20', 'PORCENTAJE'),
  _setting('recargo_mes_vencido', '80000.00', 'DINERO'),
  _setting('precio_caja_decorada', '12000.00', 'DINERO'),
  _setting('catalogo_mostrar_agotadas', '0', 'BOOLEANO'),
];

Map<String, dynamic> _logo(String url, int version) => {
  'logo_url': url,
  'logo_version': version,
};

Future<AdminServer> _open(
  WidgetTester tester, {
  List<String> extra = const ['ajustes.editar'],
  bool customLogo = false,
  FakeImagePicker? picker,
}) async {
  final server = AdminServer(
    permissions: ['ajustes.ver', 'resumen.ver', ...extra],
    routes: {
      ApiEndpoints.settingsList: (_) => _list,
      ApiEndpoints.settingsSave: (_) =>
          _setting('porcentaje_separado', '30', 'PORCENTAJE'),
      ApiEndpoints.settingsLogo: (_) => customLogo
          ? _logo('https://x.test/uploads/logo/a.png?v=3', 3)
          : _logo('', 0),
      ApiEndpoints.settingsLogoUpload: (_) =>
          _logo('https://x.test/uploads/logo/b.png?v=4', 4),
      ApiEndpoints.settingsLogoRestore: (_) => _logo('', 5),
    },
  );
  await pumpAdminApp(
    tester,
    height: 1600, // el logo va arriba y empuja los ajustes hacia abajo
    overrides: [
      ...server.harness.overrides,
      if (picker != null) imagePickerServiceProvider.overrideWithValue(picker),
    ],
  );
  await tester.tap(find.text('Más').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Ajustes'));
  await tester.pumpAndSettle();
  return server;
}

/// Abre Ajustes con un servidor cuya ruta `logo_ver` la decide [logo] (para
/// retrasarla o hacerla fallar). Sin `pumpAndSettle` mientras carga: el
/// indicador de progreso nunca se asienta.
Future<ApiHarness> _openWithLogo(
  WidgetTester tester,
  Future<ResponseBody> Function(int call) logo,
) async {
  var calls = 0;
  final harness = ApiHarness(
    FakeApiAdapter((o) async {
      if (o.path == ApiEndpoints.profile) {
        return FakeApiAdapter.jsonResponse(
          profileJson(['ajustes.ver', 'ajustes.editar', 'resumen.ver']),
          200,
        );
      }
      if (o.path == ApiEndpoints.settingsList) {
        return FakeApiAdapter.jsonResponse({
          'success': true,
          'data': _list,
        }, 200);
      }
      if (o.path == ApiEndpoints.settingsLogo) return logo(++calls);
      return FakeApiAdapter.jsonResponse({
        'success': false,
        'codigo': 'NO_ENCONTRADO',
        'error': 'Ruta de prueba no programada: ${o.path}',
      }, 404);
    }),
  );
  await pumpAdminApp(tester, height: 1600, overrides: harness.overrides);
  await tester.tap(find.text('Más').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Ajustes'));
  await tester.pump(const Duration(milliseconds: 300));
  return harness;
}

ResponseBody _logoOk(String url, int version) => FakeApiAdapter.jsonResponse({
  'success': true,
  'data': _logo(url, version),
}, 200);

void main() {
  testWidgets('muestra los ajustes agrupados y con el formato de la app', (
    tester,
  ) async {
    await _open(tester);

    expect(find.text('Datos de pago'), findsOneWidget);
    expect(find.text('WhatsApp de Barón'), findsOneWidget);
    expect(find.text('573001234567'), findsOneWidget);
    expect(find.text('20 %'), findsOneWidget);
    expect(find.text(r'$ 80.000'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
  });

  testWidgets('cambiar el porcentaje envía la clave y el valor', (
    tester,
  ) async {
    final server = await _open(tester);

    await tester.tap(find.text('Porcentaje para separar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('setting_value')), '30');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar ajuste'));
    await tester.pumpAndSettle();

    final request = server.harness.adapter.to(ApiEndpoints.settingsSave).single;
    expect(request.bodyMap, {'clave': 'porcentaje_separado', 'valor': '30'});
    expect(find.text('Ajuste guardado'), findsOneWidget);
    await dismissToasts(tester);
  });

  testWidgets('el dinero se envía como texto con 2 decimales', (tester) async {
    final server = await _open(tester);

    await tester.tap(find.text('Recargo por mes vencido'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('setting_value')), '90000');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar ajuste'));
    await tester.pumpAndSettle();

    expect(
      server.harness.adapter.to(ApiEndpoints.settingsSave).single.bodyMap,
      {'clave': 'recargo_mes_vencido', 'valor': '90000.00'},
    );
    await dismissToasts(tester);
  });

  testWidgets('un porcentaje fuera de rango no se envía', (tester) async {
    final server = await _open(tester);

    await tester.tap(find.text('Porcentaje para separar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('setting_value')), '150');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar ajuste'));
    await tester.pumpAndSettle();

    expect(find.textContaining('entre 1 y 100'), findsOneWidget);
    expect(server.harness.adapter.to(ApiEndpoints.settingsSave), isEmpty);
  });

  testWidgets('sin permiso de editar no se abre el diálogo', (tester) async {
    await _open(tester, extra: const []);
    await tester.tap(find.text('Porcentaje para separar'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('setting_value')), findsNothing);
  });

  group('logo de la marca', () {
    testWidgets('el dueño elige un logo: se envía la imagen y se avisa', (
      tester,
    ) async {
      final picker = FakeImagePicker(
        result: PickResult(image: FakeImagePicker.sample),
      );
      final server = await _open(tester, picker: picker);
      expect(find.text('Logo de la marca'), findsOneWidget);
      expect(
        find.text('Restaurar logo original'),
        findsNothing,
      ); // aún el original

      await tester.tap(find.widgetWithText(FilledButton, 'Cambiar logo'));
      await tester.pumpAndSettle();

      final request = server.harness.adapter
          .to(ApiEndpoints.settingsLogoUpload)
          .single;
      expect(request.method, 'POST');
      expect(request.formFileNames, ['imagen']);
      expect(find.textContaining('Logo actualizado'), findsOneWidget);
      expect(find.text('Restaurar logo original'), findsOneWidget);
      await dismissToasts(tester);
    });

    testWidgets('restaurar pide confirmación y vuelve al logo original', (
      tester,
    ) async {
      final server = await _open(tester, customLogo: true);

      await tester.tap(find.text('Restaurar logo original'));
      await tester.pumpAndSettle();
      expect(
        server.harness.adapter.to(ApiEndpoints.settingsLogoRestore),
        isEmpty,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Restaurar'));
      await tester.pumpAndSettle();

      expect(
        server.harness.adapter.to(ApiEndpoints.settingsLogoRestore),
        hasLength(1),
      );
      expect(find.textContaining('logo original'), findsWidgets);
      expect(find.text('Restaurar logo original'), findsNothing);
      await dismissToasts(tester);
    });

    testWidgets('una imagen que no sirve no se envía', (tester) async {
      final picker = FakeImagePicker(
        result: const PickResult(problem: 'La imagen pesa más de 4 MB.'),
      );
      final server = await _open(tester, picker: picker);
      await tester.tap(find.widgetWithText(FilledButton, 'Cambiar logo'));
      await tester.pumpAndSettle();
      expect(
        server.harness.adapter.to(ApiEndpoints.settingsLogoUpload),
        isEmpty,
      );
      expect(find.text('La imagen pesa más de 4 MB.'), findsOneWidget);
      await dismissToasts(tester);
    });

    testWidgets('sin permiso de editar solo se ve la vista previa', (
      tester,
    ) async {
      await _open(tester, extra: const []);
      expect(find.text('Logo de la marca'), findsOneWidget);
      expect(find.text('Cambiar logo'), findsNothing);
    });

    testWidgets('mientras carga muestra el indicador, no el logo como actual', (
      tester,
    ) async {
      final pending = Completer<ResponseBody>();
      await _openWithLogo(tester, (_) => pending.future);

      expect(find.text('Logo de la marca'), findsOneWidget);
      final preview = find.byType(BrandLogoPreview);
      expect(
        find.descendant(
          of: preview,
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: preview, matching: find.byType(BrandLogoImage)),
        findsNothing,
      );
      expect(find.text('Restaurar logo original'), findsNothing);

      // Llega el logo propio: el indicador se va y aparece «Restaurar».
      pending.complete(_logoOk('https://x.test/uploads/logo/a.png?v=3', 3));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Restaurar logo original'), findsOneWidget);
    });

    for (final status in [404, 500]) {
      testWidgets(
        'si falla ($status) avisa y «Intentar nuevamente» reintenta',
        (tester) async {
          final h = await _openWithLogo(tester, (call) async {
            if (call == 1) {
              return FakeApiAdapter.jsonResponse({
                'success': false,
                'codigo': 'ERROR',
                'error': 'El servidor no respondió.',
              }, status);
            }
            return _logoOk('https://x.test/uploads/logo/a.png?v=3', 3);
          });
          await tester.pumpAndSettle();

          expect(
            find.textContaining('No se pudo cargar el logo'),
            findsOneWidget,
          );
          expect(find.text('Restaurar logo original'), findsNothing);
          expect(h.adapter.to(ApiEndpoints.settingsLogo), hasLength(1));

          await tester.tap(find.text('Intentar nuevamente'));
          await tester.pumpAndSettle();

          expect(h.adapter.to(ApiEndpoints.settingsLogo), hasLength(2));
          expect(
            find.textContaining('No se pudo cargar el logo'),
            findsNothing,
          );
          expect(find.text('Intentar nuevamente'), findsNothing);
          expect(find.text('Restaurar logo original'), findsOneWidget);
        },
      );
    }
  });
}
