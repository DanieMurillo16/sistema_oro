import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Una petición que llegó al adaptador falso: lo que la app REALMENTE envió.
class RecordedRequest {
  RecordedRequest(this.options, this.body);

  final RequestOptions options;
  final Object? body;

  String get path => options.path;
  String get method => options.method;
  String? get authorization => options.headers['Authorization'] as String?;
  Map<String, dynamic> get query => options.queryParameters;

  /// El cuerpo JSON enviado, como mapa (falla si no era un objeto).
  Map<String, dynamic> get bodyMap => Map<String, dynamic>.from(body! as Map);
}

/// Adaptador de Dio que responde con lo que le programes. Sin red real.
/// Se usa con [ApiHarness] para probar repositorios y vistas de punta a punta:
/// widget → provider → repositorio → ApiClient → (aquí se corta).
class FakeApiAdapter implements HttpClientAdapter {
  /// Respuesta calculada por ruta: `(options) async => jsonResponse({...}, 200)`.
  FakeApiAdapter(this._handler);

  /// Responde siempre [body] (JSON) con [status].
  FakeApiAdapter.json(Object? body, {int status = 200})
    : _handler = ((_) async => jsonResponse(body, status));

  /// Falla como si no hubiera conexión.
  FakeApiAdapter.connectionError()
    : _handler = ((options) async => throw DioException.connectionError(
        requestOptions: options,
        reason: 'sin red',
      ));

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  /// Todo lo que la app envió, en orden.
  final requests = <RecordedRequest>[];

  /// Las peticiones a [path] (la constante de `ApiEndpoints`).
  List<RecordedRequest> to(String path) =>
      requests.where((r) => r.path == path).toList();

  static ResponseBody jsonResponse(Object? body, int status) {
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(RecordedRequest(options, options.data));
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}
