import 'package:dio/dio.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';

import '../support/api_harness.dart';
import '../support/fake_api_adapter.dart';
import 'order_fixtures.dart';

/// Servidor falso genérico: [routes] responde por ruta con el JSON de
/// `data` (o una lista); lo no programado devuelve 404 con mensaje claro.
class AdminServer {
  AdminServer({
    required this.permissions,
    Map<String, Object? Function(RequestOptions)>? routes,
  }) : routes = routes ?? {};

  final List<String> permissions;
  final Map<String, Object? Function(RequestOptions)> routes;

  late final ApiHarness harness = ApiHarness(
    FakeApiAdapter((o) async {
      if (o.path == ApiEndpoints.profile) {
        return FakeApiAdapter.jsonResponse(profileJson(permissions), 200);
      }
      final route = routes[o.path];
      if (route == null) {
        return FakeApiAdapter.jsonResponse({
          'success': false,
          'codigo': 'NO_ENCONTRADO',
          'error': 'Ruta de prueba no programada: ${o.path}',
        }, 404);
      }
      return FakeApiAdapter.jsonResponse({
        'success': true,
        'data': route(o),
      }, 200);
    }),
  );
}
