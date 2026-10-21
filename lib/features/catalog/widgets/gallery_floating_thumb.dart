import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/motion.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_photo.dart';

/// La foto de la prenda en pequeño, flotando arriba mientras se lee la
/// descripción y la galería ya no se ve. Aparece y se va deslizándose; al
/// tocarla, [onTap] lleva de vuelta a la foto grande.
class GalleryFloatingThumb extends StatelessWidget {
  const GalleryFloatingThumb({
    super.key,
    required this.visible,
    required this.url,
    required this.onTap,
  });

  final bool visible;
  final String url;
  final VoidCallback onTap;

  static const double _size = 60;

  @override
  Widget build(BuildContext context) {
    final duration = motionDuration(context, DesignTokens.animationNormal);
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: duration,
        curve: DesignTokens.curve,
        offset: visible ? Offset.zero : const Offset(0, -1.6),
        child: AnimatedOpacity(
          duration: duration,
          opacity: visible ? 1 : 0,
          child: Tooltip(
            message: 'Ver la foto',
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: _size,
                height: _size,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppCatalogColors.gold,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40141210),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    DesignTokens.radiusMd - 2,
                  ),
                  child: CatalogPhoto(url: url, cacheWidth: 160),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
