import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/services/app_toast.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// Adjuntar una foto (comprobante, imagen de prenda): botón, vista previa y
/// quitar. No sube nada: entrega la imagen elegida con [onChanged].
class ImagePickerField extends ConsumerWidget {
  const ImagePickerField({
    super.key,
    required this.image,
    required this.onChanged,
    this.label = 'Adjuntar comprobante',
    this.errorText,
  });

  final PickedImage? image;
  final ValueChanged<PickedImage?> onChanged;
  final String label;
  final String? errorText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (image == null)
          OutlinedButton.icon(
            onPressed: () => _pick(ref),
            icon: const Icon(Icons.attach_file),
            label: Text(label),
          )
        else
          // Una sola fila: miniatura, nombre y, a la derecha, solo dos iconos
          // (cambiar y quitar).
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outline),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceSm),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    child: Image.memory(
                      image!.bytes,
                      width: DesignTokens.thumbSize,
                      height: DesignTokens.thumbSize,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.square(
                        dimension: DesignTokens.thumbSize,
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceSm),
                  Expanded(
                    child: Text(
                      image!.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cambiar imagen',
                    onPressed: () => _pick(ref),
                    icon: const Icon(Icons.swap_horiz_rounded),
                  ),
                  IconButton(
                    tooltip: 'Quitar imagen',
                    onPressed: () => onChanged(null),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: scheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: DesignTokens.spaceXs),
            child: Text(
              errorText!,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.error),
            ),
          ),
      ],
    );
  }

  Future<void> _pick(WidgetRef ref) async {
    final result = await ref.read(imagePickerServiceProvider).pick();
    if (result.problem != null) {
      AppToast.warning(result.problem!);
    } else if (result.image != null) {
      onChanged(result.image);
    }
  }
}
