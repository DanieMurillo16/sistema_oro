import 'package:flutter/material.dart';

/// Datos que van juntos con « · » como piezas indivisibles: la pieza que no
/// cabe baja entera a la línea siguiente (un solo `Text` con `a · b · c` se
/// parte donde caiga).
class DotSeparatedText extends StatelessWidget {
  const DotSeparatedText({super.key, required this.parts, this.style});

  final List<String> parts;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final pieces = parts.where((part) => part.trim().isNotEmpty).toList();
    final textStyle = style ?? Theme.of(context).textTheme.bodySmall;
    return Wrap(
      children: [
        for (final (index, part) in pieces.indexed)
          Text(
            index == pieces.length - 1 ? part : '$part · ',
            style: textStyle,
          ),
      ],
    );
  }
}
