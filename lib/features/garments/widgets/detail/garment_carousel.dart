import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/shared/widgets/app_page_dots.dart';

/// Las fotos de la prenda en carrusel: la de en medio se ve grande y las
/// vecinas se asoman un poco, más pequeñas y tenues. Tocar la «x» de la
/// esquina (solo con permiso) quita la foto.
class GarmentCarousel extends StatefulWidget {
  const GarmentCarousel({super.key, required this.images, this.onRemove});

  final List<GarmentImage> images;
  final ValueChanged<GarmentImage>? onRemove;

  @override
  State<GarmentCarousel> createState() => _GarmentCarouselState();
}

class _GarmentCarouselState extends State<GarmentCarousel> {
  static const _height = 240.0;

  final _controller = PageController(viewportFraction: 0.82);
  var _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final current = _page.clamp(0, images.length - 1);
    return Column(
      children: [
        SizedBox(
          height: _height,
          child: PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (index) => setState(() => _page = index),
            itemBuilder: (context, index) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final position =
                    _controller.hasClients &&
                        _controller.position.haveDimensions
                    ? (_controller.page ?? _page.toDouble()) - index
                    : (_page - index).toDouble();
                final focus = (1 - position.abs()).clamp(0.0, 1.0);
                return Transform.scale(
                  scale: 0.88 + 0.12 * focus,
                  child: Opacity(opacity: 0.55 + 0.45 * focus, child: child),
                );
              },
              child: _Slide(
                key: ValueKey(images[index].id),
                image: images[index],
                onRemove: widget.onRemove == null
                    ? null
                    : () => widget.onRemove!(images[index]),
              ),
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: DesignTokens.spaceSm),
          AppPageDots(count: images.length, current: current),
        ],
      ],
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({super.key, required this.image, this.onRemove});

  final GarmentImage image;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceXs),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              image.bigUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ColoredBox(
                color: scheme.surfaceContainerHigh,
                child: Icon(
                  Icons.diamond_outlined,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : ColoredBox(color: scheme.surfaceContainerHigh),
            ),
            if (onRemove != null)
              Positioned(
                top: DesignTokens.spaceXs,
                right: DesignTokens.spaceXs,
                child: _RemoveButton(onPressed: onRemove!),
              ),
          ],
        ),
      ),
    );
  }
}

/// «x» pequeña y discreta en la esquina de la foto (área táctil de 32).
class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Quitar foto',
    child: InkResponse(
      onTap: onPressed,
      radius: 18,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.55),
        ),
        child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
      ),
    ),
  );
}
