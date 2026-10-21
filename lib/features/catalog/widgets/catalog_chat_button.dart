import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/services/link_launcher.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';
import 'package:sistema_oro/shared/widgets/app_action_button.dart';

/// Icono de WhatsApp de la cabecera; no aparece si Barón aún no puso su número.
class CatalogChatButton extends ConsumerWidget {
  const CatalogChatButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final whatsapp = ref.watch(catalogSettingsProvider).value?.whatsapp ?? '';
    if (whatsapp.isEmpty) return const SizedBox.shrink();
    return AppActionButton(
      icon: Icons.chat_outlined,
      tooltip: 'Escríbenos por WhatsApp',
      onPressed: () => ref
          .read(linkLauncherProvider)
          .openWhatsApp(
            whatsapp,
            message: 'Hola, quiero información sobre el catálogo.',
          ),
    );
  }
}
