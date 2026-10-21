import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/services/link_launcher.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';

/// El botón flotante de WhatsApp (círculo de la marca). Se oculta si Barón aún
/// no configuró su número.
class WhatsAppFab extends ConsumerWidget {
  const WhatsAppFab({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final whatsapp = ref.watch(catalogSettingsProvider).value?.whatsapp ?? '';
    if (whatsapp.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return FloatingActionButton(
      heroTag: 'catalog_whatsapp',
      tooltip: 'Escríbenos por WhatsApp',
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      onPressed: () => ref
          .read(linkLauncherProvider)
          .openWhatsApp(whatsapp, message: message),
      child: const Icon(Icons.chat),
    );
  }
}
