import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/core/services/link_launcher.dart';

import 'package:sistema_oro/features/catalog/catalog_garment_screen.dart';
import 'package:sistema_oro/features/catalog/catalog_screen.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_card.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_brand.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_chat_button.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_header.dart';
import 'package:sistema_oro/features/catalog/widgets/checkout/checkout_success.dart';
import 'package:sistema_oro/features/catalog/widgets/checkout/checkout_summary.dart';
import 'package:sistema_oro/features/catalog/widgets/checkout/quantity_stepper.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_filters.dart';
import 'package:sistema_oro/features/catalog/widgets/related_garments.dart';
import 'package:sistema_oro/shared/widgets/brand_logo_image.dart';
import 'package:sistema_oro/features/catalog/widgets/garment_detail_body.dart';
import 'package:sistema_oro/features/catalog/widgets/purchase_bar.dart';
import 'package:sistema_oro/features/catalog/widgets/whatsapp_fab.dart';
import 'package:sistema_oro/shared/widgets/network_thumb.dart';

import '../../helpers/catalog_fixtures.dart';
import '../../support/fake_image_picker.dart';
import '../../support/expect_layout.dart';
import '../../support/fake_link_launcher.dart';
import '../../support/form_request.dart';
import '../../support/pump_at_sizes.dart';

class _Setup {
  _Setup(this.server, this.launcher, this.picker);

  final CatalogServer server;
  final FakeLinkLauncher launcher;
  final FakeImagePicker picker;
}

/// Baja la lista lo suficiente para que la cabecera pase a mostrar los tipos.
Future<void> _scrollDown(WidgetTester tester) async {
  await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
  await tester.pumpAndSettle();
}

Future<_Setup> _open(
  WidgetTester tester, {
  CatalogServer? server,
  double width = 390,
  double height = 800,
  bool poll = false,
}) async {
  final s = server ?? CatalogServer();
  final launcher = FakeLinkLauncher();
  final picker = FakeImagePicker();
  await pumpCatalogApp(
    tester,
    width: width,
    height: height,
    pollInterval: poll ? const Duration(seconds: 2) : null,
    overrides: [
      ...s.harness.overrides,
      linkLauncherProvider.overrideWithValue(launcher),
      imagePickerServiceProvider.overrideWithValue(picker),
    ],
  );
  return _Setup(s, launcher, picker);
}

Future<void> _openGarment(WidgetTester tester) async {
  // El titular de presentación empuja las tarjetas: se baja hasta la prenda.
  // En pantalla ancha la portada también muestra la pieza: se toca la de la cuadrícula.
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
}

Future<void> _fillContact(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('checkout_name')), 'Juan Pérez');
  await tester.enterText(
    find.byKey(const Key('checkout_whatsapp')),
    '3001234567',
  );
}

Future<void> _attachReceipt(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Adjuntar comprobante'));
  await tester.tap(find.widgetWithText(OutlinedButton, 'Adjuntar comprobante'));
  await tester.pumpAndSettle();
}

/// Marca la casilla obligatoria del separado.
Future<void> _acceptLayaway(WidgetTester tester) async {
  final box = find.byKey(const Key('layaway_accept'));
  await tester.ensureVisible(box);
  await tester.tap(box);
  await tester.pumpAndSettle();
}

