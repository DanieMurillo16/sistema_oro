/// Una medida o peso sin ceros de sobra y con coma decimal (el punto es el
/// separador de miles del dinero): `5.20` → «5,2», `50.00` → «50».
String formatMeasure(double? value) {
  if (value == null) return '';
  final text = value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  return text.replaceAll('.', ',');
}
