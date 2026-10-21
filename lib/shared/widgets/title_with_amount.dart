import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// Título a la izquierda y monto a la derecha. Si el ancho no alcanza (letra
/// grande, teléfono pequeño) el monto baja debajo del título en vez de
/// comerle el sitio: el nombre crece, no se recorta.
class TitleWithAmount extends StatelessWidget {
  const TitleWithAmount({
    super.key,
    required this.title,
    this.amount,
    this.amountColor,
  });

  final String title;
  final String? amount;
  final Color? amountColor;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleSmall;
    final titleText = Text(title, style: style);
    if (amount == null) return titleText;
    final amountText = Text(
      amount!,
      style: style?.copyWith(color: amountColor),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth <
            MediaQuery.textScalerOf(context)
                .scale(DesignTokens.stackedTitleWidth);
        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [titleText, amountText],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleText),
            const SizedBox(width: DesignTokens.spaceSm),
            amountText,
          ],
        );
      },
    );
  }
}
