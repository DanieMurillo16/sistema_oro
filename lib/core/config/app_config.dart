import 'package:sistema_oro/core/errors/app_exception.dart';

abstract final class AppConfig {
  // CAMBIAR POR PROYECTO
  static const String appName = 'Sistema Oro';

  /// Nombre comercial que ve el público en el catálogo.
  static const String catalogName = 'Baron Golden Boss';

  /// Servidor de producción. Es la dirección pública de la API (no es un
  /// secreto: viaja en cada petición). Se usa cuando no se pasa
  /// `--dart-define`, así `flutter build ios` y `flutter run` funcionan solos.
  static const _defaultApiBaseUrl = 'https://cobros.com.co/bd_oro/';

  static const _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultApiBaseUrl,
  );

  /// `--dart-define=API_BASE_URL=...` (o `.env.json` con
  /// `--dart-define-from-file`) tiene prioridad, p. ej. para apuntar a un
  /// servidor de pruebas. Sin eso se usa [_defaultApiBaseUrl].
  static String get apiBaseUrl {
    if (_apiBaseUrl.trim().isEmpty) {
      throw const ConfigurationException(
        'Falta configurar la dirección del servidor.',
      );
    }
    return _apiBaseUrl.endsWith('/') ? _apiBaseUrl : '$_apiBaseUrl/';
  }
}
