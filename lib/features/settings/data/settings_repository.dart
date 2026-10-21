import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/core/utils/json_helpers.dart';
import 'package:sistema_oro/features/settings/models/app_setting.dart';
import 'package:sistema_oro/features/settings/models/brand_logo_state.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(apiClientProvider)),
);

class SettingsRepository {
  const SettingsRepository(this._api);

  final ApiClient _api;

  Future<List<AppSetting>> list() async =>
      jsonMapList(await _api.getList(ApiEndpoints.settingsList))
          .map(AppSetting.fromJson)
          .toList();

  Future<BrandLogoState> logo() async =>
      BrandLogoState.fromJson(await _api.get(ApiEndpoints.settingsLogo));

  /// Sube el logo nuevo (multipart); el servidor lo valida y lo reduce.
  Future<BrandLogoState> uploadLogo(PickedImage image) async =>
      BrandLogoState.fromJson(
        await _api.postForm(
          ApiEndpoints.settingsLogoUpload,
          FormData.fromMap({
            'imagen': MultipartFile.fromBytes(
              image.bytes,
              filename: image.name,
              contentType: DioMediaType.parse(image.mimeType),
            ),
          }),
        ),
      );

  /// Vuelve al logo original de la app.
  Future<BrandLogoState> restoreLogo() async => BrandLogoState.fromJson(
    await _api.post(ApiEndpoints.settingsLogoRestore, data: const {}),
  );

  /// [value] es texto, número o booleano; el servidor lo valida según el tipo.
  Future<AppSetting> save(String key, Object value) async =>
      AppSetting.fromJson(
        await _api.post(
          ApiEndpoints.settingsSave,
          data: {'clave': key, 'valor': value},
        ),
      );
}
