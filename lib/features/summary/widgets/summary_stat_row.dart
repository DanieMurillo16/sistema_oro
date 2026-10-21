import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/shared/widgets/animated_number_text.dart';

/// Una línea «etiqueta … cifra» cuya cifra cuenta hasta su valor al aparecer y
/// se desliza al nuevo cuando cambia. Con [money] la cifra son pesos y puede
/// taparse con [hidden]; sin él es una cantidad.
class SummaryStatRow extends StatelessWidget {
  const SummaryStatRow({
    super.key,
    required this.label,
    required this.value,
    this.money = false,
    this.hidden = false,
  });

  final String label;
  final num value;
  final bool money;
  final bool hidden;

  static String _count(num value) => value.round().toString();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceXs),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            Expanded(child: Text(label, style: textTheme.bodyMedium)),
            const SizedBox(width: DesignTokens.spaceSm),
            // La cifra no pasa del 60 % de la fila y se encoge si no cabe
            // (nunca se parte); la etiqueta usa el resto y puede crecer.
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.6),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: AnimatedNumberText(
                  value: value.toDouble(),
                  obscured: money && hidden,
                  formatter: money ? formatCop : _count,
                  style: textTheme.titleSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
