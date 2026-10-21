import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';
import 'package:sistema_oro/shared/widgets/brand_logo_image.dart';

/// El logo de «Baron Golden Boss» en el catálogo: ÚNICO punto que lo pinta.
/// Lee `logo_url` de los ajustes públicos (lo que el dueño subió desde la
/// administración); si no hay o falla, usa el logo empaquetado. Mientras llegan
/// los ajustes deja un hueco del mismo tamaño (sin saltar del logo viejo al nuevo).
class BrandLogo extends ConsumerWidget {
  const BrandLogo({super.key, required this.size});

  /// Lado del cuadrado, en píxeles lógicos.
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(catalogSettingsProvider);
    if (settings.isLoading && !settings.hasValue) {
      return SizedBox.square(dimension: size);
    }
    return BrandLogoImage(url: settings.value?.logoUrl ?? '', size: size);
  }
}
