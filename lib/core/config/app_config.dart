import 'package:sistema_oro/core/errors/app_exception.dart';

abstract final class AppConfig {
  // CAMBIAR POR PROYECTO
  static const String appName = 'Sistema Oro';

  /// Nombre comercial que ve el público en el catálogo.
  static const String catalogName = 'Baron Golden Boss';

  static const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// La URL de la API sale de `--dart-define=API_BASE_URL=...` (o de
  /// `.env.json` con `--dart-define-from-file`). Nunca escrita en el código.
  static String get apiBaseUrl {
    if (_apiBaseUrl.trim().isEmpty) {
      throw const ConfigurationException(
        'Falta configurar la dirección del servidor.',
      );
    }
    return _apiBaseUrl.endsWith('/') ? _apiBaseUrl : '$_apiBaseUrl/';
  }
}
