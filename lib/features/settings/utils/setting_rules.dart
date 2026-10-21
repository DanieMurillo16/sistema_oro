import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/core/utils/json_helpers.dart';
import 'package:sistema_oro/features/settings/models/app_setting.dart';

/// Un ajuste con el nombre que ve Barón y el grupo donde va.
class SettingInfo {
  const SettingInfo(this.label, this.group);

  final String label;
  final String group;
}

/// Reglas de los ajustes: nombres legibles, orden, cómo se muestran y cómo se
/// validan y envían. El servidor valida de nuevo según el tipo.
abstract final class SettingRules {
  static const groups = ['Datos de pago', 'Separados', 'Catálogo', 'Otros'];

  static const _known = {
    'whatsapp_baron': SettingInfo('WhatsApp de Barón', 'Datos de pago'),
    'transferencia_banco': SettingInfo('Banco', 'Datos de pago'),
    'transferencia_cuenta': SettingInfo('Número de cuenta', 'Datos de pago'),
    'transferencia_titular': SettingInfo(
      'Titular de la cuenta',
      'Datos de pago',
    ),
    'transferencia_texto': SettingInfo(
      'Texto para quien transfiere',
      'Datos de pago',
    ),
    'porcentaje_separado': SettingInfo('Porcentaje para separar', 'Separados'),
    'recargo_mes_vencido': SettingInfo('Recargo por mes vencido', 'Separados'),
    'precio_caja_decorada': SettingInfo(
      'Precio de la caja decorada',
      'Catálogo',
    ),
    'dias_prenda_nueva': SettingInfo('Días con la etiqueta NUEVO', 'Catálogo'),
    'catalogo_mostrar_agotadas': SettingInfo(
      'Mostrar prendas agotadas',
      'Catálogo',
    ),
  };

  static SettingInfo infoOf(AppSetting s) =>
      _known[s.key] ??
      SettingInfo(s.description.isEmpty ? s.key : s.description, 'Otros');

  /// Los ajustes de [group] en el orden en que se declararon arriba.
  static List<AppSetting> inGroup(List<AppSetting> all, String group) {
    final keys = _known.keys.toList();
    final items = all.where((s) => infoOf(s).group == group).toList()
      ..sort((a, b) => keys.indexOf(a.key).compareTo(keys.indexOf(b.key)));
    return items;
  }

  /// El valor listo para mostrar en la lista.
  static String display(AppSetting s) {
    if (s.value.isEmpty) return 'Sin definir';
    return switch (s.kind) {
      SettingKind.money => formatCop(jsonDecimal(s.value)),
      SettingKind.percent => '${jsonDecimal(s.value).round()} %',
      SettingKind.boolean => jsonBool(s.value) ? 'Sí' : 'No',
      _ => s.value,
    };
  }

  /// Valor inicial del campo al editar.
  static String initialInput(AppSetting s) => switch (s.kind) {
    SettingKind.money => formatCopInput(jsonDecimal(s.value)),
    SettingKind.percent => '${jsonDecimal(s.value).round()}',
    _ => s.value,
  };

  static String? validate(AppSetting s, String? input) {
    final text = (input ?? '').trim();
    switch (s.kind) {
      case SettingKind.text:
        return s.key == 'whatsapp_baron' && text.isNotEmpty && !_isPhone(text)
            ? 'Escribe el número con indicativo, solo dígitos (573001234567).'
            : null;
      case SettingKind.integer:
        final n = int.tryParse(text);
        return n == null || n < 0 ? 'Escribe un número entero.' : null;
      case SettingKind.money:
        final n = parseCopInput(text);
        return n == null ? 'Escribe el valor en pesos.' : null;
      case SettingKind.percent:
        final n = int.tryParse(text);
        return n == null || n < 1 || n > 100
            ? 'Escribe un porcentaje entre 1 y 100.'
            : null;
      case SettingKind.boolean:
        return null;
    }
  }

  /// Lo que se envía: dinero como texto con 2 decimales, el resto como texto.
  static Object toApi(AppSetting s, String input) => switch (s.kind) {
    SettingKind.money => moneyText(parseCopInput(input)!.round()),
    SettingKind.boolean => input == 'true',
    _ => input.trim(),
  };

  static bool _isPhone(String text) => RegExp(r'^\d{10,15}$').hasMatch(text);
}
