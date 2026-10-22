import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/core/utils/date_formatter.dart';
import 'package:sistema_oro/core/utils/text_formatter.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/models/order_payment.dart';

/// Textos ya listos para pintar. La vista no formatea nada.
extension OrderLabels on Order {
  String get clientLabel => formatPersonName(clientName);
  String get garmentLabel => formatDisplayText(garmentName);
  String get totalLabel => formatCop(total);
  String get paidLabel => formatCop(paid);
  String get balanceLabel => formatCop(balance);
  String get createdLabel => createdAt == null ? '' : formatDate(createdAt!);
  String get deadlineLabel => deadline == null ? '' : formatDate(deadline!);
  String get quantityLabel => quantity > 1 ? '$quantity unidades' : '';
  String get typeChipLabel => isLayaway ? 'Separación' : 'Compra';
  String get bankLabel => formatDisplayText(bank ?? '');
  String get codeLabel => 'Pedido $code';
  String get whatsappMessage =>
      'Hola $clientLabel, te escribo sobre tu pedido $code ($garmentLabel).';

  /// Recordatorio amable para un separado con saldo.
  String get reminderMessage =>
      'Hola $clientLabel 👋 Te escribimos con mucho cariño para recordarte tu '
      'separado de $garmentLabel. Tu saldo es de $balanceLabel y puedes abonar '
      'cuando te quede cómodo. ¡Gracias por confiar en nosotros! ✨';

  /// «Vence 19/11/2026» o «2 meses vencido».
  String get layawayDueLabel {
    if (monthsOverdue > 0) {
      return monthsOverdue == 1
          ? '1 mes vencido'
          : '$monthsOverdue meses vencido';
    }
    return deadline == null ? '' : 'Vence $deadlineLabel';
  }
}

extension OrderDetailLabels on OrderDetailFields {
  String get unitPriceLabel => formatCop(unitPrice);
  String get boxLabel =>
      decoratedBox ? 'Decorada · ${formatCop(boxPrice)}' : 'Gratis';
  String get subtotalLabel => formatCop(subtotal);
  String get surchargesLabel => formatCop(surcharges);
  String get minimumDepositLabel => formatCop(minimumDeposit);
  String get startedLabel => startedAt == null ? '' : formatDate(startedAt!);
  String get deliveredLabel =>
      deliveredAt == null ? '' : formatDate(deliveredAt!);
  String get percentLabel => '${layawayPercent.round()} %';
  String get addressLabel => [
    city,
    address,
  ].whereType<String>().where((t) => t.isNotEmpty).join(' · ');
}

extension PaymentLabels on OrderPayment {
  String get amountLabel => formatCop(amount);
  String get dateLabel => date == null ? '' : formatDate(date!);
  String get methodLabel => method.label;
  String get kindLabel => isInitial ? 'Pago inicial' : 'Abono';
  String get voidedLabel =>
      voidedAt == null ? 'Anulado' : 'Anulado el ${formatDate(voidedAt!)}';
}

extension CancellationLabels on OrderCancellation {
  String get paidLabel => formatCop(paid);
  String get retainedLabel => formatCop(retained);
  String get returnedLabel => formatCop(returned);
  String get whenLabel => cancelledAt == null ? '' : formatDate(cancelledAt!);
}

/// «Hoy», «Hace 1 día», «Hace 12 días» sin abonar.
String idleDaysLabel(int days) => switch (days) {
  0 => 'Abonó hoy',
  1 => 'Hace 1 día sin abonar',
  _ => 'Hace $days días sin abonar',
};
