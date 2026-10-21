import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// Cantidad con − y +, compacta para ir dentro de la fila de la prenda. Se
/// apaga en los topes; no esconde los botones.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  static const _button = BoxConstraints.tightFor(
    width: DesignTokens.quantityButton,
    height: DesignTokens.quantityButton,
  );

  // Sin el área táctil de 48: la cantidad ocupa lo que dibuja (36 + 36).
  static final _style = IconButton.styleFrom(
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton.outlined(
        tooltip: 'Quitar una',
        constraints: _button,
        style: _style,
        padding: EdgeInsets.zero,
        iconSize: DesignTokens.iconSm + 2,
        onPressed: value > 1 ? () => onChanged(value - 1) : null,
        icon: const Icon(Icons.remove),
      ),
      SizedBox(
        width: DesignTokens.quantityWidth,
        child: Text(
          '$value',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      IconButton.outlined(
        tooltip: 'Agregar una',
        constraints: _button,
        style: _style,
        padding: EdgeInsets.zero,
        iconSize: DesignTokens.iconSm + 2,
        onPressed: value < max ? () => onChanged(value + 1) : null,
        icon: const Icon(Icons.add),
      ),
    ],
  );
}
