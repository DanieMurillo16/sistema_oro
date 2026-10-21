import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/services/link_launcher.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';

/// «Te la conseguimos»: para quien no encuentra la prenda. Lleva al WhatsApp de
/// Barón con el mensaje ya armado. El número viene de los ajustes públicos.
class FindItBanner extends ConsumerWidget {
  const FindItBanner({super.key});

  static const message =
      'Hola, no encontré la prenda que busco en el catálogo. ¿Me ayudan a conseguirla?';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final whatsapp = ref.watch(catalogSettingsProvider).value?.whatsapp ?? '';
    if (whatsapp.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppCatalogColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.catalogPhotoRadius),
        border: Border.all(color: AppCatalogColors.gold.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceLg),
        child: Wrap(
          spacing: DesignTokens.spaceLg,
          runSpacing: DesignTokens.spaceMd,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: DesignTokens.catalogBannerTextWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Te la conseguimos',
                    style: textTheme.headlineSmall?.copyWith(
                      color: AppCatalogColors.goldText,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceXs),
                  Text(
                    '¿No encuentras la prenda que buscas? Cuéntanos cuál es y la conseguimos para ti.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppCatalogColors.text,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () => ref
                  .read(linkLauncherProvider)
                  .openWhatsApp(whatsapp, message: message),
              icon: const Icon(Icons.chat_outlined),
              label: const Text('Escríbenos'),
            ),
          ],
        ),
      ),
    );
  }
}
