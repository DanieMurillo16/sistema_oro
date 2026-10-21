// Layout de los indicadores del Resumen con las fuentes reales (Inter): con
// Ahem, la de las pruebas, todo mide ~1,8× más ancho. Archivo aparte porque las
// fuentes se cargan antes de la primera medición.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';
import 'package:sistema_oro/shared/widgets/app_metric_card.dart';

import '../../helpers/admin_server.dart';
import '../../support/expect_layout.dart';
import '../../support/pump_at_sizes.dart';
import '../../support/real_fonts.dart';

// Forma de backend/docs/API.md → resumen/obtener.php, con cifras de 8 dígitos.
Map<String, dynamic> _bigSummary(String month) => {
  'mes': month,
  'ventas': {'monto': '34500000.00', 'cantidad': 30},
  'ganancia_estimada': '12800000.00',
  'abonos': {'monto': '21200000.00', 'cantidad': 50},
  'por_cobrar': {'saldo': '27500000.00', 'separados': 40},
  'vencidos': {'cantidad': 1, 'recargos': '80000.00', 'por_vencer': 2},
  'solicitudes_pendientes': 2,
  'clientes': {'nuevos': 6, 'total': 41},
  'inventario': {'prendas': 18, 'unidades': 37, 'valor_venta': '52300000.00'},
};

void main() {
  setUpAll(loadRealFonts);

  testWidgets(
    'KPI de 8 dígitos: la cifra cabe en una línea dentro de la tarjeta y el título no se corta',
    (tester) async {
      for (final (width, scale) in [(320.0, 1.0), (390.0, 1.5)]) {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final server = AdminServer(
          permissions: const ['resumen.ver', 'prendas.ver_costo'],
          routes: {
            ApiEndpoints.summary: (o) =>
                _bigSummary('${o.queryParameters['mes']}'),
          },
        );
        await pumpAdminApp(
          tester,
          overrides: server.harness.overrides,
          width: width,
          height: 1600,
        );
        final reason = '$width px · texto $scale';

        final amount = find.text(r'$ 34.500.000');
        expect(amount, findsOneWidget, reason: reason);
        expectSingleLine(tester, amount, reason: reason);
        final card = find.ancestor(
          of: amount,
          matching: find.byType(AppMetricCard),
        );
        // La cifra reducida (FittedBox) queda dentro de la tarjeta, sin salirse...
        expect(
          tester.getBottomRight(amount).dx,
          lessThanOrEqualTo(tester.getBottomRight(card).dx),
          reason: 'la cifra se sale de la tarjeta · $reason',
        );
        // ...y legible: no se encoge a menos de la mitad.
        final shown =
            tester.getBottomRight(amount).dx - tester.getTopLeft(amount).dx;
        expect(
          shown / tester.getSize(amount).width,
          greaterThan(0.5),
          reason: 'cifra demasiado reducida · $reason',
        );

        for (final title in [
          'Ventas del mes',
          'Abonos recibidos',
          'Por cobrar',
          'Ganancia estimada',
        ]) {
          final text = find.descendant(
            of: find.byType(AppMetricCard),
            matching: find.text(title),
          );
          expectMaxLines(tester, text, 2, reason: '«$title» · $reason');
          expect(
            tester.renderObject<RenderParagraph>(text).didExceedMaxLines,
            isFalse,
            reason: '«$title» con elipsis · $reason',
          );
        }
        expect(tester.takeException(), isNull, reason: reason);
        await tester.pumpWidget(const SizedBox());
      }
    },
  );
}
