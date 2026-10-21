import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';

import '../../support/api_harness.dart';
import '../../support/fake_api_adapter.dart';
import '../../support/pump_at_sizes.dart';

// Respuestas copiadas de backend/docs/API.md (auth/login.php y auth/perfil.php).
const _profile = {
  'perfil': {
    'id_usuario': 1,
    'nombre_completo': 'Barón Joyero',
    'usuario': 'baron',
    'rol': 'ADMINISTRADOR',
  },
  'permisos': <String>[],
};
final _loginOk = {
  'success': true,
  'data': {..._profile, 'token': 'tok123', 'expira_en': null},
};
final _profileOk = {'success': true, 'data': _profile};
const _badCredentials = {
  'success': false,
  'codigo': 'NO_AUTENTICADO',
  'error': 'Usuario o contraseña incorrectos.',
};

Future<void> _fillAndSubmit(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('login_username')), 'baron');
  await tester.enterText(find.byKey(const Key('login_password')), 'secreta123');
  await tester.tap(find.widgetWithText(FilledButton, 'Ingresar'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('iniciar sesión envía usuario y clave y guarda el token', (
    tester,
  ) async {
    final h = ApiHarness(
      FakeApiAdapter(
        (o) async => switch (o.path) {
          ApiEndpoints.login => FakeApiAdapter.jsonResponse(_loginOk, 200),
          _ => FakeApiAdapter.jsonResponse({'success': false}, 404),
        },
      ),
      token: null,
    );
    await pumpAdminApp(tester, overrides: h.overrides);

    expect(find.text('Ingresa a la administración'), findsOneWidget);
    await _fillAndSubmit(tester);

    final request = h.adapter.to(ApiEndpoints.login).single;
    expect(request.method, 'POST');
    expect(request.authorization, isNull);
    expect(request.bodyMap, {'usuario': 'baron', 'clave': 'secreta123'});
    expect(h.tokens.token, 'tok123');
    expect(find.text('Barón Joyero'), findsOneWidget); // llegó a «Más»
  });

  testWidgets('credenciales erróneas muestran el mensaje y no guardan token', (
    tester,
  ) async {
    final h = ApiHarness(
      FakeApiAdapter.json(_badCredentials, status: 401),
      token: null,
    );
    await pumpAdminApp(tester, overrides: h.overrides);

    await _fillAndSubmit(tester);

    expect(find.text('Usuario o contraseña incorrectos.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Ingresar'), findsOneWidget);
    expect(h.tokens.token, isNull);
    await dismissToasts(tester);
  });

  testWidgets('con token guardado recupera la sesión con el Bearer', (
    tester,
  ) async {
    final h = ApiHarness(FakeApiAdapter.json(_profileOk));
    await pumpAdminApp(tester, overrides: h.overrides);

    final request = h.adapter.to(ApiEndpoints.profile).single;
    expect(request.authorization, 'Bearer tok');
    expect(find.text('Barón Joyero'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('un 401 al recuperar la sesión lleva al login', (tester) async {
    final h = ApiHarness(FakeApiAdapter.json(_badCredentials, status: 401));
    await pumpAdminApp(tester, overrides: h.overrides);

    expect(find.byKey(const Key('login_username')), findsOneWidget);
    expect(h.tokens.token, isNull);
  });

  testWidgets('sin red al arrancar ofrece reintentar', (tester) async {
    final h = ApiHarness(FakeApiAdapter.connectionError());
    await pumpAdminApp(tester, overrides: h.overrides);

    expect(find.text('Intentar nuevamente'), findsOneWidget);
    expect(find.textContaining('No fue posible conectar'), findsOneWidget);
  });

  testWidgets('cerrar sesión avisa al servidor y vuelve al login', (
    tester,
  ) async {
    final h = ApiHarness(
      FakeApiAdapter(
        (o) async => switch (o.path) {
          ApiEndpoints.profile => FakeApiAdapter.jsonResponse(_profileOk, 200),
          ApiEndpoints.logout => FakeApiAdapter.jsonResponse({
            'success': true,
            'data': {'mensaje': 'Sesión cerrada correctamente.'},
          }, 200),
          _ => FakeApiAdapter.jsonResponse({'success': false}, 404),
        },
      ),
    );
    await pumpAdminApp(tester, overrides: h.overrides);

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(
      h.adapter.to(ApiEndpoints.logout).single.authorization,
      'Bearer tok',
    );
    expect(h.tokens.token, isNull);
    expect(find.byKey(const Key('login_username')), findsOneWidget);
  });

  testWidgets('el login no desborda en ningún tamaño', (tester) async {
    final h = ApiHarness(FakeApiAdapter.json(_badCredentials), token: null);
    for (final width in [320.0, 800.0]) {
      await pumpAdminApp(
        tester,
        overrides: h.overrides,
        width: width,
        height: 480,
      );
      expect(tester.takeException(), isNull, reason: '$width px');
    }
  });
}
