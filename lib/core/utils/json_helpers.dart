/// Lectura tolerante del JSON del backend: las llaves no se tocan, estos
/// ayudantes solo convierten tipos. El dinero llega como texto con 2 decimales
/// (`"12500.00"`) y se parsea aquí, nunca con `as double`.
Map<String, dynamic> jsonMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<Map<String, dynamic>> jsonMapList(Object? value) =>
    value is List ? value.map(jsonMap).toList() : <Map<String, dynamic>>[];

String jsonString(Object? value, [String fallback = '']) =>
    value == null ? fallback : value.toString();

String? jsonStringOrNull(Object? value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}

int jsonInt(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? jsonIntOrNull(Object? value) => value == null ? null : jsonInt(value, 0);

bool jsonBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == '1';
}

double jsonDecimal(Object? value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

double? jsonDecimalOrNull(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

/// Fecha `AAAA-MM-DD` o fecha y hora `AAAA-MM-DD HH:MM:SS` (hora Colombia).
DateTime? jsonDateOrNull(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text.replaceFirst(' ', 'T'));
}

/// Dinero que se envía: texto con 2 decimales, nunca `double`.
String moneyText(int pesos) => '$pesos.00';
