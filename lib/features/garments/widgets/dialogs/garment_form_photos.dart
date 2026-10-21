import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/services/app_toast.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/garments/utils/garment_rules.dart';

/// Fotos que se agregan al crear la prenda (hasta 3). No suben nada: el
/// formulario las envía cuando la prenda ya existe.
class GarmentFormPhotos extends ConsumerWidget {
  const GarmentFormPhotos({
    super.key,
    required this.photos,
    required this.onChanged,
  });

  final List<PickedImage> photos;
  final ValueChanged<List<PickedImage>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fotos (hasta ${GarmentRules.maxImages})',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: DesignTokens.spaceXs),
        Wrap(
          spacing: DesignTokens.spaceSm,
          runSpacing: DesignTokens.spaceSm,
          children: [
            for (var i = 0; i < photos.length; i++)
              _PhotoPreview(
                image: photos[i],
                onRemove: () => onChanged([...photos]..removeAt(i)),
              ),
            if (photos.length < GarmentRules.maxImages)
              _AddPhotoButton(onPressed: () => _pick(ref)),
          ],
        ),
      ],
    );
  }

  Future<void> _pick(WidgetRef ref) async {
    final result = await ref.read(imagePickerServiceProvider).pick();
    if (result.problem != null) {
      AppToast.warning(result.problem!);
    } else if (result.image != null) {
      onChanged([...photos, result.image!]);
    }
  }
}

class _AddPhotoButton extends StatelessWidget {
  const _AddPhotoButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Agregar foto',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        child: Container(
          width: DesignTokens.thumbSize,
          height: DesignTokens.thumbSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            border: Border.all(color: scheme.outline),
          ),
          child: Icon(Icons.add_a_photo_outlined, color: scheme.secondary),
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.image, required this.onRemove});

  final PickedImage image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        child: Image.memory(
          image.bytes,
          width: DesignTokens.thumbSize,
          height: DesignTokens.thumbSize,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.square(
            dimension: DesignTokens.thumbSize,
            child: Icon(Icons.broken_image_outlined),
          ),
        ),
      ),
      Positioned(
        top: 2,
        right: 2,
        child: InkResponse(
          onTap: onRemove,
          radius: 14,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.55),
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ],
  );
}
