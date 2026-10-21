import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/network/api_client.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/core/utils/json_helpers.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/models/checkout_draft.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(ref.watch(apiClientProvider)),
);

/// Único acceso del catálogo público al servidor. Solo rutas `publico/*`.
class CatalogRepository {
  const CatalogRepository(this._api);

  final ApiClient _api;

  static const pageSize = 24;

  /// Lo máximo que acepta el servidor por petición.
  static const maxPageSize = 100;

  Future<List<CatalogType>> types() async =>
      jsonMapList(await _api.getList(ApiEndpoints.publicTypes))
          .map(CatalogType.fromJson)
          .toList();

  Future<CatalogSettings> settings() async =>
      CatalogSettings.fromJson(await _api.get(ApiEndpoints.publicSettings));

  Future<CatalogPage> garments({
    int? typeId,
    required String sort,
    int offset = 0,
    int limit = pageSize,
  }) async {
    final result = await _api.getPage(
      ApiEndpoints.publicGarments,
      queryParameters: {
        'tipo': ?typeId,
        'orden': sort,
        'limite': limit,
        'desplazamiento': offset,
      },
    );
    return CatalogPage(
      items: jsonMapList(result.items).map(CatalogGarment.fromJson).toList(),
      total: result.total,
    );
  }

  Future<CatalogGarment> garment(int id) async => CatalogGarment.fromJson(
    await _api.get(ApiEndpoints.publicGarment, queryParameters: {'id': id}),
  );

  /// Envía la compra o el separado con el comprobante (multipart).
  Future<RequestReceipt> submitRequest(
    CheckoutDraft draft,
    PickedImage receipt,
  ) async => RequestReceipt.fromJson(
    await _api.postForm(
      ApiEndpoints.publicRequest,
      FormData.fromMap({
        ...draft.toFields(),
        'comprobante': MultipartFile.fromBytes(
          receipt.bytes,
          filename: receipt.name,
          contentType: DioMediaType.parse(receipt.mimeType),
        ),
      }),
    ),
  );
}
