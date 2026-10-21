import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/orders/data/orders_repository.dart';
import 'package:sistema_oro/features/orders/models/order_detail.dart';

/// El detalle de un pedido (pagos y cancelación). Se pide al entrar y se
/// invalida cuando una escritura lo cambia.
final orderDetailProvider = FutureProvider.autoDispose.family<OrderDetail, int>(
  (ref, id) {
    ref.watch(sessionUserIdProvider);
    return ref.read(ordersRepositoryProvider).getDetail(id);
  },
);

/// La imagen de un comprobante (privada: se descarga con el Bearer).
final receiptProvider = FutureProvider.autoDispose.family<Uint8List, String>(
  (ref, file) => ref.read(ordersRepositoryProvider).receipt(file),
);
