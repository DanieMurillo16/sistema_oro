import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/features/catalog/catalog_garment_screen.dart';
import 'package:sistema_oro/features/catalog/catalog_screen.dart';

/// Router del catálogo público. Aparte del de la administración para que el
/// build del catálogo no arrastre sus pantallas.
final catalogRouterProvider = Provider<GoRouter>((ref) {
  // Cada prenda que se abre con push queda en el historial del navegador: la
  // URL cambia (se puede compartir) y «atrás» vuelve a la prenda anterior.
  GoRouter.optionURLReflectsImperativeAPIs = true;
  return GoRouter(
    initialLocation: AppRoutes.catalog,
    observers: [FlutterSmartDialog.observer],
    routes: [
      GoRoute(
        path: AppRoutes.catalog,
        builder: (context, state) => const CatalogScreen(),
        routes: [
          GoRoute(
            path: AppRoutes.catalogGarmentPattern,
            // Fundido corto: deja que la foto de la tarjeta «viaje» al detalle.
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              transitionDuration: const Duration(milliseconds: 420),
              reverseTransitionDuration: const Duration(milliseconds: 320),
              child: CatalogGarmentScreen(
                id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
              ),
              transitionsBuilder: (context, animation, secondary, child) =>
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                    child: child,
                  ),
            ),
          ),
        ],
      ),
    ],
  );
});
