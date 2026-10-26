import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/utils/garment_labels.dart';
import 'package:sistema_oro/features/garments/providers/garment_photos_provider.dart';
import 'package:sistema_oro/features/garments/providers/garment_uploads_provider.dart';
import 'package:sistema_oro/features/garments/widgets/detail/garment_carousel.dart';
import 'package:sistema_oro/features/garments/widgets/detail/garment_upload_strip.dart';
import 'package:sistema_oro/shared/utils/listen_action.dart';
import 'package:sistema_oro/shared/utils/confirm_destructive.dart';
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
            _EmptyPhotos(garmentId: garment.id)
          else
            GarmentCarousel(
              images: garment.images,
              onRemove: canEdit
                  ? (image) => _confirmRemove(context, ref, image)
                  : null,
            ),
          if (garment.images.isNotEmpty) ...[
            GarmentUploadStrip(garmentId: garment.id),
          ],
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
    final confirmed = await confirmDestructive(
      context,
      title: 'Quitar foto',
      itemName: '${garment.nameLabel} · foto ${image.order}',
      message: 'La foto se elimina de la prenda y del catálogo.',
      confirmLabel: 'Quitar foto',
    );
    if (confirmed != null) {
      await ref
          .read(garmentPhotosProvider.notifier)
          .remove(garment.id, image.id);
    }
  }
}

/// Sin fotos todavía: si están subiendo, sus vistas previas; si no, el aviso.
class _EmptyPhotos extends ConsumerWidget {
  const _EmptyPhotos({required this.garmentId});

  final int garmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploading = ref.watch(
      garmentUploadsProvider.select((all) => all.containsKey(garmentId)),
    );
    return uploading
        ? GarmentUploadStrip(garmentId: garmentId)
        : Text(
            'Aún no hay fotos.',
            style: Theme.of(context).textTheme.bodySmall,
          );
  }
}
