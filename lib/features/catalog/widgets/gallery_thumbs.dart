import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/motion.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_photo.dart';

/// Las miniaturas de la galería, pequeñas y translúcidas sobre la parte baja
/// de la foto grande. La elegida se ve opaca y con borde dorado.
class GalleryThumbs extends StatelessWidget {
  const GalleryThumbs({
    super.key,
    required this.images,
    required this.selected,
    required this.onSelected,
  });

  final List<CatalogImage> images;
  final int selected;
  final ValueChanged<int> onSelected;

  static const double _size = 40;

  @override
  Widget build(BuildContext context) {
    const primary = AppCatalogColors.gold;
    final duration = motionDuration(context, DesignTokens.animationFast);
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: _size + 8,
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          separatorBuilder: (_, _) =>
              const SizedBox(width: DesignTokens.spaceSm),
          itemBuilder: (context, index) {
            final chosen = index == selected;
            return GestureDetector(
              onTap: () => onSelected(index),
              child: Center(
                child: AnimatedContainer(
                  duration: duration,
                  curve: DesignTokens.curve,
                  width: chosen ? _size + 6 : _size,
                  height: chosen ? _size + 6 : _size,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    border: Border.all(
                      color: chosen ? primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Opacity(
                    opacity: chosen ? 1 : 0.6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusSm - 2,
                      ),
                      child: CatalogPhoto(
                        url: images[index].thumbUrl,
                        cacheWidth: 120,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
