import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// Una fila de «Más»: icono en cuadro tenue, título y flecha.
class MoreTile extends StatelessWidget {
  const MoreTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.secondary;
    return Card(
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        leading: DecoratedBox(
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceSm),
            child: Icon(icon, color: accent),
          ),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
