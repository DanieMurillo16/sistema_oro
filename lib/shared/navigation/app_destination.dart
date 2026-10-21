import 'package:flutter/material.dart';

/// Un destino del menú. Los destinos que ve cada usuario (según permisos) los
/// decide el provider de la app; el shell solo los dibuja.
class AppDestination {
  const AppDestination({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.badge = 0,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  /// Cantidad pendiente (insignia); 0 = sin insignia.
  final int badge;
}
