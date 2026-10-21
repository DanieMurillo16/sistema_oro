import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/network/api_client.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';
import 'package:sistema_oro/core/utils/json_helpers.dart';
import 'package:sistema_oro/features/clients/models/client.dart';

final clientsRepositoryProvider = Provider<ClientsRepository>(
  (ref) => ClientsRepository(ref.watch(apiClientProvider)),
);

class ClientsRepository {
  const ClientsRepository(this._api);

  final ApiClient _api;

  static const _pageSize = 200;
  static const _maxPages = 25;

  Future<List<Client>> fetchAll() async {
    final clients = <Client>[];
    for (var page = 0; page < _maxPages; page++) {
      final result = await _api.getPage(
        ApiEndpoints.clientsList,
        queryParameters: {
          'limite': _pageSize,
          'desplazamiento': clients.length,
        },
      );
      clients.addAll(jsonMapList(result.items).map(Client.fromJson));
      if (result.items.length < _pageSize || clients.length >= result.total) {
        break;
      }
    }
    return clients;
  }

  Future<Client> get(int id) async => Client.fromJson(
    await _api.get(ApiEndpoints.clientsGet, queryParameters: {'id': id}),
  );

  Future<void> edit(int id, {required String name, String? notes}) => _api.post(
    ApiEndpoints.clientsEdit,
    data: {'id': id, 'nombre': name, 'notas': ?notes},
  );
}
