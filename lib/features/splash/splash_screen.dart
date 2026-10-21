import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/config/app_config.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/splash/widgets/splash_retry.dart';
import 'package:sistema_oro/shared/widgets/app_appear.dart';
import 'package:sistema_oro/shared/widgets/app_page_dots.dart';
import 'package:sistema_oro/shared/widgets/brand_mark.dart';

/// Pantalla de arranque de la administración: se ve mientras se recupera la
/// sesión guardada. Si no se pudo (sin red), ofrece reintentar. No decide a
/// dónde ir: eso lo hace el router según la sesión.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final session = ref.watch(sessionProvider);
    final failed = session.hasError && !session.isLoading;
    return Scaffold(
      body: SafeArea(
        // Desplazable: con letra ampliada o poca altura el contenido no se
        // corta; si cabe, queda centrado.
        child: Center(
          child: SingleChildScrollView(
            padding: DesignTokens.pagePadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: DesignTokens.splashTextMaxWidth,
              ),
              child: AppAppear(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BrandMark(),
                    const SizedBox(height: DesignTokens.spaceLg),
                    Text(
                      AppConfig.appName,
                      style: textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DesignTokens.spaceSm),
                    Text(
                      'Pedidos, separados y clientes, en un solo lugar.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DesignTokens.spaceXl),
                    if (failed)
                      SplashRetry(
                        message: userErrorMessage(session.error),
                        onRetry: () => ref.invalidate(sessionProvider),
                      )
                    else
                      const AppPageDots(count: 3),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
