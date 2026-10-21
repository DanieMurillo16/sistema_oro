import 'package:sistema_oro/core/utils/json_helpers.dart';

/// El logo de la marca tal como lo guarda el servidor: la URL del que subió el
/// dueño (con `?v=` para la caché) o vacía si se usa el logo original de la app.
class BrandLogoState {
  const BrandLogoState({required this.url, required this.version});

  factory BrandLogoState.fromJson(Map<String, dynamic> json) => BrandLogoState(
    url: jsonString(json['logo_url']),
    version: jsonInt(json['logo_version']),
  );

  final String url;
  final int version;

  /// ¿Hay un logo propio? Si no, se usa el empaquetado.
  bool get isCustom => url.isNotEmpty;
}
