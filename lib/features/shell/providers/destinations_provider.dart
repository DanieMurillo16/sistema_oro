import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/orders/models/order_detail.dart';
import 'package:sistema_oro/features/orders/providers/order_counters_provider.dart';
import 'package:sistema_oro/shared/navigation/app_destination.dart';

/// Los destinos del menú según los permisos del usuario. «Más» siempre está:
/// reúne clientes, ajustes, usuarios y cerrar sesión.
final destinationsProvider = Provider<List<AppDestination>>((ref) {
  bool can(String permission) => ref.watch(canProvider(permission));
  final counters =
      ref.watch(orderCountersProvider).value ?? OrderCounters.empty;
  return [
    if (can(Permissions.summaryView))
      const AppDestination(
        path: AppRoutes.summary,
        label: 'Resumen',
        icon: Icons.insights_outlined,
        selectedIcon: Icons.insights,
      ),
    if (can(Permissions.ordersView)) ...[
      AppDestination(
        path: AppRoutes.orders,
        label: 'Pedidos',
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
        badge: counters.pending,
      ),
      AppDestination(
        path: AppRoutes.layaways,
        label: 'Separados',
        icon: Icons.bookmark_border,
        selectedIcon: Icons.bookmark,
        badge: counters.overdueLayaways,
      ),
    ],
    if (can(Permissions.garmentsView))
      const AppDestination(
        path: AppRoutes.garments,
        label: 'Prendas',
        icon: Icons.diamond_outlined,
        selectedIcon: Icons.diamond,
      ),
    const AppDestination(
      path: AppRoutes.more,
      label: 'Más',
      icon: Icons.menu,
      selectedIcon: Icons.menu_open,
    ),
  ];
});

/// A dónde se va tras iniciar sesión: el primer destino que el usuario puede
/// ver. Función pura sobre la sesión (el router la usa en su `redirect`, donde
/// un provider derivado aún podría estar desactualizado).
String homePathFor(AppSession? session) {
  if (session == null) return AppRoutes.more;
  if (session.can(Permissions.summaryView)) return AppRoutes.summary;
  if (session.can(Permissions.ordersView)) return AppRoutes.orders;
  if (session.can(Permissions.garmentsView)) return AppRoutes.garments;
  if (session.can(Permissions.clientsView)) return AppRoutes.clients;
  return AppRoutes.more;
}

/// Qué destino del menú se marca para una ruta: «Clientes», «Ajustes» y
/// «Usuarios» viven dentro de «Más».
String menuPathFor(String location) {
  final first = location.split('/').where((s) => s.isNotEmpty).firstOrNull;
  if (first == null) return '/';
  final path = '/$first';
  return path == AppRoutes.settings ||
          path == AppRoutes.users ||
          path == AppRoutes.clients
      ? AppRoutes.more
      : path;
}
