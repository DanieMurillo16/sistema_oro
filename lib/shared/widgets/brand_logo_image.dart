import 'package:flutter/material.dart';

/// La imagen del logo de «Baron Golden Boss»: usa [url] (el que subió el dueño,
/// ya con `?v=` para la caché) y, mientras carga, si falla o si está vacío, el
/// logo empaquetado en `assets/brand/logo.png`. Los bordes se desvanecen: aunque
/// el negro de la imagen no coincida con el fondo, no se ve un cuadrado.
class BrandLogoImage extends StatelessWidget {
  const BrandLogoImage({super.key, required this.url, required this.size});

  static const asset = 'assets/brand/logo.png';

  /// Vacío = el logo empaquetado.
  final String url;

  /// Lado del cuadrado, en píxeles lógicos.
  final double size;

  @override
  Widget build(BuildContext context) {
    const packaged = Image(image: AssetImage(asset), fit: BoxFit.contain);
    return Semantics(
      image: true,
      label: 'Logo de Baron Golden Boss',
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => const RadialGradient(
          radius: 0.62,
          colors: [Colors.white, Colors.white, Colors.transparent],
          stops: [0, 0.78, 1],
        ).createShader(bounds),
        child: SizedBox.square(
          dimension: size,
          child: url.isEmpty
              ? packaged
              : Image.network(
                  url,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) => packaged,
                  // Mientras baja la imagen no se muestra el logo viejo (parpadeo): hueco.
                  loadingBuilder: (_, child, progress) =>
                      progress == null ? child : const SizedBox.shrink(),
                ),
        ),
      ),
    );
  }
}
