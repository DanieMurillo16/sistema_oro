import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/app_dark_colors.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// Icono de marca: cuadro redondeado con degradado champán → dorado envejecido
/// y el símbolo de joya. Lo usan el splash y, más adelante, el login y el
/// catálogo.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = DesignTokens.brandMarkSize});

  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppDarkColors.goldLight, AppDarkColors.goldDeep],
        ),
      ),
      child: Icon(
        Icons.diamond_outlined,
        size: size * 0.5,
        color: AppDarkColors.background,
      ),
    ),
  );
}
