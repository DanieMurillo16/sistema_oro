import 'package:dio/dio.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';

import '../support/api_harness.dart';
import '../support/fake_api_adapter.dart';
import 'order_fixtures.dart';

// JSON con la forma que documenta backend/docs/API.md (publico/*).

Map<String, dynamic> publicGarment({
  int id = 11,
  String name = 'cadena cubana',
  int stock = 3,
  bool isNew = false,
  bool onSale = false,
  bool lastUnit = false,
  bool soldOut = false,
  String? previous,
}) => {
  'id_prenda': id,
  'nombre': name,
  'referencia': 'CAD-11',
  'tipo': 'cadenas',
  'tipo_oro': 'ITALIANO',
  'peso_gramos': '5.20',
  'largo_cm': '50.00',
  'ancho_cm': null,
  'grosor_mm': null,
  'precio_venta': '1000000.00',
  'precio_anterior': previous,
  'stock': stock,
  'es_nueva': isNew,
  'en_oferta': onSale,
  'ultima_unidad': lastUnit,
  'agotada': soldOut,
  'miniatura': null,
};

Map<String, dynamic> publicGarmentDetail(Map<String, dynamic> row) => {
  ...row,
  'descripcion': 'Cadena de eslabones cubanos',
  'valor_separado': '200000.00',
  'imagenes': [
    {
      'orden': 1,
      'url_miniatura': 'https://x.test/m1.jpg',
      'url_grande': 'https://x.test/g1.jpg',
    },
    {
      'orden': 2,
      'url_miniatura': 'https://x.test/m2.jpg',
      'url_grande': 'https://x.test/g2.jpg',
    },
  ],
};

const publicTypes = [
  {'id_tipo_prenda': 1, 'nombre': 'cadenas'},
  {'id_tipo_prenda': 2, 'nombre': 'pulseras'},
];

Map<String, dynamic> publicSettings({
  String whatsapp = '573001234567',
  String logoUrl = '',
}) => {
  'logo_url': logoUrl,
  'whatsapp_baron': whatsapp,
  'transferencia_banco': 'Bancolombia',
  'transferencia_cuenta': '123-456789-00',
  'transferencia_titular': 'Barón Joyero',
  'transferencia_texto': 'Envía el comprobante en este formulario.',
  'porcentaje_separado': '20',
  'recargo_mes_vencido': '80000.00',
  'precio_caja_decorada': '12000.00',
  'catalogo_mostrar_agotadas': true,
};

/// Servidor público falso: anota cada petición y responde por ruta. Las
/// respuestas de la solicitud se programan en [requestResponses] (una por envío).
class CatalogServer {
  CatalogServer({
    List<Map<String, dynamic>>? rows,
    this.whatsapp = '573001234567',
    this.logoUrl = '',
  }) : rows = rows ?? [publicGarment()];

  final List<Map<String, dynamic>> rows;
  final String whatsapp;
  final String logoUrl;
  final List<ResponseBody Function()> requestResponses = [];

  late final ApiHarness harness = ApiHarness(
    FakeApiAdapter((o) async {
      switch (o.path) {
        case ApiEndpoints.publicTypes:
          return FakeApiAdapter.jsonResponse({
            'success': true,
            'data': publicTypes,
          }, 200);
        case ApiEndpoints.publicSettings:
          return FakeApiAdapter.jsonResponse(
            okJson(publicSettings(whatsapp: whatsapp, logoUrl: logoUrl)),
            200,
          );
        case ApiEndpoints.publicGarments:
          return FakeApiAdapter.jsonResponse(listJson(rows), 200);
        case ApiEndpoints.publicGarment:
          final row = rows
              .where(
                (r) =>
                    r['id_prenda'].toString() == '${o.queryParameters['id']}',
              )
              .firstOrNull;
          // Vendida o separada por otra persona: ya no está en el catálogo.
          if (row == null) {
            return FakeApiAdapter.jsonResponse({
              'success': false,
              'codigo': 'NO_ENCONTRADO',
              'error': 'La prenda no está disponible.',
            }, 404);
          }
          return FakeApiAdapter.jsonResponse(
            okJson(publicGarmentDetail(row)),
            200,
          );
        case ApiEndpoints.publicRequest:
          if (requestResponses.isEmpty) {
            return FakeApiAdapter.jsonResponse({
              'success': false,
              'error': 'sin respuesta programada',
            }, 500);
          }
          return requestResponses.removeAt(0)();
      }
      return FakeApiAdapter.jsonResponse({
        'success': false,
        'codigo': 'NO_ENCONTRADO',
        'error': 'Ruta de prueba no programada: ${o.path}',
      }, 404);
    }),
    token: null,
  );

  static ResponseBody created(String code, {bool repeated = false}) =>
      FakeApiAdapter.jsonResponse(
        okJson({
          'codigo': code,
          'tipo': 'COMPRA',
          'estado': 'PENDIENTE',
          'repetida': repeated,
        }),
        201,
      );

  static ResponseBody failure(String code, String message, int status) =>
      FakeApiAdapter.jsonResponse({
        'success': false,
        'codigo': code,
        'error': message,
      }, status);
}
