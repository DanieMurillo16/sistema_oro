import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/network/api_client.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/core/utils/json_helpers.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/models/garment_draft.dart';

final garmentsRepositoryProvider = Provider<GarmentsRepository>(
  (ref) => GarmentsRepository(ref.watch(apiClientProvider)),
);

class GarmentsRepository {
  const GarmentsRepository(this._api);

  final ApiClient _api;

  static const _pageSize = 200;
  static const _maxPages = 25;

  /// Todo el inventario (páginas de 200; se guarda completo para buscar local).
  Future<List<Garment>> fetchAll() async {
    final garments = <Garment>[];
    for (var page = 0; page < _maxPages; page++) {
      final result = await _api.getPage(
        ApiEndpoints.garmentsList,
        queryParameters: {
          'limite': _pageSize,
          'desplazamiento': garments.length,
        },
      );
      garments.addAll(jsonMapList(result.items).map(Garment.fromJson));
      if (result.items.length < _pageSize || garments.length >= result.total) {
        break;
      }
    }
    return garments;
  }

  Future<Garment> get(int id) async => Garment.fromJson(
    await _api.get(ApiEndpoints.garmentsGet, queryParameters: {'id': id}),
  );

  Future<int> create(GarmentDraft draft) async {
    final json = await _api.post(
      ApiEndpoints.garmentsCreate,
      data: draft.toCreateJson(),
    );
    return jsonInt(json['id_prenda']);
  }

  Future<void> edit(int id, GarmentDraft draft) =>
      _api.post(ApiEndpoints.garmentsEdit, data: draft.toEditJson(id));

  /// Eliminación lógica: la prenda sale del catálogo y del inventario, pero el
  /// historial de pedidos la sigue mostrando. [reason] es opcional.
  Future<void> delete(int id, {String? reason}) => _api.post(
    ApiEndpoints.garmentsDelete,
    data: {'id': id, 'motivo': ?reason},
  );

  Future<int> adjustStock(
    int id, {
    required int delta,
    required String reason,
  }) async {
    final json = await _api.post(
      ApiEndpoints.garmentsAdjustStock,
      data: {'id': id, 'cantidad': delta, 'motivo': reason},
    );
    return jsonInt(json['stock']);
  }

  Future<void> addImage(
    int id, {
    required int order,
    required PickedImage image,
  }) => _api.postForm(
    ApiEndpoints.garmentsImageAdd,
    FormData.fromMap({
      'id': id,
      'orden': order,
      'imagen': MultipartFile.fromBytes(
        image.bytes,
        filename: image.name,
        contentType: DioMediaType.parse(image.mimeType),
      ),
    }),
  );

  Future<void> removeImage(int imageId) =>
      _api.post(ApiEndpoints.garmentsImageRemove, data: {'id_imagen': imageId});

  // --- Tipos ---

  Future<List<GarmentType>> types() async =>
      jsonMapList(await _api.getList(ApiEndpoints.typesList))
          .map(GarmentType.fromJson)
          .toList();

  Future<GarmentType> saveType({
    int? id,
    required String name,
    required int order,
    required bool active,
  }) async => GarmentType.fromJson(
    await _api.post(
      ApiEndpoints.typesSave,
      data: {'id': ?id, 'nombre': name, 'orden': order, 'activo': active},
    ),
  );
}
