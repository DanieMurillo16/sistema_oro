import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/theme/status_colors.dart';
import 'package:sistema_oro/core/utils/text_formatter.dart';
import 'package:sistema_oro/features/clients/models/client.dart';
import 'package:sistema_oro/features/clients/utils/client_labels.dart';
import 'package:sistema_oro/shared/widgets/dot_separated_text.dart';
import 'package:sistema_oro/shared/widgets/title_with_amount.dart';

/// Un cliente en la lista: quién es, cuántos pedidos y cuánto debe.
class ClientTile extends StatelessWidget {
  const ClientTile({super.key, required this.client, required this.onTap});

  final Client client;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: DesignTokens.avatarSize / 2,
                backgroundColor: scheme.secondaryContainer,
                foregroundColor: scheme.secondary,
                child: Text(displayInitial(client.name)),
              ),
              const SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleWithAmount(
                      title: client.nameLabel,
                      amount: client.pendingBalance > 0
                          ? client.balanceLabel
                          : null,
                      amountColor: statusColor(context, StatusTone.warning),
                    ),
                    DotSeparatedText(
                      parts: [
                        client.whatsapp,
                        client.ordersLabel,
                        client.layawaysLabel,
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
