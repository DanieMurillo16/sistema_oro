import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/app.dart';
import 'package:sistema_oro/core/utils/provider_retry.dart';
import 'package:sistema_oro/core/router/catalog_router.dart';
import 'package:sistema_oro/core/theme/app_theme.dart';

/// Entrada del catálogo público (clara, sin login). Se compila aparte
/// (`scripts/build_catalogo.sh`): no incluye el router, la sesión ni las
/// pantallas de la administración.
void main() => runApp(
  ProviderScope(
    retry: noProviderRetry,
    child: App(theme: AppTheme.catalog, routerProvider: catalogRouterProvider),
  ),
);
