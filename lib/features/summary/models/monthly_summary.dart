import 'package:sistema_oro/core/utils/json_helpers.dart';

/// Los agregados de un mes que devuelve `resumen/obtener.php` (el servidor suma;
/// la app no calcula dinero). La ganancia estimada llega solo con el permiso de
/// ver costos: sin él es `null`.
class MonthlySummary {
  const MonthlySummary({
    required this.month,
    required this.salesAmount,
    required this.salesCount,
    required this.estimatedProfit,
    required this.paymentsAmount,
    required this.paymentsCount,
    required this.receivable,
    required this.activeLayaways,
    required this.overdueLayaways,
    required this.surcharges,
    required this.dueSoonLayaways,
    required this.pendingRequests,
    required this.newClients,
    required this.totalClients,
    required this.garments,
    required this.units,
    required this.inventoryValue,
  });

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    final sales = jsonMap(json['ventas']);
    final payments = jsonMap(json['abonos']);
    final due = jsonMap(json['por_cobrar']);
    final overdue = jsonMap(json['vencidos']);
    final clients = jsonMap(json['clientes']);
    final stock = jsonMap(json['inventario']);
    return MonthlySummary(
      month: jsonString(json['mes']),
      salesAmount: jsonDecimal(sales['monto']),
      salesCount: jsonInt(sales['cantidad']),
      estimatedProfit: jsonDecimalOrNull(json['ganancia_estimada']),
      paymentsAmount: jsonDecimal(payments['monto']),
      paymentsCount: jsonInt(payments['cantidad']),
      receivable: jsonDecimal(due['saldo']),
      activeLayaways: jsonInt(due['separados']),
      overdueLayaways: jsonInt(overdue['cantidad']),
      surcharges: jsonDecimal(overdue['recargos']),
      dueSoonLayaways: jsonInt(overdue['por_vencer']),
      pendingRequests: jsonInt(json['solicitudes_pendientes']),
      newClients: jsonInt(clients['nuevos']),
      totalClients: jsonInt(clients['total']),
      garments: jsonInt(stock['prendas']),
      units: jsonInt(stock['unidades']),
      inventoryValue: jsonDecimal(stock['valor_venta']),
    );
  }

  /// Mes al que corresponden las cifras, `AAAA-MM`.
  final String month;
  final double salesAmount;
  final int salesCount;
  final double? estimatedProfit;
  final double paymentsAmount;
  final int paymentsCount;
  final double receivable;
  final int activeLayaways;
  final int overdueLayaways;
  final double surcharges;
  final int dueSoonLayaways;
  final int pendingRequests;
  final int newClients;
  final int totalClients;
  final int garments;
  final int units;
  final double inventoryValue;

  bool get canSeeProfit => estimatedProfit != null;
}
