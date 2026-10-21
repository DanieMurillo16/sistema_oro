import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/clients/providers/clients_provider.dart';
import 'package:sistema_oro/features/garments/providers/garment_types_provider.dart';
import 'package:sistema_oro/features/garments/providers/garments_provider.dart';
import 'package:sistema_oro/features/orders/providers/order_counters_provider.dart';
import 'package:sistema_oro/features/orders/providers/orders_provider.dart';
import 'package:sistema_oro/features/settings/providers/settings_provider.dart';

/// Cada cuánto se refrescan, sin que se note, las listas que no son pedidos
/// (los pedidos ya se refrescan solos con el contador). `null` en pruebas.
final preloadRefreshIntervalProvider = Provider<Duration?>(
  (ref) => const Duration(seconds: 60),
);

/// Al entrar a la administración pide TODAS las listas a la vez (pedidos,
/// prendas, clientes, tipos, ajustes e insignia) para que al abrir cualquier
/// pantalla ya estén cargadas, y luego las refresca en silencio cada minuto.
/// Cada lista solo se pide si la sesión tiene su permiso (el propio provider
/// lo decide). Se vuelve a ejecutar si cambia la sesión.
final appPreloadProvider = Provider<void>((ref) {
  final userId = ref.watch(sessionUserIdProvider);
  if (userId == null) return;
  ref.read(ordersProvider);
  ref.read(garmentsProvider);
  ref.read(clientsProvider);
  ref.read(garmentTypesProvider);
  ref.read(settingsProvider);
  ref.read(orderCountersProvider);
  final interval = ref.read(preloadRefreshIntervalProvider);
  if (interval == null) return;
  final timer = Timer.periodic(interval, (_) {
    unawaited(ref.read(garmentsProvider.notifier).refreshQuietly());
    unawaited(ref.read(clientsProvider.notifier).refreshQuietly());
  });
  ref.onDispose(timer.cancel);
});
