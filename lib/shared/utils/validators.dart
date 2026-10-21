import 'package:sistema_oro/core/utils/text_formatter.dart';

/// Validaciones comunes a varias features (mensajes ya listos en español).
abstract final class Validators {
  /// Un motivo escrito de verdad: mínimo [min] letras.
  static String? reason(String? value, {int min = 3}) =>
      formatDisplayText(value ?? '').length < min
      ? 'Cuéntanos el motivo (mínimo $min letras).'
      : null;
}
