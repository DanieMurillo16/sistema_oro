sealed class AppException implements Exception {
  const AppException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;
}

final class ApiException extends AppException {
  const ApiException(super.message, {super.code, super.statusCode});
}

final class NetworkException extends AppException {
  const NetworkException(super.message);
}

final class ConfigurationException extends AppException {
  const ConfigurationException(super.message);
}

final class UnexpectedException extends AppException {
  const UnexpectedException(super.message);
}

String userErrorMessage(Object? error) {
  if (error is AppException) return error.message;
  return 'Ocurrió un error inesperado. Intenta nuevamente.';
}
