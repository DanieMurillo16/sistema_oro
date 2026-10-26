import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/shared/widgets/app_toggle.dart';
import 'package:sistema_oro/shared/widgets/app_toggle_option.dart';
import 'package:sistema_oro/shared/widgets/list_search_field.dart';

/// Búsqueda y pestañas de una lista, una encima de la otra. No filtra nada:
/// avisa con [onSearch] y [onSelected]; el filtrado vive en el provider. (Pedidos
/// y Separados llevan las pestañas abajo: ver `BottomToggleBar`.)
class ListFilterBar<T> extends StatelessWidget {
  const ListFilterBar({
    super.key,
    required this.hint,
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.onSearch,
  });

  final String hint;
  final List<AppToggleOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ListSearchField(hint: hint, onSearch: onSearch),
      const SizedBox(height: DesignTokens.spaceSm),
      // Con 4 opciones, cada etiqueta se encogía distinto con letra grande: el
      // texto de las pestañas crece hasta 1.2× (como la barra inferior).
      MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.2,
        child: AppToggle<T>(
          compact: true,
          options: options,
          selected: selected,
          onSelected: onSelected,
        ),
      ),
    ],
  );
}
