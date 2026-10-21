import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/shared/widgets/app_toggle_option.dart';

/// Una opción dentro de [AppToggle]: icono y texto que cambian de color al
/// elegirse. Se toca por su `InkWell`.
class AppToggleOptionTile<T> extends StatelessWidget {
  const AppToggleOptionTile({
    super.key,
    required this.option,
    required this.chosen,
    required this.enabled,
    required this.compact,
    required this.onTap,
  });

  final AppToggleOption<T> option;
  final bool chosen;
  final bool enabled;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = !enabled
        ? scheme.onSurfaceVariant.withValues(alpha: 0.5)
        : chosen
        ? scheme.onPrimary
        : scheme.onSurfaceVariant;
    final style = compact
        ? Theme.of(context).textTheme.labelMedium
        : Theme.of(context).textTheme.labelLarge;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? DesignTokens.spaceSm : DesignTokens.spaceMd,
            vertical: DesignTokens.spaceXs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (option.icon != null) ...[
                Icon(option.icon, size: DesignTokens.iconSm, color: color),
                const SizedBox(width: DesignTokens.spaceXs),
              ],
              Flexible(
                // Si la etiqueta no cabe, se encoge en una sola línea (nunca se
                // parte una palabra a la mitad).
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    option.label,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: style?.copyWith(
                      color: color,
                      fontWeight: chosen ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
