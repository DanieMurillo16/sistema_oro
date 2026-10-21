import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/theme/status_colors.dart';
import 'package:sistema_oro/core/utils/text_formatter.dart';
import 'package:sistema_oro/features/users/models/managed_user.dart';
import 'package:sistema_oro/shared/widgets/app_action_button.dart';
import 'package:sistema_oro/shared/widgets/dot_separated_text.dart';
import 'package:sistema_oro/shared/widgets/status_chip.dart';

/// Un usuario: quién es, su rol y si está activo, con sus acciones.
class UserTile extends StatelessWidget {
  const UserTile({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onPassword,
  });

  final ManagedUser user;
  final VoidCallback onEdit;
  final VoidCallback onPassword;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatPersonName(user.name),
                    style: textTheme.titleSmall,
                  ),
                  DotSeparatedText(
                    parts: [
                      user.username,
                      formatDisplayText(user.role.toLowerCase()),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceXs),
                  StatusChip(
                    label: user.active ? 'Activo' : 'Inactivo',
                    tone: user.active ? StatusTone.success : StatusTone.neutral,
                  ),
                ],
              ),
            ),
            AppActionButton(
              icon: Icons.key_outlined,
              tooltip: 'Cambiar contraseña',
              onPressed: onPassword,
            ),
            const SizedBox(width: DesignTokens.spaceXs),
            AppActionButton(
              icon: Icons.edit_outlined,
              tooltip: 'Editar usuario',
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}
