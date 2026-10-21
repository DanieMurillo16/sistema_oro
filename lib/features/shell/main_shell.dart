import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/features/shell/providers/destinations_provider.dart';
import 'package:sistema_oro/features/shell/providers/preload_provider.dart';
import 'package:sistema_oro/shared/widgets/app_shell.dart';

/// Marco de la administración: menú (rail o barra inferior) y el contenido de
/// la ruta activa.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Precarga todas las listas al entrar (y las refresca en silencio).
    ref.watch(appPreloadProvider);
    return AppShell(
      destinations: ref.watch(destinationsProvider),
      currentPath: menuPathFor(location),
      onSelected: (destination) => context.go(destination.path),
      child: child,
    );
  }
}
