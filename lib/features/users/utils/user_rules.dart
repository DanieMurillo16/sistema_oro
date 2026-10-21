import 'package:sistema_oro/features/users/models/managed_user.dart';

abstract final class UserRules {
  static const passwordMin = 8;
  static const passwordMax = 72;

  static String? name(String? value) =>
      (value ?? '').trim().length < 2 ? 'Escribe el nombre completo.' : null;

  static String? username(String? value) {
    final text = (value ?? '').trim();
    if (text.length < 3) return 'El usuario necesita mínimo 3 caracteres.';
    if (text.contains(' ')) return 'El usuario no puede tener espacios.';
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.length < passwordMin) {
      return 'La contraseña necesita mínimo $passwordMin caracteres.';
    }
    return null;
  }

  static String? role(UserRole? value) =>
      value == null ? 'Elige el rol.' : null;
}
