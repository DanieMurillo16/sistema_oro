import 'package:flutter/material.dart';
import 'package:sistema_oro/shared/widgets/app_action_button.dart';
import 'package:sistema_oro/core/utils/text_formatter.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

class DialogHeader extends StatelessWidget {
  const DialogHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
    this.onClose,
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback? onClose;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.secondary;
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.all(
        MediaQuery.viewInsetsOf(context).bottom > 0
            ? DesignTokens.spaceMd
            : DesignTokens.spaceLg,
      ),
      child: Row(
        children: [
          _HeaderIcon(icon: icon, color: accent),
          const SizedBox(width: DesignTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatDisplayText(title),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (subtitle != null)
                  Text(
                    formatDisplayText(subtitle!),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          ...actions,
          AppActionButton(
            tooltip: 'Cerrar',
            onPressed: onClose ?? () => Navigator.of(context).pop(),
            icon: Icons.close_rounded,
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceSm),
        child: Icon(icon, color: color),
      ),
    );
  }
}
