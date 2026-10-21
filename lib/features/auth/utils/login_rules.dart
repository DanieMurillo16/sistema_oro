/// Reglas del formulario de ingreso (el servidor valida de nuevo).
abstract final class LoginRules {
  static const usernameMax = 50;
  static const passwordMax = 72;

  static String? username(String? value) =>
      (value ?? '').trim().isEmpty ? 'Escribe tu usuario.' : null;

  static String? password(String? value) =>
      (value ?? '').isEmpty ? 'Escribe tu contraseña.' : null;
}
