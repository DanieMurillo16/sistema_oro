import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// Margen del encabezado de una lista (búsqueda, pestañas): el mismo de las
/// tarjetas de abajo, según el ancho, y sin espacio debajo.
class ListHeaderPadding extends StatelessWidget {
  const ListHeaderPadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: DesignTokens.pagePaddingFor(MediaQuery.sizeOf(context).width)
        .copyWith(bottom: 0),
    child: child,
  );
}
