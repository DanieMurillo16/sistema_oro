import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/network/api_client.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/core/utils/date_formatter.dart';
import 'package:sistema_oro/core/utils/json_helpers.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>(
  (ref) => PaymentsRepository(ref.watch(apiClientProvider)),
);

class PaymentsRepository {
  const PaymentsRepository(this._api);

  final ApiClient _api;

  /// Registra un abono (multipart: el comprobante es obligatorio si es
  /// transferencia). El monto viaja como texto con 2 decimales.
  Future<Map<String, dynamic>> register({
    required int orderId,
    required int amount,
    required DateTime date,
    required PaymentMethod method,
    PickedImage? receipt,
  }) => _api.postForm(
    ApiEndpoints.paymentsRegister,
    FormData.fromMap({
      'id_pedido': orderId,
      'monto': moneyText(amount),
      'fecha': apiDate(date),
      'medio': method.api,
      if (receipt != null)
        'comprobante': MultipartFile.fromBytes(
          receipt.bytes,
          filename: receipt.name,
          contentType: DioMediaType.parse(receipt.mimeType),
        ),
    }),
  );

  Future<Map<String, dynamic>> voidPayment(int paymentId, String reason) =>
      _api.post(
        ApiEndpoints.paymentsVoid,
        data: {'id_pago': paymentId, 'motivo': reason},
      );
}
