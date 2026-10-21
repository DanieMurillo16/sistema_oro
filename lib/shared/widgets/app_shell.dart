import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/shared/navigation/app_destination.dart';

/// Esqueleto de la app una vez dentro: menú y contenido.
///
/// - Ancho (>= `wideLayoutWidth`): menú lateral; extendido (con textos) desde
///   `expandedLayoutWidth`, plegado a iconos entre medias.
/// - Angosto: barra inferior. Máximo 5 destinos; si hay más, agrupar en un
///   cajón (ver `responsive.md`).
///
/// El contenido es el mismo [child] en los dos casos, así que cambiar de
/// tamaño no pierde lo que se estuviera haciendo.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.destinations,
    required this.currentPath,
    required this.onSelected,
    required this.child,
  });

  final List<AppDestination> destinations;
  final String currentPath;
  final ValueChanged<AppDestination> onSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Con un solo destino no hay nada que elegir (y NavigationBar pide dos).
    if (destinations.length < 2) return Scaffold(body: child);

    final selected = destinations.indexWhere((d) => d.path == currentPath);
    final index = selected < 0 ? 0 : selected;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width < DesignTokens.wideLayoutWidth) {
          return Scaffold(
            body: child,
            bottomNavigationBar: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => onSelected(destinations[i]),
              destinations: [
                for (final d in destinations)
                  NavigationDestination(
                    icon: _BadgedIcon(icon: d.icon, count: d.badge),
                    selectedIcon: _BadgedIcon(
                      icon: d.selectedIcon,
                      count: d.badge,
                    ),
                    label: d.label,
                  ),
              ],
            ),
          );
        }
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: width >= DesignTokens.expandedLayoutWidth,
                selectedIndex: index,
                onDestinationSelected: (i) => onSelected(destinations[i]),
                destinations: [
                  for (final d in destinations)
                    NavigationRailDestination(
                      icon: _BadgedIcon(icon: d.icon, count: d.badge),
                      selectedIcon: _BadgedIcon(
                        icon: d.selectedIcon,
                        count: d.badge,
                      ),
                      label: Text(d.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}

/// Icono del menú con la insignia de pendientes (si hay).
class _BadgedIcon extends StatelessWidget {
  const _BadgedIcon({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) => Badge(
    isLabelVisible: count > 0,
    label: Text('$count'),
    child: Icon(icon),
  );
}
