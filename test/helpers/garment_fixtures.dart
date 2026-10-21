import 'package:sistema_oro/core/network/api_endpoints.dart';

import '../support/api_harness.dart';
import '../support/fake_api_adapter.dart';
import 'order_fixtures.dart';

// JSON con la forma que documenta backend/docs/API.md (dinero y medidas como texto).

const ownerGarmentPermissions = [
  'prendas.ver',
  'prendas.crear',
  'prendas.editar',
  'prendas.ver_costo',
  'prendas.ajustar_stock',
  'tipos.gestionar',
];

/// Empleado: solo ve el inventario, sin costo ni edición.
const viewerGarmentPermissions = ['prendas.ver'];

Map<String, dynamic> garmentRow({
  int id = 11,
  String name = 'cadena cubana',
  int stock = 2,
  bool active = true,
  String? previous,
  String? purchase = '700000.00',
}) => {
  'id_prenda': id,
  'nombre': name,
  'referencia': 'CAD-11',
  'id_tipo_prenda': 1,
  'tipo': 'cadenas',
  'tipo_oro': 'ITALIANO',
  'peso_gramos': '5.20',
  'largo_cm': '50.00',
  'ancho_cm': null,
  'grosor_mm': null,
  'precio_venta': '1000000.00',
  'precio_anterior': previous,
  'precio_compra': purchase,
  'stock': stock,
  'activa': active,
  'publicada_en': '2026-10-01 09:00:00',
  'solicitudes_pendientes': 0,
  'miniatura': null,
};

Map<String, dynamic> garmentDetailJson(Map<String, dynamic> row) => okJson({
  ...row,
  'descripcion': 'Cadena de eslabones cubanos',
  'imagenes': <Map<String, dynamic>>[],
});

const typesJson = [
  {
    'id_tipo_prenda': 1,
    'nombre': 'cadenas',
    'orden': 1,
    'activo': true,
    'prendas': 1,
  },
  {
    'id_tipo_prenda': 2,
    'nombre': 'pulseras',
    'orden': 2,
    'activo': true,
    'prendas': 0,
  },
];

/// Servidor falso de prendas y tipos.
class GarmentsServer {
  GarmentsServer({
    this.permissions = ownerGarmentPermissions,
    List<Map<String, dynamic>>? rows,
  }) : rows = rows ?? [garmentRow()];

  final List<String> permissions;
  final List<Map<String, dynamic>> rows;
  final Map<String, Map<String, dynamic> Function()> writes = {};

  /// Rutas que fallan con 500 (para probar qué pasa si algo sale mal a mitad).
  final Set<String> failing = {};

  late final ApiHarness harness = ApiHarness(
    FakeApiAdapter((o) async {
      if (failing.contains(o.path)) {
        return FakeApiAdapter.jsonResponse({
          'success': false,
          'codigo': 'ERROR_INTERNO',
          'error': 'No se pudo completar.',
        }, 500);
      }
      final write = writes[o.path];
      if (write != null) {
        return FakeApiAdapter.jsonResponse(okJson(write()), 200);
      }
      return switch (o.path) {
        ApiEndpoints.profile => FakeApiAdapter.jsonResponse(
          profileJson(permissions),
          200,
        ),
        ApiEndpoints.garmentsList => FakeApiAdapter.jsonResponse(
          listJson(rows),
          200,
        ),
        ApiEndpoints.garmentsGet => FakeApiAdapter.jsonResponse(
          garmentDetailJson(
            rows.firstWhere(
              (r) => r['id_prenda'].toString() == '${o.queryParameters['id']}',
            ),
          ),
          200,
        ),
        ApiEndpoints.typesList => FakeApiAdapter.jsonResponse({
          'success': true,
          'data': typesJson,
        }, 200),
        _ => FakeApiAdapter.jsonResponse({
          'success': false,
          'codigo': 'NO_ENCONTRADO',
          'error': 'Ruta de prueba no programada: ${o.path}',
        }, 404),
      };
    }),
  );
}
