import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/config/app_config.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/core/network/api_adapter.dart'
    if (dart.library.js_interop) 'package:sistema_oro/core/network/api_adapter_web.dart';
import 'package:sistema_oro/core/network/api_response.dart';
import 'package:sistema_oro/core/services/session_expiration.dart';
import 'package:sistema_oro/core/services/token_storage.dart';

/// El único cliente HTTP de la app. Los repositorios lo reciben por provider.
final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    tokenStorage: tokenStorage,
    onUnauthorized: () async {
      await tokenStorage.clear();
      ref.read(sessionExpirationProvider.notifier).notify();
    },
  );
});

/// Una página de una lista: los elementos recibidos y el total en el servidor.
class ApiPage {
  const ApiPage(this.items, this.total);

  final List<dynamic> items;
  final int total;
}

class ApiClient {
  ApiClient({
    required String baseUrl,
    required TokenStorage tokenStorage,
    required this.onUnauthorized,
    HttpClientAdapter? adapter,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: const Duration(seconds: 15),
           receiveTimeout: const Duration(seconds: 20),
           sendTimeout: const Duration(seconds: 15),
           headers: const {'Accept': 'application/json'},
         ),
       ) {
    _dio.httpClientAdapter = adapter ?? createApiAdapter();
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.data == null) options.sendTimeout = null;
          final token = await tokenStorage.read();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final Future<void> Function() onUnauthorized;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _request(
      () => _dio.get<Object?>(path, queryParameters: queryParameters),
    );
    return response.asMap();
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _request(
      () => _dio.get<Object?>(path, queryParameters: queryParameters),
    );
    return response.asList();
  }

  /// Lista paginada: los elementos y el `total` que dice `meta`.
  Future<ApiPage> getPage(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _request(
      () => _dio.get<Object?>(path, queryParameters: queryParameters),
    );
    final items = response.asList();
    final total = response.meta['total'];
    return ApiPage(items, total is num ? total.toInt() : items.length);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _request(() => _dio.post<Object?>(path, data: data));
    return response.asMap();
  }

  /// Envío `multipart/form-data` (imágenes y comprobantes).
  Future<Map<String, dynamic>> postForm(String path, FormData data) async {
    final response = await _request(
      () => _dio.post<Object?>(
        path,
        data: data,
        options: Options(sendTimeout: const Duration(seconds: 60)),
      ),
    );
    return response.asMap();
  }

  /// Descarga archivos privados (el comprobante exige el Bearer).
  Future<Uint8List> getBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        path,
        queryParameters: queryParameters,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data ?? const []);
    } on DioException catch (error) {
      if (error.response?.statusCode == 401 &&
          error.requestOptions.headers.containsKey('Authorization')) {
        await onUnauthorized();
      }
      throw _mapBytesError(error);
    }
  }

  /// El error de una descarga llega como bytes: se lee el JSON del backend.
  AppException _mapBytesError(DioException error) {
    final data = error.response?.data;
    if (data is List<int>) {
      Object? json;
      try {
        json = jsonDecode(utf8.decode(data));
      } on FormatException {
        json = null;
      }
      if (json is Map) {
        return ApiException(
          json['error']?.toString() ?? 'No fue posible descargar el archivo.',
          code: json['codigo']?.toString(),
          statusCode: error.response?.statusCode,
        );
      }
    }
    return _mapDioError(error);
  }

  Future<ApiResponse> _request(
    Future<Response<Object?>> Function() request,
  ) async {
    try {
      final response = await request();
      return ApiResponse.fromRaw(response.data);
    } on AppException {
      rethrow;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401 &&
          error.requestOptions.headers.containsKey('Authorization')) {
        await onUnauthorized();
      }
      throw _mapDioError(error);
    } on FormatException {
      throw const UnexpectedException(
        'El servidor devolvió datos incompletos.',
      );
    } catch (_) {
      throw const UnexpectedException('No fue posible procesar la respuesta.');
    }
  }

  /// Traduce un `DioException` a un error propio con mensaje en español ya
  /// listo para mostrar. La UI nunca ve un `DioException`.
  AppException _mapDioError(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map) {
      final json = Map<String, dynamic>.from(responseData);
      return ApiException(
        json['error']?.toString() ?? 'No fue posible completar la operación.',
        code: json['codigo']?.toString(),
        statusCode: error.response?.statusCode,
      );
    }
    if (error.response?.statusCode == 404) {
      return const ApiException(
        'La ruta solicitada no está instalada en el servidor.',
        code: 'RUTA_NO_INSTALADA',
        statusCode: 404,
      );
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const NetworkException(
        'El servidor tardó demasiado en responder. Intenta nuevamente.',
      );
    }
    return const NetworkException(
      'No fue posible conectar con el servidor. Revisa tu conexión.',
    );
  }
}
