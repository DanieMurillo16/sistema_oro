import 'package:flutter/material.dart';

/// La foto de una prenda que «viaja» entre el listado y el detalle. Durante el
/// vuelo recorta con esquinas que pasan suavemente de [fromRadius] a [toRadius]
/// (y al regresar, al revés), así nunca se ven cortes cuadrados.
class CatalogPhotoHero extends StatelessWidget {
  const CatalogPhotoHero({
    super.key,
    required this.tag,
    required this.child,
    required this.radius,
  });

  final String tag;
  final Widget child;
  final double radius;

  static Widget _clip(Widget child, double radius) =>
      ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);

  @override
  Widget build(BuildContext context) => Hero(
    tag: tag,
    transitionOnUserGestures: true,
    flightShuttleBuilder:
        (context, animation, direction, fromContext, toContext) {
          final from = (fromContext.widget as Hero).child;
          final to = (toContext.widget as Hero).child;
          final shown = direction == HeroFlightDirection.push ? to : from;
          return AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final t = Curves.easeOutCubic.transform(animation.value);
              final start = direction == HeroFlightDirection.push ? 14.0 : 24.0;
              final end = direction == HeroFlightDirection.push ? 24.0 : 14.0;
              return _clip(shown, start + (end - start) * t);
            },
          );
        },
    child: _clip(child, radius),
  );
}
