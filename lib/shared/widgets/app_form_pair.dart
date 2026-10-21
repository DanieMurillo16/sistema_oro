import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

/// Dos campos en fila cuando caben sin sacrificar legibilidad.
class AppFormPair extends StatelessWidget {
  const AppFormPair({
    super.key,
    required this.first,
    required this.second,
    this.minWidth = DesignTokens.formPairMinWidth,
  });

  final Widget first;
  final Widget second;
  final double minWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final inline =
          constraints.maxWidth >=
          MediaQuery.textScalerOf(context).scale(minWidth);
      final fieldWidth = inline
          ? (constraints.maxWidth - DesignTokens.spaceMd) / 2
          : constraints.maxWidth;
      return Wrap(
        spacing: DesignTokens.spaceMd,
        runSpacing: DesignTokens.spaceMd,
        children: [
          SizedBox(width: fieldWidth, child: first),
          SizedBox(width: fieldWidth, child: second),
        ],
      );
    },
  );
}
