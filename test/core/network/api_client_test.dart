import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';

import '../../support/api_harness.dart';
import '../../support/fake_api_adapter.dart';

/// Tabla de casos del cliente HTTP central: lo que se envía y cómo se traduce
/// lo que vuelve. Sirve también de ejemplo del patrón de prueba de flujo.
void main() {
  test('envía el token, el método y el cuerpo exactos', () async {
    final h = ApiHarness(
      FakeApiAdapter.json({'success': true, 'data': <String, dynamic>{}}),
    );

    await h.api.post('movimientos/crear.php', data: {'valor': '25000'});

    expect(h.single.method, 'POST');
    expect(h.single.path, 'movimientos/crear.php');
    expect(h.single.authorization, 'Bearer tok');
    expect(h.single.bodyMap, {
      'valor': '25000',
    }); // cuerpo exacto, sin campos extra
  });

  test('error del servidor → mensaje propio en español', () async {
    final h = ApiHarness(
      FakeApiAdapter.json({
        'success': false,
        'codigo': 'SALDO_INSUFICIENTE',
        'error': 'El valor supera el saldo.',
      }, status: 422),
    );

    expect(
      h.api.get('vencimientos/listar.php'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.message, 'message', 'El valor supera el saldo.')
            .having((e) => e.code, 'code', 'SALDO_INSUFICIENTE'),
      ),
    );
  });

  test('401 con token → cierra la sesión local', () async {
    final h = ApiHarness(
      FakeApiAdapter.json({
        'success': false,
        'codigo': 'NO_AUTENTICADO',
        'error': 'Sesión vencida.',
      }, status: 401),
    );

    await expectLater(
      h.api.get('resumen/mes.php'),
      throwsA(isA<ApiException>()),
    );
    expect(h.unauthorizedCalls, 1);
    expect(h.tokens.token, isNull);
  });

  test('sin red → NetworkException con mensaje listo para mostrar', () async {
    final h = ApiHarness(FakeApiAdapter.connectionError());

    expect(h.api.get('health.php'), throwsA(isA<NetworkException>()));
  });
}
