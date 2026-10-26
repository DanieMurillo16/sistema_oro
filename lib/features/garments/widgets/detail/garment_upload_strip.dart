import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/theme/status_colors.dart';
import 'package:sistema_oro/features/garments/models/photo_upload.dart';
import 'package:sistema_oro/features/garments/providers/garment_uploads_provider.dart';

/// Las fotos de una prenda recién creada que aún suben, con su vista previa
/// local, el avance de cada una y «Reintentar» si alguna falló. No dice nada
/// si no hay subidas en curso.
class GarmentUploadStrip extends ConsumerWidget {
  const GarmentUploadStrip({super.key, required this.garmentId});

  final int garmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploads = ref.watch(
      garmentUploadsProvider.select((all) => all[garmentId]),
    );
    if (uploads == null || uploads.isEmpty) return const SizedBox.shrink();
    final failed = uploads.any((u) => u.status == UploadStatus.failed);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: DesignTokens.spaceSm,
          runSpacing: DesignTokens.spaceSm,
          children: [for (final u in uploads) _UploadThumb(upload: u)],
        ),
        const SizedBox(height: DesignTokens.spaceSm),
        Row(
          children: [
            Expanded(
              child: Text(
                failed
                    ? 'Algunas fotos no se pudieron subir.'
                    : 'Subiendo fotos… ya puedes seguir con lo tuyo.',
                style: textTheme.bodySmall?.copyWith(
                  color: failed ? statusColor(context, StatusTone.error) : null,
                ),
              ),
            ),
            if (failed)
              TextButton.icon(
                onPressed: () =>
                    ref.read(garmentUploadsProvider.notifier).retry(garmentId),
                icon: const Icon(Icons.refresh, size: DesignTokens.iconSm),
                label: const Text('Reintentar'),
              ),
          ],
        ),
      ],
    );
  }
}

class _UploadThumb extends StatelessWidget {
  const _UploadThumb({required this.upload});

  final PhotoUpload upload;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final failed = upload.status == UploadStatus.failed;
    final done = upload.status == UploadStatus.done;
    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      child: SizedBox.square(
        dimension: DesignTokens.thumbSize,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(upload.image.bytes, fit: BoxFit.cover),
            if (!done)
              ColoredBox(
                color: (failed ? scheme.error : scheme.scrim).withValues(
                  alpha: 0.45,
                ),
                child: Center(
                  child: failed
                      ? Icon(Icons.error_outline, color: scheme.onError)
                      : const SizedBox.square(
                          dimension: DesignTokens.progressSize,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
