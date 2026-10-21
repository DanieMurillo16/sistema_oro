import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// Franja de confianza compacta: tres razones para comprar separadas por
/// divisores finos, sin cajas. Solo dice lo que el negocio ofrece de verdad:
/// oro nacional e italiano, separar con el 20 % y completar en abonos, recoger
/// en tienda o recibir en casa.
class CatalogTrustStrip extends StatelessWidget {
  const CatalogTrustStrip({super.key});

  static const _items = [
    (
      Icons.workspace_premium_outlined,
      'Oro nacional e italiano',
      'Peso y medidas a la vista',
    ),
    (Icons.bookmark_border, 'Separa con el 20 %', 'Completa en abonos'),
    (
      Icons.local_shipping_outlined,
      'Recoge o recibe en casa',
      'Tú eliges cómo',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final line = BorderSide(color: AppCatalogColors.border);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: line, bottom: line),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final row = constraints.maxWidth >= 3 * 230 * scale;
          final items = [
            for (final (icon, title, subtitle) in _items)
              _Item(icon: icon, title: title, subtitle: subtitle),
          ];
          if (!row) {
            return Column(
              children: [
                for (final (index, item) in items.indexed) ...[
                  if (index > 0) Divider(height: 1, color: line.color),
                  item,
                ],
              ],
            );
          }
          return IntrinsicHeight(
            child: Row(
              children: [
                for (final (index, item) in items.indexed) ...[
                  if (index > 0) VerticalDivider(width: 1, color: line.color),
                  Expanded(child: item),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceMd,
        vertical: DesignTokens.spaceMd,
      ),
      child: Row(
        children: [
          Icon(icon, size: 26, color: AppCatalogColors.gold),
          const SizedBox(width: DesignTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleSmall),
                Text(subtitle, style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
