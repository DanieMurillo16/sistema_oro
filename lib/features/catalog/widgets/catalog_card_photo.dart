import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/utils/motion.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_photo.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_photo_hero.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_tag.dart';
import 'package:sistema_oro/features/catalog/widgets/garment_gallery.dart';

/// La foto de una tarjeta (relación 4:5, esquinas de 18): etiquetas flotantes
/// arriba. Con el mouse encima la foto se acerca a 1,04 en 500 ms y, si la
/// prenda tiene más fotos, pasan una a una con un fundido lento (el detalle
/// se pide solo al pasar el mouse). La primera foto «viaja» al detalle.
class CatalogCardPhoto extends ConsumerStatefulWidget {
  const CatalogCardPhoto({
    super.key,
    required this.garment,
    required this.hover,
    this.aspectRatio = 4 / 5,
  });

  final CatalogGarment garment;
  final bool hover;

  /// 4:5 en tarjetas anchas; cuadrada en teléfono para que no sean tan largas.
  final double aspectRatio;

  static const double radius = DesignTokens.catalogPhotoRadius;

  @override
  ConsumerState<CatalogCardPhoto> createState() => _CatalogCardPhotoState();
}

class _CatalogCardPhotoState extends ConsumerState<CatalogCardPhoto> {
  Timer? _timer; // estado efímero y visual
  var _index = 0;
  var _fetched = false;

  @override
  void didUpdateWidget(CatalogCardPhoto old) {
    super.didUpdateWidget(old);
    if (widget.hover && !old.hover) {
      // Al pasar el mouse se pide el detalle (sus fotos) y se empieza a rotar.
      ref.read(catalogGarmentProvider(widget.garment.id).future).ignore();
      _timer = Timer.periodic(const Duration(milliseconds: 1700), (_) {
        final count =
            ref
                .read(catalogGarmentProvider(widget.garment.id))
                .value
                ?.images
                .length ??
            0;
        if (count > 1 && mounted) setState(() => _index = (_index + 1) % count);
      });
    } else if (!widget.hover && old.hover) {
      _timer?.cancel();
      setState(() => _index = 0);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Deslizar sobre la foto pasa a la siguiente o anterior (se pide el detalle
  /// la primera vez, que es de donde salen las demás fotos).
  Future<void> _swipe(int delta) async {
    setState(() => _fetched = true);
    final detail = await ref.read(
      catalogGarmentProvider(widget.garment.id).future,
    );
    final count = detail.images.length;
    if (count < 2 || !mounted) return;
    setState(() => _index = (_index + delta + count) % count);
  }

  @override
  Widget build(BuildContext context) {
    final garment = widget.garment;
    final duration = motionDuration(context, const Duration(milliseconds: 500));
    final images = widget.hover || _fetched
        ? ref.watch(catalogGarmentProvider(garment.id)).value?.images ??
              const <CatalogImage>[]
        : const <CatalogImage>[];
    final total = images.length > 1 ? images.length : garment.photoCount;
    final url = _index > 0 && _index < images.length
        ? images[_index].thumbUrl
        : garment.thumbnail;
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: GestureDetector(
        // Deslizar de lado cambia de foto (sin abrir la prenda).
        onHorizontalDragEnd: total < 2
            ? null
            : (details) {
                final v = details.primaryVelocity ?? 0;
                if (v.abs() > 120) _swipe(v < 0 ? 1 : -1);
              },
        child: Stack(
          fit: StackFit.expand,
          children: [
            CatalogPhotoHero(
              tag: GarmentGallery.heroTag(garment.id),
              radius: CatalogCardPhoto.radius,
              child: AnimatedScale(
                scale: widget.hover ? 1.04 : 1,
                duration: duration,
                curve: Curves.easeOutCubic,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  switchInCurve: Curves.easeOutCubic,
                  child: CatalogPhoto(
                    key: ValueKey(url),
                    url: url,
                    cacheWidth: 600,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: CatalogTags(tags: garment.tags),
            ),
            // Puntos pequeños: avisan de que hay más fotos y cuál se ve.
            if (total > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 10,
                child: IgnorePointer(
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: widget.hover ? 0 : 1,
                      duration: duration,
                      child: _PhotoDots(count: total, current: _index),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: widget.hover ? 1 : 0,
                  duration: duration,
                  child: const _ViewButton(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Puntos sobre la foto, sobre una píldora oscura translúcida para que se vean
/// con cualquier fondo.
class _PhotoDots extends StatelessWidget {
  const _PhotoDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: i == current ? 14 : 5,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: i == current
                    ? AppCatalogColors.goldLight
                    : Colors.white.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    ),
  );
}

class _ViewButton extends StatelessWidget {
  const _ViewButton();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppCatalogColors.ink.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Text(
        'Ver prenda',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: Colors.white),
      ),
    ),
  );
}
