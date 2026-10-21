import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/app.dart';
import 'package:sistema_oro/core/utils/provider_retry.dart';
import 'package:sistema_oro/core/router/app_router.dart';
import 'package:sistema_oro/core/theme/app_theme.dart';

/// Entrada de la administración (oscura, con login).
void main() => runApp(
  ProviderScope(
    retry: noProviderRetry,
    child: App(theme: AppTheme.dark, routerProvider: appRouterProvider),
  ),
);
