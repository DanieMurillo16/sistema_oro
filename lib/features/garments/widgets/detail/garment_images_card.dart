import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/providers/garment_photos_provider.dart';
import 'package:sistema_oro/features/garments/widgets/detail/garment_carousel.dart';
import 'package:sistema_oro/shared/utils/listen_action.dart';
import 'package:sistema_oro/shared/widgets/confirm_action_dialog.dart';
import 'package:sistema_oro/shared/widgets/image_picker_field.dart';
import 'package:sistema_oro/shared/widgets/section_card.dart';

/// Las fotos de la prenda (hasta 3): ver, agregar y quitar. El servidor genera
/// la miniatura y la versión grande al subirlas.
class GarmentImagesCard extends ConsumerWidget {
  const GarmentImagesCard({
    super.key,
    required this.garment,
    required this.canEdit,
  });

  final Garment garment;
  final bool canEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    listenAction(ref, garmentPhotosProvider);
    final nextOrder = GarmentPhotosNotifier.nextOrder(
      garment.images.map((image) => image.order),
    );
    return SectionCard(
      title: 'Fotos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (garment.images.isEmpty)
            Text(
              'Aún no hay fotos.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            GarmentCarousel(
              images: garment.images,
              onRemove: canEdit
                  ? (image) => _confirmRemove(context, ref, image)
                  : null,
            ),
          if (canEdit && nextOrder != null) ...[
            const SizedBox(height: DesignTokens.spaceMd),
            ImagePickerField(
              image: null,
              label: 'Agregar foto',
              onChanged: (picked) {
                if (picked == null) return;
                ref
                    .read(garmentPhotosProvider.notifier)
                    .add(garment.id, order: nextOrder, image: picked);
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    GarmentImage image,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmActionDialog(
        title: 'Quitar foto',
        message: 'La foto se elimina de la prenda y del catálogo.',
        confirmLabel: 'Quitar foto',
        icon: Icons.delete_outline,
      ),
    );
    if (confirmed == true) {
      await ref
          .read(garmentPhotosProvider.notifier)
          .remove(garment.id, image.id);
    }
  }
}
