import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_photo.dart';
import 'package:sistema_oro/features/catalog/widgets/zoomable_photo.dart';
import 'package:sistema_oro/shared/widgets/app_page_dots.dart';

/// Abre el visor de fotos de la prenda: una ventana oscura con la foto grande
/// que se acerca con pellizco o doble toque, se desliza a las otras fotos y se
/// cierra con la «x» o tocando fuera.
Future<void> showGalleryZoom(
  BuildContext context, {
  required CatalogGarment garment,
  required int initial,
}) => showGeneralDialog<void>(
  context: context,
  barrierDismissible: true,
  barrierLabel: 'Cerrar',
  barrierColor: Colors.black.withValues(alpha: 0.82),
  transitionDuration: const Duration(milliseconds: 450),
  pageBuilder: (context, _, _) =>
      GalleryZoomDialog(garment: garment, initial: initial),
  transitionBuilder: (context, animation, _, child) => FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
    child: ScaleTransition(
      scale: Tween<double>(
        begin: 0.94,
        end: 1,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  ),
);

class GalleryZoomDialog extends StatefulWidget {
  const GalleryZoomDialog({
    super.key,
    required this.garment,
    required this.initial,
  });

  final CatalogGarment garment;
  final int initial;

  @override
  State<GalleryZoomDialog> createState() => _GalleryZoomDialogState();
}

class _GalleryZoomDialogState extends State<GalleryZoomDialog> {
  late final _controller = PageController(initialPage: widget.initial);
  late var _page = widget.initial; // estado efímero y visual
  var _zoomed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final garment = widget.garment;
    final images = garment.images;
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(DesignTokens.spaceMd),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 900),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        garment.nameLabel,
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        garment.priceLabel,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppCatalogColors.goldLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  tooltip: 'Cerrar',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppCatalogColors.ink,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            Flexible(
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  child: PageView.builder(
                    controller: _controller,
                    physics: _zoomed
                        ? const NeverScrollableScrollPhysics()
                        : const PageScrollPhysics(),
                    itemCount: images.length,
                    onPageChanged: (index) => setState(() => _page = index),
                    itemBuilder: (context, index) => ColoredBox(
                      color: Colors.black,
                      child: ZoomablePhoto(
                        key: ValueKey(index),
                        onZoomChanged: (zoomed) {
                          if (zoomed != _zoomed) {
                            setState(() => _zoomed = zoomed);
                          }
                        },
                        child: CatalogPhoto(
                          url: images[index].bigUrl,
                          placeholderUrl: images[index].thumbUrl,
                          fit: BoxFit.contain,
                          cacheWidth: 1600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (images.length > 1) ...[
              const SizedBox(height: DesignTokens.spaceMd),
              AppPageDots(count: images.length, current: _page),
            ],
            const SizedBox(height: DesignTokens.spaceSm),
            Text(
              'Pellizca o toca dos veces para acercar',
              style: textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
