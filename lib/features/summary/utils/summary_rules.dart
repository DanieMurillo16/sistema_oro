/// Reglas puras del selector de mes de la vista de resumen.
abstract final class SummaryRules {
  static const _months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  /// El primer día del mes de [date].
  static DateTime firstOfMonth(DateTime date) =>
      DateTime(date.year, date.month);

  /// `AAAA-MM`, que es lo que pide el servidor.
  static String key(DateTime month) =>
      '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}';

  /// «octubre 2026».
  static String label(DateTime month) =>
      '${_months[month.month - 1]} ${month.year}';

  /// El mes [delta] meses antes (negativo) o después (positivo).
  static DateTime shift(DateTime month, int delta) =>
      DateTime(month.year, month.month + delta);

  /// No se avanza más allá del mes actual: no hay cifras del futuro.
  static bool canGoNext(DateTime month, DateTime now) =>
      !shift(month, 1).isAfter(firstOfMonth(now));
}
