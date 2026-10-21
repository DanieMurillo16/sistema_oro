import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/core/utils/measure_formatter.dart';
import 'package:sistema_oro/core/utils/text_formatter.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/shared/utils/search_options.dart';

/// Pestañas de la lista de prendas.
enum GarmentsTab {
  all('Todas'),
  inStock('Con stock'),
  soldOut('Agotadas');

  const GarmentsTab(this.label);

  final String label;
}

/// Reglas puras de prendas: validaciones (mensajes listos en español),
/// normalización de medidas y filtrado de la lista.
abstract final class GarmentRules {
  static const maxImages = 3;

  static String? name(String? value) {
    final text = (value ?? '').trim();
    if (text.length < 2) return 'Escribe el nombre de la prenda.';
    return null;
  }

  static String? type(GarmentType? value) =>
      value == null ? 'Elige el tipo de prenda.' : null;

  /// El peso es obligatorio y mayor que cero.
  static String? weight(String? value) {
    final parsed = parseDecimal(value);
    return parsed == null || parsed <= 0 ? 'Escribe el peso en gramos.' : null;
  }

  /// Medidas opcionales: vacías valen; si se escriben, deben ser mayores que 0.
  static String? optionalMeasure(String? value) {
    if ((value ?? '').trim().isEmpty) return null;
    final parsed = parseDecimal(value);
    return parsed == null || parsed <= 0
        ? 'Debe ser un número mayor a 0.'
        : null;
  }

  static String? salePrice(double? value) =>
      value == null || value <= 0 ? 'Escribe el precio de venta.' : null;

  /// Si hay precio anterior (oferta), debe ser mayor que el de venta.
  static String? previousPrice(double? previous, double? sale) {
    if (previous == null) return null;
    if (sale != null && previous <= sale) {
      return 'Debe ser mayor al precio de venta.';
    }
    return null;
  }

  static String? stock(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    return parsed == null || parsed < 0
        ? 'Escribe cuántas unidades hay.'
        : null;
  }

  /// Ajuste de stock: entero distinto de cero que no deje el stock negativo.
  static String? stockDelta(String? value, int currentStock) {
    final delta = int.tryParse((value ?? '').trim());
    if (delta == null || delta == 0) {
      return 'Escribe una cantidad distinta de 0.';
    }
    if (currentStock + delta < 0) {
      return 'No puedes quitar más de las $currentStock unidades que hay.';
    }
    return null;
  }

  /// «5,2» o «5.20» → «5.20». `null` si está vacío o no es número.
  static String? decimalText(String? value) {
    final parsed = parseDecimal(value);
    return parsed?.toStringAsFixed(2);
  }

  static double? parseDecimal(String? value) {
    final text = (value ?? '').trim().replaceAll(',', '.');
    return text.isEmpty ? null : double.tryParse(text);
  }

  /// Valor inicial de un campo de medida al editar.
  static String measureInput(double? value) => formatMeasure(value);

  static String moneyInput(double? value) =>
      value == null ? '' : formatCopInput(value);

  static List<Garment> filtered(
    List<Garment> all,
    GarmentsTab tab,
    String query,
  ) {
    final byTab = switch (tab) {
      GarmentsTab.all => all,
      GarmentsTab.inStock => all.where((g) => !g.soldOut),
      GarmentsTab.soldOut => all.where((g) => g.soldOut),
    };
    final text = normalizeSearch(query);
    if (text.isEmpty) return byTab.toList();
    return byTab
        .where(
          (g) => normalizeSearch(
            '${formatDisplayText(g.name)} ${g.reference ?? ''} ${g.typeName}',
          ).contains(text),
        )
        .toList();
  }
}
