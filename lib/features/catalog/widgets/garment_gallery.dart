import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_photo.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_photo_hero.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_tag.dart';
import 'package:sistema_oro/features/catalog/widgets/gallery_thumbs.dart';
import 'package:sistema_oro/features/catalog/widgets/gallery_zoom_dialog.dart';

/// La galería del detalle: foto grande que cambia sola con un fundido suave
/// (y también al deslizar o tocar una miniatura), con miniaturas pequeñas dentro de la foto. La primera foto «viaja»
/// desde la tarjeta del listado (Hero).
class GarmentGallery extends StatefulWidget {
  const GarmentGallery({super.key, required this.garment});

  final CatalogGarment garment;

  /// Etiqueta compartida entre la tarjeta del listado y la foto grande.
  static String heroTag(int id) => 'catalog-photo-$id';

  @override
  State<GarmentGallery> createState() => _GarmentGalleryState();
}

class _GarmentGalleryState extends State<GarmentGallery> {
  Timer? _timer; // estado efímero y visual
  var _selected = 0;
  var _pausedUntil = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    // Las fotos pasan solas, con un fundido, cada 4,5 s.
    _timer = Timer.periodic(const Duration(milliseconds: 4500), (_) {
      final count = widget.garment.images.length;
      if (!mounted || count < 2) return;
      if (DateTime.now().isBefore(_pausedUntil)) return;
      setState(() => _selected = (_selected + 1) % count);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Cambio manual (miniatura o deslizar): el avance automático espera 9 s.
  void _select(int index) {
    _pausedUntil = DateTime.now().add(const Duration(seconds: 9));
    setState(() => _selected = index);
  }

  void _step(int delta, int count) =>
      _select((_selected + delta + count) % count);

  @override
  Widget build(BuildContext context) {
    final garment = widget.garment;
    final images = garment.images;
    // Mientras llega el detalle solo se conoce la miniatura del listado.
    final slides = images.isEmpty
        ? [CatalogImage(thumbUrl: garment.thumbnail ?? '', bigUrl: '')]
        : images;
    final index = _selected.clamp(0, slides.length - 1);
    final slide = slides[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.sizeOf(context).height *
                DesignTokens.galleryMaxHeightFactor,
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                DesignTokens.catalogPhotoRadius,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: images.isEmpty
                        ? null
                        : () {
                            // Mientras el visor está abierto no cambian solas.
                            _pausedUntil = DateTime.now().add(
                              const Duration(seconds: 30),
                            );
                            showGalleryZoom(
                              context,
                              garment: garment,
                              initial: index,
                            );
                          },
                    onHorizontalDragEnd: slides.length < 2
                        ? null
                        : (details) {
                            final v = details.primaryVelocity ?? 0;
                            if (v.abs() > 120) {
                              _step(v < 0 ? 1 : -1, slides.length);
                            }
                          },
                    child: CatalogPhotoHero(
                      tag: GarmentGallery.heroTag(garment.id),
                      radius: DesignTokens.catalogPhotoRadius,
                      // Fundido lento entre fotos (se desvanece una en la otra).
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 900),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        child: KeyedSubtree(
                          key: ValueKey(slide.bigUrl + slide.thumbUrl),
                          child: CatalogPhoto(
                            url: slide.bigUrl.isEmpty
                                ? slide.thumbUrl
                                : slide.bigUrl,
                            placeholderUrl: slide.thumbUrl.isEmpty
                                ? garment.thumbnail
                                : slide.thumbUrl,
                            cacheWidth: 1200,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: DesignTokens.spaceMd,
                    left: DesignTokens.spaceMd,
                    child: CatalogTags(tags: garment.tags),
                  ),
                  if (images.length > 1)
                    Positioned(
                      left: DesignTokens.spaceMd,
                      right: DesignTokens.spaceMd,
                      bottom: DesignTokens.spaceSm,
                      child: GalleryThumbs(
                        images: images,
                        selected: _selected,
                        onSelected: _select,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
