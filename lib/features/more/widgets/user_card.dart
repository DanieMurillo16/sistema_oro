import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/text_formatter.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';

/// Quién tiene la sesión abierta.
class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        child: Row(
          children: [
            CircleAvatar(
              radius: DesignTokens.avatarSize / 2,
              backgroundColor: scheme.secondaryContainer,
              foregroundColor: scheme.secondary,
              child: Text(displayInitial(user.name)),
            ),
            const SizedBox(width: DesignTokens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatPersonName(user.name),
                    style: textTheme.titleMedium,
                  ),
                  Text(
                    '${formatDisplayText(user.role.toLowerCase())} · ${user.username}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
