import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/core/utils/date_formatter.dart';
import 'package:sistema_oro/core/utils/text_formatter.dart';
import 'package:sistema_oro/features/clients/models/client.dart';

extension ClientLabels on Client {
  String get nameLabel => formatPersonName(name);
  String get totalPaidLabel => formatCop(totalPaid);
  String get balanceLabel => formatCop(pendingBalance);
  String get sinceLabel => createdAt == null ? '' : formatDate(createdAt!);
  String get ordersLabel => orders == 1 ? '1 pedido' : '$orders pedidos';
  String get layawaysLabel => activeLayaways == 0
      ? ''
      : activeLayaways == 1
      ? '1 separado'
      : '$activeLayaways separados';
  String get whatsappMessage =>
      'Hola $nameLabel, te escribimos de Sistema Oro.';
}

extension ClientOrderLabels on ClientOrder {
  String get garmentLabel => formatDisplayText(garment);
  String get totalLabel => formatCop(total);
  String get balanceLabel => formatCop(balance);
  String get createdLabel => createdAt == null ? '' : formatDate(createdAt!);
  String get dueLabel {
    if (monthsOverdue > 0) {
      return monthsOverdue == 1
          ? '1 mes vencido'
          : '$monthsOverdue meses vencido';
    }
    return deadline == null ? '' : 'Vence ${formatDate(deadline!)}';
  }
}
