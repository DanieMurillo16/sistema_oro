import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';

import '../../helpers/admin_server.dart';
import '../../support/pump_at_sizes.dart';

const _list = [
  {
    'id_cliente': 3,
    'nombre': 'juan pérez',
    'whatsapp': '573001234567',
    'creado_en': '2026-10-01 09:00:00',
    'pedidos': 2,
    'separados_activos': 1,
    'total_pagado': '200000.00',
    'saldo_pendiente': '800000.00',
  },
  {
    'id_cliente': 4,
    'nombre': 'ana gómez',
    'whatsapp': '573009876543',
    'creado_en': '2026-10-02 09:00:00',
    'pedidos': 1,
    'separados_activos': 0,
    'total_pagado': '500000.00',
    'saldo_pendiente': '0.00',
  },
];

final _detail = {
  ..._list[0],
  'notas': 'Prefiere pulseras',
  'pedidos': [
    {
      'id_pedido': 8,
      'codigo': 'LY000008',
      'tipo': 'SEPARADO',
      'estado': 'ACTIVO',
      'creado_en': '2026-10-05 10:00:00',
      'prenda': 'cadena cubana',
      'total_a_pagar': '1000000.00',
      'total_pagado': '200000.00',
      'saldo': '800000.00',
      'meses_vencidos': 0,
      'fecha_limite': '2026-11-05',
    },
  ],
};

const _perms = ['clientes.ver', 'clientes.editar'];

AdminServer _server([List<String> permissions = _perms]) => AdminServer(
  permissions: permissions,
  routes: {
    ApiEndpoints.clientsList: (_) => _list,
    ApiEndpoints.clientsGet: (_) => _detail,
  },
);

Future<void> _open(WidgetTester tester, AdminServer server) =>
    pumpAdminApp(tester, overrides: server.harness.overrides);

void main() {
  testWidgets('la lista muestra nombre, pedidos y saldo, y filtra por saldo', (
    tester,
  ) async {
    await _open(tester, _server());

    expect(find.text('Juan Pérez'), findsOneWidget);
    expect(find.text(r'$ 800.000'), findsOneWidget);
    expect(find.textContaining('2 pedidos'), findsOneWidget);

    await tester.tap(find.text('Con saldo'));
    await tester.pumpAndSettle();
    expect(find.text('Ana Gómez'), findsNothing);
    expect(find.text('Juan Pérez'), findsOneWidget);
  });

  testWidgets('la ficha muestra sus datos y su historial', (tester) async {
    final server = _server();
    await _open(tester, server);

    await tester.tap(find.text('Juan Pérez'));
    await tester.pumpAndSettle();

    expect(server.harness.adapter.to(ApiEndpoints.clientsGet).single.query, {
      'id': 3,
    });
    expect(find.text('Prefiere pulseras'), findsOneWidget);
    expect(find.textContaining('Cadena cubana'), findsOneWidget);
    expect(find.text('Activo'), findsOneWidget);
  });

  testWidgets('editar envía el nombre y las notas', (tester) async {
    final server = _server();
    server.routes[ApiEndpoints.clientsEdit] = (_) => {'id_cliente': 3};
    await _open(tester, server);
    await tester.tap(find.text('Juan Pérez'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Editar cliente'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('client_name')),
      'Juan Pérez Gómez',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar cliente'));
    await tester.pumpAndSettle();

    final request = server.harness.adapter.to(ApiEndpoints.clientsEdit).single;
    expect(request.bodyMap, {
      'id': 3,
      'nombre': 'Juan Pérez Gómez',
      'notas': 'Prefiere pulseras',
    });
    expect(find.text('Cliente actualizado'), findsOneWidget);
    await dismissToasts(tester);
  });

  testWidgets('sin permiso de editar no hay lápiz', (tester) async {
    final server = _server(['clientes.ver']);
    await _open(tester, server);
    await tester.tap(find.text('Juan Pérez'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Editar cliente'), findsNothing);
  });

  testWidgets('la lista y la ficha no desbordan con nombres largos', (
    tester,
  ) async {
    final server = AdminServer(
      permissions: _perms,
      routes: {
        ApiEndpoints.clientsList: (_) => [
          {
            ..._list[0],
            'nombre': 'maría de los ángeles rodríguez de la cruz y pérez',
          },
        ],
        ApiEndpoints.clientsGet: (_) => {
          ..._detail,
          'nombre': 'maría de los ángeles rodríguez de la cruz y pérez',
        },
      },
    );
    await pumpAdminApp(
      tester,
      width: 320,
      height: 700,
      overrides: server.harness.overrides,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(Card).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
