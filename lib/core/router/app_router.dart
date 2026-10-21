import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/core/router/session_redirect.dart';
import 'package:sistema_oro/features/auth/login_screen.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/clients/client_detail_screen.dart';
import 'package:sistema_oro/features/clients/clients_screen.dart';
import 'package:sistema_oro/features/garments/garment_detail_screen.dart';
import 'package:sistema_oro/features/garments/garments_screen.dart';
import 'package:sistema_oro/features/layaways/layaways_screen.dart';
import 'package:sistema_oro/features/more/more_screen.dart';
import 'package:sistema_oro/features/orders/order_detail_screen.dart';
import 'package:sistema_oro/features/orders/orders_screen.dart';
import 'package:sistema_oro/features/shell/main_shell.dart';
import 'package:sistema_oro/features/shell/providers/destinations_provider.dart';
import 'package:sistema_oro/features/settings/settings_screen.dart';
import 'package:sistema_oro/features/splash/splash_screen.dart';
import 'package:sistema_oro/features/summary/summary_screen.dart';
import 'package:sistema_oro/features/users/users_screen.dart';

/// Router de la administración. La sesión decide a dónde se va (ver
/// `sessionRedirect`); las pantallas del menú viven dentro de `MainShell`.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    // Necesario para que `AppToast` y los diálogos de SmartDialog se coordinen
    // con la navegación.
    observers: [FlutterSmartDialog.observer],
    redirect: (context, state) => sessionRedirect(
      session: ref.read(sessionProvider),
      location: state.matchedLocation,
      homePath: homePathFor(ref.read(sessionProvider).value),
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            MainShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.summary,
            builder: (context, state) => const SummaryScreen(),
          ),
          GoRoute(
            path: AppRoutes.orders,
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: AppRoutes.orderPattern,
            builder: (context, state) => OrderDetailScreen(
              id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
              backRoute: state.uri.queryParameters['from'] ?? AppRoutes.orders,
            ),
          ),
          GoRoute(
            path: AppRoutes.layaways,
            builder: (context, state) => const LayawaysScreen(),
          ),
          GoRoute(
            path: AppRoutes.layawayPattern,
            builder: (context, state) => OrderDetailScreen(
              id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
              backRoute:
                  state.uri.queryParameters['from'] ?? AppRoutes.layaways,
            ),
          ),
          GoRoute(
            path: AppRoutes.garments,
            builder: (context, state) => const GarmentsScreen(),
          ),
          GoRoute(
            path: AppRoutes.garmentPattern,
            builder: (context, state) => GarmentDetailScreen(
              id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
            ),
          ),
          GoRoute(
            path: AppRoutes.clients,
            builder: (context, state) => const ClientsScreen(),
          ),
          GoRoute(
            path: AppRoutes.clientPattern,
            builder: (context, state) => ClientDetailScreen(
              id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
            ),
          ),
          GoRoute(
            path: AppRoutes.more,
            builder: (context, state) => const MoreScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.users,
            builder: (context, state) => const UsersScreen(),
          ),
        ],
      ),
    ],
  );
});
