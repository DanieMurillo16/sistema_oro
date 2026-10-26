import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';

import '../../helpers/admin_server.dart';
import '../../support/pump_at_sizes.dart';

const _users = [
  {
    'id_usuario': 1,
    'nombre_completo': 'barón joyero',
    'usuario': 'baron',
    'activo': true,
    'id_rol': 1,
    'rol': 'ADMINISTRADOR',
    'creado_en': '2026-10-01 09:00:00',
  },
  {
    'id_usuario': 2,
    'nombre_completo': 'laura empleada',
    'usuario': 'laura',
    'activo': true,
    'id_rol': 2,
    'rol': 'EMPLEADO',
    'creado_en': '2026-10-02 09:00:00',
  },
];

const _roles = [
  {'id_rol': 1, 'nombre': 'ADMINISTRADOR'},
  {'id_rol': 2, 'nombre': 'EMPLEADO'},
];

Future<AdminServer> _open(
  WidgetTester tester, {
  List<String> permissions = const ['usuarios.gestionar', 'resumen.ver'],
}) async {
  final server = AdminServer(
    permissions: permissions,
    routes: {
      ApiEndpoints.usersList: (_) => _users,
      ApiEndpoints.usersRoles: (_) => _roles,
      ApiEndpoints.usersCreate: (_) => {'id_usuario': 3},
      ApiEndpoints.usersEdit: (_) => _users[1],
      ApiEndpoints.usersChangePassword: (_) => {
        'mensaje': 'Contraseña cambiada.',
      },
    },
  );
  await pumpAdminApp(tester, overrides: server.harness.overrides);
  await tester.tap(find.text('Más').last);
  await tester.pumpAndSettle();
  if (permissions.contains('usuarios.gestionar')) {
    await tester.tap(find.text('Usuarios'));
    await tester.pumpAndSettle();
  }
  return server;
}

void main() {
  testWidgets('lista los usuarios con su rol', (tester) async {
    await _open(tester);

    expect(find.text('Laura Empleada'), findsOneWidget);
    expect(find.textContaining('laura'), findsWidgets);
    expect(find.text('Activo'), findsNWidgets(2));
  });

  testWidgets('crear envía el cuerpo del contrato', (tester) async {
    final server = await _open(tester);

    await tester.tap(find.text('Nuevo usuario'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('user_name')), 'Pedro Ruiz');
    await tester.enterText(find.byKey(const Key('user_username')), 'pedro');
    await tester.enterText(
      find.byKey(const Key('user_password')),
      'clave12345',
    );
    await tester.tap(find.widgetWithText(TextField, 'Rol'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Empleado'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Crear usuario'));
    await tester.pumpAndSettle();

    final request = server.harness.adapter.to(ApiEndpoints.usersCreate).single;
    expect(request.authorization, 'Bearer tok');
    expect(request.bodyMap, {
      'nombre': 'Pedro Ruiz',
      'usuario': 'pedro',
      'clave': 'clave12345',
      'id_rol': 2,
    });
    expect(find.text('Usuario creado'), findsOneWidget);
    await dismissToasts(tester);
  });

  testWidgets('una contraseña corta no se envía', (tester) async {
    final server = await _open(tester);

    await tester.tap(find.byTooltip('Cambiar contraseña').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('new_password')), 'corta');
    await tester.tap(find.widgetWithText(FilledButton, 'Cambiar contraseña'));
    await tester.pumpAndSettle();

    expect(find.textContaining('mínimo 8'), findsOneWidget);
    expect(
      server.harness.adapter.to(ApiEndpoints.usersChangePassword),
      isEmpty,
    );
  });

  testWidgets('cambiar la contraseña envía el id y la clave', (tester) async {
    final server = await _open(tester);

    await tester.tap(find.byTooltip('Cambiar contraseña').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('new_password')), 'nueva12345');
    await tester.tap(find.widgetWithText(FilledButton, 'Cambiar contraseña'));
    await tester.pumpAndSettle();

    final request = server.harness.adapter
        .to(ApiEndpoints.usersChangePassword)
        .single;
    expect(request.bodyMap, {'id': 2, 'clave': 'nueva12345'});
    await dismissToasts(tester);
  });

  testWidgets('editar envía nombre, rol y estado', (tester) async {
    final server = await _open(tester);

    await tester.tap(find.byTooltip('Editar usuario').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar usuario'));
    await tester.pumpAndSettle();
    // Desactivar pide confirmación; «Cancelar» no envía nada.
    expect(server.harness.adapter.to(ApiEndpoints.usersEdit), isEmpty);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Cancelar').last);
    await tester.pumpAndSettle();
    expect(server.harness.adapter.to(ApiEndpoints.usersEdit), isEmpty);
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar usuario'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Desactivar'));
    await tester.pumpAndSettle();

    final request = server.harness.adapter.to(ApiEndpoints.usersEdit).single;
    expect(request.bodyMap, {
      'id': 2,
      'nombre': 'laura empleada',
      'id_rol': 2,
      'activo': false,
    });
    await dismissToasts(tester);
  });

  testWidgets('quien no es dueño no ve «Usuarios» en Más', (tester) async {
    await _open(tester, permissions: const ['clientes.ver', 'resumen.ver']);
    expect(find.text('Usuarios'), findsNothing);
  });
}
