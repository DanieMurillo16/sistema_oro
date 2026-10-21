import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/services/link_launcher.dart';
import 'package:sistema_oro/features/clients/models/client.dart';
import 'package:sistema_oro/features/clients/utils/client_labels.dart';
import 'package:sistema_oro/shared/widgets/app_action_button.dart';
import 'package:sistema_oro/shared/widgets/info_grid.dart';
import 'package:sistema_oro/shared/widgets/section_card.dart';

/// Los datos del cliente y el acceso rápido a su WhatsApp.
class ClientInfoCard extends ConsumerWidget {
  const ClientInfoCard({super.key, required this.client});

  final Client client;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SectionCard(
    title: 'Datos',
    trailing: AppActionButton(
      icon: Icons.chat_outlined,
      tooltip: 'Escribir por WhatsApp',
      onPressed: () => ref
          .read(linkLauncherProvider)
          .openWhatsApp(client.whatsapp, message: client.whatsappMessage),
    ),
    child: InfoGrid(
      items: [
        InfoItem('WhatsApp', client.whatsapp),
        if (client.sinceLabel.isNotEmpty)
          InfoItem('Cliente desde', client.sinceLabel),
        InfoItem('Total pagado', client.totalPaidLabel),
        InfoItem('Saldo pendiente', client.balanceLabel, strong: true),
        if (client.notes != null) InfoItem('Notas', client.notes!, wide: true),
      ],
    ),
  );
}
