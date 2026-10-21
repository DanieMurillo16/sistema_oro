import 'package:sistema_oro/core/errors/app_exception.dart';

class ApiResponse {
  const ApiResponse({required this.data, this.meta = const {}});

  factory ApiResponse.fromRaw(Object? raw) {
    if (raw is! Map) {
      throw const UnexpectedException(
        'El servidor devolvió una respuesta no válida.',
      );
    }

    final json = Map<String, dynamic>.from(raw);
    if (json['success'] != true) {
      throw ApiException(
        json['error']?.toString() ?? 'No fue posible completar la operación.',
        code: json['codigo']?.toString(),
      );
    }

    if (!json.containsKey('data')) {
      throw const UnexpectedException(
        'Faltan datos en la respuesta del servidor.',
      );
    }

    final meta = json['meta'];
    return ApiResponse(
      data: json['data'],
      meta: meta is Map ? Map<String, dynamic>.from(meta) : const {},
    );
  }

  final Object? data;

  /// `{total, limite, desplazamiento}` en las listas paginadas.
  final Map<String, dynamic> meta;

  Map<String, dynamic> asMap() {
    if (data is! Map) {
      throw const UnexpectedException(
        'El servidor no devolvió el objeto esperado.',
      );
    }
    return Map<String, dynamic>.from(data! as Map);
  }

  List<dynamic> asList() {
    if (data is! List) {
      throw const UnexpectedException(
        'El servidor no devolvió la lista esperada.',
      );
    }
    return List<dynamic>.from(data! as List);
  }
}
