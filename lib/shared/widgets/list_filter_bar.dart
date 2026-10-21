import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/shared/widgets/app_toggle.dart';
import 'package:sistema_oro/shared/widgets/app_toggle_option.dart';

/// Búsqueda y pestañas de una lista. No filtra nada: avisa con [onSearch] y
/// [onSelected]; el filtrado vive en el provider.
class ListFilterBar<T> extends StatefulWidget {
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
  State<ListFilterBar<T>> createState() => _ListFilterBarState<T>();
}

class _ListFilterBarState<T> extends State<ListFilterBar<T>> {
  final _controller = TextEditingController(); // estado efímero del campo

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        controller: _controller,
        onChanged: widget.onSearch,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: ValueListenableBuilder(
            valueListenable: _controller,
            builder: (_, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Limpiar búsqueda',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _controller.clear();
                      widget.onSearch('');
                    },
                  ),
          ),
        ),
      ),
      const SizedBox(height: DesignTokens.spaceSm),
      AppToggle<T>(
        compact: true,
        options: widget.options,
        selected: widget.selected,
        onSelected: widget.onSelected,
      ),
    ],
  );
}
