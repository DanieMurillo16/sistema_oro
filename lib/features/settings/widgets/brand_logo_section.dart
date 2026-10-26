import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/core/services/app_toast.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/settings/providers/settings_provider.dart';
import 'package:sistema_oro/features/settings/widgets/brand_logo_preview.dart';
import 'package:sistema_oro/shared/utils/confirm_destructive.dart';
import 'package:sistema_oro/shared/widgets/section_card.dart';

/// «Logo de la marca»: vista previa sobre fondo oscuro (así se ve en el
/// catálogo), «Cambiar logo» y «Restaurar logo original». Cambiarlo se refleja
/// en el catálogo sin recompilar (al recargar la página).
class BrandLogoSection extends ConsumerWidget {
  const BrandLogoSection({super.key});

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(imagePickerServiceProvider).pick();
    if (!context.mounted) return;
    final problem = result.problem;
    if (problem != null) return AppToast.warning(problem);
    final image = result.image;
    if (image == null) return;
    final confirmed = await confirmDestructive(
      context,
      title: 'Cambiar el logo',
      message:
          'El catálogo mostrará el logo nuevo en lugar del actual. Puedes '
          'volver al original cuando quieras.',
      confirmLabel: 'Cambiar logo',
      icon: Icons.swap_horiz,
    );
    if (confirmed == null || !context.mounted) return;
    await ref.read(brandLogoActionsProvider.notifier).change(image);
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDestructive(
      context,
      title: 'Restaurar el logo original',
      message:
          'El catálogo volverá a mostrar el logo original de la app. '
          'El logo que subiste se borra del servidor.',
      confirmLabel: 'Restaurar',
      icon: Icons.restore,
    );
    if (confirmed != null) {
      await ref.read(brandLogoActionsProvider.notifier).restore();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(brandLogoActionsProvider, (previous, next) {
      if (previous?.isLoading != true) return;
      if (next.hasError) AppToast.error(userErrorMessage(next.error));
      final message = next.value;
      if (message != null) AppToast.success(message);
    });
    final canEdit = ref.watch(canProvider(Permissions.settingsEdit));
    final logo = ref.watch(brandLogoProvider);
    final busy = ref.watch(brandLogoActionsProvider).isLoading;
    final textTheme = Theme.of(context).textTheme;
    return SectionCard(
      title: 'Logo de la marca',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: BrandLogoPreview(
              url: logo.value?.url ?? '',
              loading: logo.isLoading && !logo.hasValue,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          Text(
            logo.hasError
                ? 'No se pudo cargar el logo. ${userErrorMessage(logo.error)}'
                : 'Se ve en la cabecera y la portada del catálogo, sobre fondo '
                      'negro. Mejor un PNG de al menos 400 px, con fondo transparente.',
            style: textTheme.bodySmall,
          ),
          if (logo.hasError)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => ref.invalidate(brandLogoProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Intentar nuevamente'),
              ),
            ),
          if (busy) ...[
            const SizedBox(height: DesignTokens.spaceSm),
            const LinearProgressIndicator(minHeight: 2),
          ],
          if (canEdit) ...[
            const SizedBox(height: DesignTokens.spaceMd),
            Wrap(
              spacing: DesignTokens.spaceSm,
              runSpacing: DesignTokens.spaceSm,
              children: [
                FilledButton.icon(
                  onPressed: busy ? null : () => _pick(context, ref),
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Cambiar logo'),
                ),
                if (logo.hasValue && logo.requireValue.isCustom)
                  OutlinedButton.icon(
                    onPressed: busy ? null : () => _restore(context, ref),
                    icon: const Icon(Icons.restore),
                    label: const Text('Restaurar logo original'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
