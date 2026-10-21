import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/network/api_client.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';
import 'package:sistema_oro/core/utils/json_helpers.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

class AuthRepository {
  const AuthRepository(this._api);

  final ApiClient _api;

  Future<LoginResult> login(String username, String password) async {
    final json = await _api.post(
      ApiEndpoints.login,
      data: {'usuario': username, 'clave': password},
    );
    return LoginResult(
      session: AppSession.fromJson(json),
      token: jsonString(json['token']),
    );
  }

  Future<AppSession> profile() async =>
      AppSession.fromJson(await _api.get(ApiEndpoints.profile));

  Future<void> logout() => _api.post(ApiEndpoints.logout);
}
