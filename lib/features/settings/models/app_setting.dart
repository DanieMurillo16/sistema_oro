import 'package:sistema_oro/core/utils/json_helpers.dart';

enum SettingKind {
  text('TEXTO'),
  integer('ENTERO'),
  money('DINERO'),
  percent('PORCENTAJE'),
  boolean('BOOLEANO');

  const SettingKind(this.api);

  final String api;

  static SettingKind fromApi(String? value) =>
      values.firstWhere((k) => k.api == value, orElse: () => text);
}

/// Un ajuste editable de la app (WhatsApp, transferencia, %, recargo, caja…).
class AppSetting {
  const AppSetting({
    required this.key,
    required this.value,
    required this.kind,
    required this.description,
    required this.isPublic,
    required this.updatedAt,
  });

  factory AppSetting.fromJson(Map<String, dynamic> json) => AppSetting(
    key: jsonString(json['clave']),
    value: jsonString(json['valor']),
    kind: SettingKind.fromApi(jsonStringOrNull(json['tipo'])),
    description: jsonString(json['descripcion']),
    isPublic: jsonBool(json['publico']),
    updatedAt: jsonDateOrNull(json['actualizado_en']),
  );

  final String key;
  final String value;
  final SettingKind kind;
  final String description;
  final bool isPublic;
  final DateTime? updatedAt;
}