Future<void> _send(WidgetTester tester, String label) async {
  final button = find.widgetWithText(FilledButton, label);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  group('listado', () {
    testWidgets('muestra las prendas con precio y etiquetas, sin token', (
      tester,
    ) async {
      final s = await _open(
        tester,
        height: 1600,
        server: CatalogServer(
          rows: [
            publicGarment(isNew: true),
            publicGarment(
              id: 12,
              name: 'dije corazón',
              onSale: true,
              previous: '1200000.00',
            ),
            publicGarment(id: 13, name: 'topo perla', soldOut: true, stock: 0),
          ],
        ),
      );

      expect(
        s.server.harness.adapter
            .to(ApiEndpoints.publicGarments)
            .first
            .authorization,
        isNull,
      );
      expect(find.text('Cadena cubana'), findsOneWidget);
      expect(find.text(r'$ 1.000.000'), findsWidgets);
      // La tarjeta es limpia: el precio anterior solo se ve en el detalle.
      expect(find.text(r'$ 1.200.000'), findsNothing);
      // «Reservar» en las que se pueden separar (no en la agotada).
      expect(find.text('Reservar'), findsNWidgets(2));
      expect(find.text('NUEVO'), findsOneWidget);
      expect(find.text('SALE'), findsOneWidget);
      expect(find.text('AGOTADO'), findsOneWidget);
      expect(find.text('Mostrando 3 de 3 prendas'), findsOneWidget);
    });

    testWidgets('«Reservar» explica el 20 % y sigue al formulario de separar', (
      tester,
    ) async {
      await _open(tester);
      await tester.scrollUntilVisible(
        find.text('Reservar'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      // Se baja un poco para que no quede bajo la cabecera fija.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 250));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reservar'));
      await tester.pumpAndSettle();

      expect(find.text('Reservar con el 20 %'), findsOneWidget);
      expect(find.text(r'$ 200.000'), findsOneWidget); // pagas hoy
      expect(find.text(r'$ 800.000'), findsOneWidget); // saldo
      expect(find.textContaining('Tienes 1 mes'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Continuar'));
      await tester.pumpAndSettle();
      expect(find.text('Separar con el 20 %'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Enviar separado'),
        findsOneWidget,
      );
    });

    testWidgets(
      'arriba solo va el logo centrado; al bajar, logo a la izquierda y tipos',
      (tester) async {
        await _open(tester);
        final brand = find.byType(CatalogBrand);
        expect(find.byType(TextField), findsNothing); // sin buscador
        expect(find.byType(CatalogChatButton), findsNothing);
        expect(find.text('Pulseras'), findsNothing); // ni fila de chips
        expect(tester.getCenter(brand).dx, closeTo(390 / 2, 2));

        await _scrollDown(tester);
        expect(find.byType(TextField), findsNothing);
        expect(find.byType(CatalogChatButton), findsOneWidget);
        expect(find.text('Todas'), findsOneWidget);
        expect(find.text('Pulseras'), findsOneWidget);
        expect(tester.getCenter(brand).dx, lessThan(390 / 2));
        // Los tipos van en la cabecera fija, pegados arriba.
        expect(tester.getTopLeft(find.text('Pulseras')).dy, lessThan(160));

        await tester.drag(find.byType(CustomScrollView), const Offset(0, 2000));
        await tester.pumpAndSettle();
        expect(find.text('Pulseras'), findsNothing);
        expect(find.byType(CatalogChatButton), findsNothing);
        expect(tester.getCenter(brand).dx, closeTo(390 / 2, 2));
      },
    );

    testWidgets('elegir un tipo vuelve a pedir el listado filtrado', (
      tester,
    ) async {
      final s = await _open(tester);
      await _scrollDown(tester); // los tipos aparecen en la cabecera fija

      await tester.tap(find.text('Pulseras'));
      await tester.pumpAndSettle();

      final last = s.server.harness.adapter
          .to(ApiEndpoints.publicGarments)
          .last;
      expect(last.query['tipo'], 2);
      expect(last.query['orden'], 'RECIENTES');
    });

    testWidgets('«Te la conseguimos» abre el WhatsApp de Barón', (
      tester,
    ) async {
      final s = await _open(tester);

      await tester.scrollUntilVisible(
        find.text('Te la conseguimos'),
        300,
        scrollable: find.byWidgetPredicate(
          (w) => w is Scrollable && w.axis == Axis.vertical,
        ),
      );
      await tester.ensureVisible(find.text('Escríbenos').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Escríbenos').last);
      await tester.pumpAndSettle();

      expect(s.launcher.whatsappCalls.single.phone, '573001234567');
      expect(
        s.launcher.whatsappCalls.single.message,
        contains('no encontré la prenda'),
      );
    });

    testWidgets('sin número de WhatsApp no hay «Te la conseguimos»', (
      tester,
    ) async {
      await _open(tester, server: CatalogServer(whatsapp: ''));
      expect(find.text('Te la conseguimos'), findsNothing);
    });
  });

  group('detalle', () {
    testWidgets('muestra el 20 % ya calculado por el servidor', (tester) async {
      await _open(tester);
      await _openGarment(tester);

      expect(find.text('Cadena de eslabones cubanos'), findsOneWidget);
      expect(find.text(r'$ 200.000'), findsWidgets); // lo que se paga hoy
      expect(find.widgetWithText(OutlinedButton, 'Separar'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Comprar ahora'),
        findsOneWidget,
      );
    });

    testWidgets('en teléfono la barra de compra no tapa el detalle', (
      tester,
    ) async {
      await _open(tester, width: 360, height: 640);
      await _openGarment(tester);

      final bar = tester.getSize(find.byType(PurchaseBar));
      final body = tester.getSize(find.byType(GarmentDetailBody));
      expect(
        bar.height,
        lessThan(220),
        reason: 'la barra es de botones, no de pantalla',
      );
      expect(body.height, greaterThan(150), reason: 'el detalle sigue visible');
      expect(find.byType(WhatsAppFab), findsNothing); // ya está en la cabecera
    });

    testWidgets('una prenda agotada no se puede comprar', (tester) async {
      await _open(
        tester,
        server: CatalogServer(rows: [publicGarment(soldOut: true, stock: 0)]),
      );
      await _openGarment(tester);

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Agotada'),
      );
      expect(button.onPressed, isNull);
      expect(find.widgetWithText(OutlinedButton, 'Separar'), findsNothing);
    });
  });

  group('comprar y separar', () {
    testWidgets(
      'comprar envía el formulario del contrato y muestra el código',
      (tester) async {
        final s = await _open(tester);
        s.server.requestResponses.add(() => CatalogServer.created('AB12CD34'));
        await _openGarment(tester);

        await tester.tap(find.widgetWithText(FilledButton, 'Comprar ahora'));
        await tester.pumpAndSettle();
        await _fillContact(tester);
        await _attachReceipt(tester);
        await _send(tester, 'Enviar compra');

        final request = s.server.harness.adapter
            .to(ApiEndpoints.publicRequest)
            .single;
        expect(request.method, 'POST');
        expect(request.authorization, isNull);
        expect(
          request.formFields['clave_envio'],
          matches(
            RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
            ),
          ),
        );
        expect({...request.formFields}..remove('clave_envio'), {
          'tipo': 'COMPRA',
          'id_prenda': '11',
          'cantidad': '1',
          'caja': 'GRATIS',
          'nombre': 'Juan Pérez',
          'whatsapp': '3001234567',
          'entrega': 'RECOGE',
          'monto': '1000000.00',
          'sitio_web': '',
        });
        expect(request.formFileNames, ['comprobante']);
        expect(find.text('AB12CD34'), findsOneWidget);
        expect(find.text('¡Recibimos tu compra!'), findsOneWidget);

        // Del código a WhatsApp en un toque, con el mensaje ya escrito.
        await tester.tap(
          find.widgetWithText(FilledButton, 'Enviar por WhatsApp'),
        );
        await tester.pumpAndSettle();
        final call = s.launcher.whatsappCalls.single;
        expect(call.phone, '573001234567');
        expect(call.message, contains('AB12CD34'));
        expect(call.message, contains('mi compra'));
      },
    );

    testWidgets('el banco viaja con el comprobante y es opcional', (
      tester,
    ) async {
      final s = await _open(tester);
      s.server.requestResponses.add(() => CatalogServer.created('AB12CD34'));
      await _openGarment(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Comprar ahora'));
      await tester.pumpAndSettle();
      await _fillContact(tester);
      await _attachReceipt(tester);
      await tester.ensureVisible(find.byKey(const Key('checkout_bank')));
      await tester.enterText(
        find.byKey(const Key('checkout_bank')),
        '  Bancolombia  ',
      );
      await _send(tester, 'Enviar compra');

      final request = s.server.harness.adapter
          .to(ApiEndpoints.publicRequest)
          .single;
      expect(request.formFields['banco'], 'Bancolombia');
    });

    testWidgets(
      'en el diálogo: cantidad dentro de la fila de la prenda y nombre con WhatsApp en pareja',
      (tester) async {
        for (final width in [320.0, 390.0, 800.0]) {
          await _open(tester, width: width, height: 800);
          await _openGarment(tester);
          await tester.tap(find.widgetWithText(FilledButton, 'Comprar ahora'));
          await tester.pumpAndSettle();
          final name = find.descendant(
            of: find.byType(CheckoutSummary),
            matching: find.text('Cadena cubana'),
          );
          if (width >= 390) {
            // A la derecha de la prenda, centrada con su fila (miniatura, nombre, precio).
            expect(
              tester.getCenter(find.text('Cantidad')).dx,
              tester.getCenter(find.byType(QuantityStepper)).dx,
              reason: 'etiqueta centrada sobre el control ($width px)',
            );
            final stack = Rect.fromPoints(
              tester.getTopLeft(find.text('Cantidad')),
              tester.getBottomRight(find.byType(QuantityStepper)),
            );
            expect(
              stack.center.dy,
              closeTo(tester.getCenter(find.byType(CheckoutSummary)).dy, 4),
              reason: 'centrada en vertical con la fila ($width px)',
            );
            expect(
              tester.getTopLeft(find.text('Cantidad')).dx,
              greaterThan(tester.getTopRight(name).dx - 1),
              reason: 'a la derecha de la prenda ($width px)',
            );
          } else {
            // Muy angosto: debajo del precio, pero DENTRO de la fila de la prenda.
            expectStacked(tester, name, find.text('Cantidad'));
            expect(
              tester.getTopLeft(find.text('Cantidad')).dy,
              lessThan(tester.getBottomLeft(find.byType(CheckoutSummary)).dy),
            );
          }
          // Nombre y WhatsApp uno al lado del otro (AppFormPair: se apilan solo si no caben).
          await tester.ensureVisible(
            find.byKey(const Key('checkout_whatsapp')),
          );
          final nameField = find.byKey(const Key('checkout_name'));
          final whatsappField = find.byKey(const Key('checkout_whatsapp'));
          if (width >= 390) {
            expectSameRow(tester, nameField, whatsappField);
          } else {
            expectStacked(tester, nameField, whatsappField); // a 320 no caben
          }
          await tester.pumpWidget(const SizedBox());
        }
      },
    );

    testWidgets(
      'al cerrar la confirmación lo lleva al inicio, sin «ya no está disponible»',
      (tester) async {
        final s = await _open(tester, poll: true);
        s.server.requestResponses.add(() => CatalogServer.created('AB12CD34'));
        await _openGarment(tester);
        await tester.tap(find.widgetWithText(FilledButton, 'Comprar ahora'));
        await tester.pumpAndSettle();
        await _fillContact(tester);
        await _attachReceipt(tester);
        await _send(tester, 'Enviar compra');
        expect(find.text('AB12CD34'), findsOneWidget);

        // La unidad quedó reservada: el servidor ya no la devuelve (detrás del diálogo).
        s.server.rows.clear();
        await tester.pump(const Duration(seconds: 2));
        await tester.pump();
        expect(
          find.text('AB12CD34'),
          findsOneWidget,
        ); // la confirmación sigue ahí

        await tester.tap(find.widgetWithText(OutlinedButton, 'Cerrar'));
        await tester.pumpAndSettle();

        expect(find.text('Esta prenda ya no está disponible'), findsNothing);
        expect(find.byType(CatalogScreen), findsOneWidget); // vista principal
        expect(find.byType(CatalogGarmentScreen), findsNothing);
      },
    );

    testWidgets(
      'la caja decorada y el envío entran en el monto y la dirección',
      (tester) async {
        final s = await _open(tester);
        s.server.requestResponses.add(() => CatalogServer.created('AB12CD34'));
        await _openGarment(tester);

        await tester.tap(find.widgetWithText(FilledButton, 'Comprar ahora'));
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining('Decorada'));
        await tester.tap(find.text('Envío'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('checkout_city')),
          'Medellín',
        );
        await tester.enterText(
          find.byKey(const Key('checkout_address')),
          'Calle 10 # 20-30',
        );
        await _fillContact(tester);
        await _attachReceipt(tester);
        await _send(tester, 'Enviar compra');

        final fields = s.server.harness.adapter
            .to(ApiEndpoints.publicRequest)
            .single
            .formFields;
        expect(fields['caja'], 'DECORADA');
        expect(fields['monto'], '1012000.00'); // precio + caja
        expect(fields['entrega'], 'ENVIO');
        expect(fields['ciudad'], 'Medellín');
        expect(fields['direccion'], 'Calle 10 # 20-30');
      },
    );

    group('separar no es llevarse la prenda', () {
      const rule =
          'Separar no es llevarte la prenda: te la entregamos únicamente '
          'cuando pagues el 100 %.';

      testWidgets('el detalle, el aviso y la casilla dicen la regla', (
        tester,
      ) async {
        await _open(tester);
        await _openGarment(tester);
        expect(find.text(rule), findsWidgets); // «Plan separe» del detalle

        await tester.tap(find.widgetWithText(OutlinedButton, 'Separar'));
        await tester.pumpAndSettle();
        expect(find.text(rule), findsWidgets); // aviso dentro del diálogo
        expect(find.textContaining('Plazo: 1 mes'), findsOneWidget);
        expect(
          find.textContaining(r'$ 80.000'),
          findsWidgets,
        ); // recargo (ajustes)
        expect(
          find.text(
            'Entiendo que la prenda se entrega solo cuando pague el 100 %',
          ),
          findsOneWidget,
        );
      });

      testWidgets('«Enviar separado» queda apagado hasta marcar la casilla', (
        tester,
      ) async {
        final s = await _open(tester);
        s.server.requestResponses.add(() => CatalogServer.created('LY000009'));
        await _openGarment(tester);
        await tester.tap(find.widgetWithText(OutlinedButton, 'Separar'));
        await tester.pumpAndSettle();
        await _fillContact(tester);
        await _attachReceipt(tester);

        FilledButton send() => tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Enviar separado'),
        );
        expect(send().onPressed, isNull); // existe, pero apagado
        await _acceptLayaway(tester);
        expect(send().onPressed, isNotNull);
        await _acceptLayaway(tester); // la desmarca: vuelve a apagarse
        expect(send().onPressed, isNull);
        expect(
          s.server.harness.adapter.to(ApiEndpoints.publicRequest),
          isEmpty,
        );
      });

      testWidgets('la confirmación y el WhatsApp repiten la regla', (
        tester,
      ) async {
        final s = await _open(tester);
        s.server.requestResponses.add(() => CatalogServer.created('LY000010'));
        await _openGarment(tester);
        await tester.tap(find.widgetWithText(OutlinedButton, 'Separar'));
        await tester.pumpAndSettle();
        await _fillContact(tester);
        await _attachReceipt(tester);
        await _acceptLayaway(tester);
        await _send(tester, 'Enviar separado');

        expect(
          find.descendant(
            of: find.byType(CheckoutSuccess),
            matching: find.text(rule),
          ),
          findsOneWidget,
        ); // en la confirmación
        await tester.tap(
          find.widgetWithText(FilledButton, 'Enviar por WhatsApp'),
        );
        await tester.pumpAndSettle();
        final message = s.launcher.whatsappCalls.single.message!;
        expect(message, contains('mi separado'));
        expect(message, contains('LY000010'));
        expect(
          message,
          contains(
            'Entiendo que la prenda se entrega solo cuando pague el 100 %',
          ),
        );
      });

      testWidgets('una compra no lleva la casilla ni el aviso', (tester) async {
        await _open(tester);
        await _openGarment(tester);
        await tester.tap(find.widgetWithText(FilledButton, 'Comprar ahora'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('layaway_accept')), findsNothing);
        expect(
          find.widgetWithText(FilledButton, 'Enviar compra'),
          findsOneWidget,
        );
      });

      testWidgets('el inicio ya no sugiere llevársela al separar', (
        tester,
      ) async {
        await _open(tester);
        await tester.scrollUntilVisible(
          find.text('Se entrega al pagar el 100 %'),
          300,
          scrollable: find
              .descendant(
                of: find.byType(CustomScrollView),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        expect(find.text('Se entrega al pagar el 100 %'), findsOneWidget);
        expect(find.text('Completa en abonos'), findsNothing);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 3));
      });

      testWidgets(
        'con teclado y 320×1.5 la casilla se alcanza y habilita el botón',
        (tester) async {
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          tester.platformDispatcher.textScaleFactorTestValue = 1.5;
          final s = await _open(tester, width: 320, height: 760);
          s.server.requestResponses.add(
            () => CatalogServer.created('LY000011'),
          );
          await _openGarment(tester);
          await tester.tap(find.widgetWithText(OutlinedButton, 'Separar'));
          await tester.pumpAndSettle();
          await _fillContact(tester);
          await _attachReceipt(tester);
          tester.view.viewInsets = const FakeViewPadding(bottom: 300);
          addTearDown(tester.view.resetViewInsets);
          await tester.pumpAndSettle();

          await _acceptLayaway(tester); // ensureVisible + tap
          expect(tester.takeException(), isNull);
          tester.view.resetViewInsets();
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<FilledButton>(
                  find.widgetWithText(FilledButton, 'Enviar separado'),
                )
                .onPressed,
            isNotNull,
          );
        },
      );

      testWidgets('el aviso y la casilla no desbordan a 320 con letra 1.5', (
        tester,
      ) async {
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        for (final width in [320.0, 390.0]) {
          await _open(tester, width: width);
          await _openGarment(tester);
          await tester.tap(find.widgetWithText(OutlinedButton, 'Separar'));
          await tester.pumpAndSettle();
          await _acceptLayaway(tester);
          expect(tester.takeException(), isNull, reason: '$width');
          await tester.pumpWidget(const SizedBox());
        }
      });
    });

    testWidgets('separar envía el 20 % por defecto como monto', (tester) async {
      final s = await _open(tester);
      s.server.requestResponses.add(() => CatalogServer.created('LY000008'));
      await _openGarment(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Separar'));
      await tester.pumpAndSettle();
      await _fillContact(tester);
      await _attachReceipt(tester);
      await _acceptLayaway(tester);
      await _send(tester, 'Enviar separado');

      final fields = s.server.harness.adapter
          .to(ApiEndpoints.publicRequest)
          .single
          .formFields;
      expect(fields['tipo'], 'SEPARADO');
      expect(fields['monto'], '200000.00');
      expect(find.text('¡Recibimos tu separado!'), findsOneWidget);
    });

    testWidgets('separar con menos del 20 % no se envía', (tester) async {
      final s = await _open(tester);
      await _openGarment(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Separar'));
      await tester.pumpAndSettle();
      await _fillContact(tester);
      await tester.enterText(
        find.byKey(const Key('checkout_amount')),
        '100000',
      );
      await _attachReceipt(tester);
      await _acceptLayaway(tester);
      await _send(tester, 'Enviar separado');

      expect(find.textContaining('transferir mínimo'), findsOneWidget);
      expect(s.server.harness.adapter.to(ApiEndpoints.publicRequest), isEmpty);
    });

    testWidgets('sin comprobante no se envía', (tester) async {
      final s = await _open(tester);
      await _openGarment(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Comprar ahora'));
      await tester.pumpAndSettle();
      await _fillContact(tester);
      await _send(tester, 'Enviar compra');

      expect(find.textContaining('Adjunta el comprobante'), findsOneWidget);
      expect(s.server.harness.adapter.to(ApiEndpoints.publicRequest), isEmpty);
    });

    testWidgets('al reintentar se reutiliza la misma clave de envío', (
      tester,
    ) async {
      final s = await _open(tester);
      s.server.requestResponses
        ..add(
          () =>
              CatalogServer.failure('ERROR_INTERNO', 'Falla inesperada.', 500),
        )
        ..add(() => CatalogServer.created('AB12CD34', repeated: true));
      await _openGarment(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Comprar ahora'));
      await tester.pumpAndSettle();
      await _fillContact(tester);
      await _attachReceipt(tester);
      await _send(tester, 'Enviar compra');
      expect(find.text('Falla inesperada.'), findsOneWidget);
      await dismissToasts(tester);
      await _send(tester, 'Enviar compra');

      final requests = s.server.harness.adapter.to(ApiEndpoints.publicRequest);
      expect(requests, hasLength(2));
      expect(
        requests[0].formFields['clave_envio'],
        requests[1].formFields['clave_envio'],
      );
      expect(find.text('AB12CD34'), findsOneWidget);
    });

    testWidgets(
      'la miniatura del diálogo es la primera foto (el detalle no trae «miniatura»)',
      (tester) async {
        await _open(tester);
        await _openGarment(tester);
        await tester.tap(find.widgetWithText(FilledButton, 'Comprar ahora'));
        await tester.pumpAndSettle();

        final thumb = tester.widget<NetworkThumb>(
          find.descendant(
            of: find.byType(CheckoutSummary),
            matching: find.byType(NetworkThumb),
          ),
        );
        expect(thumb.url, 'https://x.test/m1.jpg');
      },
    );

    testWidgets('si ya no está disponible avisa y recarga la prenda', (
      tester,
    ) async {
      final s = await _open(tester);
      s.server.requestResponses.add(
        () => CatalogServer.failure(
          'NO_DISPONIBLE',
          'Esta prenda ya no está disponible.',
          409,
        ),
      );
      await _openGarment(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Comprar ahora'));
      await tester.pumpAndSettle();
      await _fillContact(tester);
      await _attachReceipt(tester);
      await _send(tester, 'Enviar compra');

      expect(find.text('Esta prenda ya no está disponible.'), findsOneWidget);
      expect(
        s.server.harness.adapter.to(ApiEndpoints.publicGarment).length,
        greaterThanOrEqualTo(2),
      );
      await dismissToasts(tester);
    });
  });

  group('logo de la marca', () {
    Finder logoImage(bool Function(ImageProvider) test) =>
        find.byWidgetPredicate((w) => w is Image && test(w.image));

    testWidgets('sin logo subido se usa el empaquetado', (tester) async {
      await _open(tester);
      expect(
        logoImage(
          (i) => i is AssetImage && i.assetName == BrandLogoImage.asset,
        ),
        findsWidgets,
      );
    });

    testWidgets('con un logo subido por el dueño se muestra ese (con su ?v=)', (
      tester,
    ) async {
      const url = 'https://x.test/uploads/logo/a.png?v=2';
      await _open(tester, server: CatalogServer(logoUrl: url));
      expect(logoImage((i) => i is NetworkImage && i.url == url), findsWidgets);
    });
  });

  group('inventario en vivo', () {
    testWidgets('el listado saca solo la prenda que otra persona se llevó', (
      tester,
    ) async {
      final s = await _open(
        tester,
        height: 1600,
        poll: true,
        server: CatalogServer(
          rows: [
            publicGarment(),
            publicGarment(id: 12, name: 'dije corazón'),
          ],
        ),
      );
      expect(find.text('Dije corazón'), findsOneWidget);

      s.server.rows.removeWhere((r) => r['id_prenda'] == 12);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Dije corazón'), findsNothing);
      expect(find.text('Cadena cubana'), findsOneWidget);
    });

    testWidgets('el detalle avisa cuando la prenda ya no está', (tester) async {
      final s = await _open(tester, poll: true);
      await _openGarment(tester);
      expect(
        find.widgetWithText(FilledButton, 'Comprar ahora'),
        findsOneWidget,
      );

      s.server.rows.clear();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Esta prenda ya no está disponible'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Comprar ahora'), findsNothing);
    });

    testWidgets('el formulario se cierra si se llevan la prenda', (
      tester,
    ) async {
      final s = await _open(tester, poll: true);
      await _openGarment(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Comprar ahora'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('checkout_name')), findsOneWidget);

      s.server.rows.clear();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('checkout_name')), findsNothing);
      expect(
        find.text('Otra persona acaba de llevarse esta prenda.'),
        findsOneWidget,
      );
      await dismissToasts(tester);
    });
  });

  testWidgets('el catálogo no desborda en ningún tamaño ni con letra grande', (
    tester,
  ) async {
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    for (final scale in [1.0, 1.5]) {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      for (final (width, height) in [
        (320.0, 700.0),
        (390.0, 800.0),
        (800.0, 700.0),
        (1300.0, 800.0),
      ]) {
        final s = CatalogServer(
          rows: [
            publicGarment(
              name: 'cadena cubana con dije de la virgen del carmen en oro de 18 quilates',
              isNew: true,
              onSale: true,
              previous: '1200000.00',
            ),
            publicGarment(id: 12, lastUnit: true, stock: 1),
            publicGarment(id: 13, soldOut: true, stock: 0),
          ],
        );
        await _open(tester, server: s, width: width, height: height);
        final reason = '$width px · letra $scale';
        expect(tester.takeException(), isNull, reason: 'listado $reason');
        final headerHeight = tester.getSize(find.byType(CatalogHeader)).height;
        await _scrollDown(tester);
        expect(tester.takeException(), isNull, reason: 'tipos $reason');
        expect(
          tester.getSize(find.byType(CatalogHeader)).height,
          headerHeight,
          reason: 'la cabecera no salta $reason',
        );
        await tester.drag(find.byType(CustomScrollView), const Offset(0, 3000));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'detalle $reason');
        await tester.pumpWidget(const SizedBox());
      }
    }
  });

  testWidgets('Comprar y Separar van lado a lado y Comprar es el más ancho', (
    tester,
  ) async {
    for (final width in [320.0, 390.0, 800.0, 1300.0]) {
      await _open(tester, width: width, height: 800);
      await _openGarment(tester);
      final buy = find.widgetWithText(FilledButton, 'Comprar ahora');
      final layaway = find.widgetWithText(OutlinedButton, 'Separar');
      expectSameRow(tester, buy, layaway);
      expect(
        tester.getSize(buy).width,
        greaterThan(tester.getSize(layaway).width * 1.3),
        reason: 'Comprar debe abarcar más ($width px)',
      );
      expectSingleLine(tester, find.text('Comprar ahora'));
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('con letra muy grande en un teléfono angosto se apilan', (
    tester,
  ) async {
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    await _open(tester, width: 360, height: 800);
    await _openGarment(tester);
    expectStacked(
      tester,
      find.widgetWithText(FilledButton, 'Comprar ahora'),
      find.widgetWithText(OutlinedButton, 'Separar'),
    );
  });

  testWidgets(
    'las tarjetas relacionadas con nombre largo no desbordan (800 y 1300 × letra 1.5)',
    (tester) async {
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      const longName =
          'cadena cubana con dije de la virgen del carmen en oro de 18 quilates italiano';
      for (final (width, height) in [(800.0, 700.0), (1300.0, 800.0)]) {
        final s = CatalogServer(
          rows: [
            publicGarment(),
            publicGarment(id: 12, name: longName),
          ],
        );
        await _open(tester, server: s, width: width, height: height);
        await _openGarment(tester);

        await tester.scrollUntilVisible(
          find.byType(RelatedGarments),
          300,
          scrollable: find
              .byWidgetPredicate(
                (w) => w is Scrollable && w.axis == Axis.vertical,
              )
              .last,
        );
        await tester.pumpAndSettle();

        final reason = '$width px · letra 1.5';
        expect(tester.takeException(), isNull, reason: 'relacionadas $reason');
        // La otra prenda está en la fila y su tarjeta tiene altura propia (natural).
        final card = find.descendant(
          of: find.byType(RelatedGarments),
          matching: find.byType(CatalogCard),
        );
        expect(card, findsOneWidget, reason: reason);
        expect(tester.getSize(card).height, greaterThan(0), reason: reason);
        await tester.pumpWidget(const SizedBox());
      }
    },
  );

  testWidgets(
    '«Ordenar» va debajo del título en teléfono y a la derecha en ancho',
    (tester) async {
      final title = find.text('Nuestras piezas');
      final sort = find.byType(PopupMenuButton<CatalogSort>);
      final filters = find.byType(CatalogFilters);

      await _open(tester, width: 390, height: 800);
      expectStacked(tester, title, sort);
      expect(
        tester.getTopLeft(sort).dy,
        greaterThanOrEqualTo(
          tester.getTopLeft(find.textContaining('Mostrando')).dy,
        ),
        reason: 'en teléfono el orden queda bajo título y contador',
      );
      await tester.pumpWidget(const SizedBox());

      await _open(tester, width: 800, height: 800);
      // Con la fila alineada abajo, el menú empieza más arriba que el título:
      // lo que importa es que está a su derecha, pegado al borde, y no debajo.
      expect(
        tester.getTopLeft(sort).dx,
        greaterThan(tester.getTopRight(title).dx),
        reason: 'en 800 px el orden va a la derecha del título',
      );
      expectRightEdge(tester, sort, filters, tolerance: 40);
      expect(
        tester.getTopLeft(sort).dy,
        lessThan(tester.getBottomLeft(find.textContaining('Mostrando')).dy),
        reason: 'en 800 px el orden comparte altura con el encabezado',
      );
    },
  );
}
