import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';

/// Validaciones del formulario de abono (el servidor valida de nuevo).
abstract final class PaymentRules {
  static String? amount(double? value, double balance) {
    if (value == null || value <= 0) return 'Escribe el valor del abono.';
    if (value > balance) {
      return 'No puede superar el saldo (${formatCop(balance)}).';
    }
    return null;
  }

  static String? date(DateTime value, DateTime today) =>
      DateTime(
        value.year,
        value.month,
        value.day,
      ).isAfter(DateTime(today.year, today.month, today.day))
      ? 'La fecha no puede ser futura.'
      : null;

  /// Una transferencia exige su comprobante.
  static bool needsReceipt(PaymentMethod method) =>
      method == PaymentMethod.transfer;
}
