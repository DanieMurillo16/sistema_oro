import 'package:flutter/material.dart';

/// Campo de búsqueda de una lista. No filtra nada: avisa con [onSearch]; el
/// filtrado vive en el provider.
class ListSearchField extends StatefulWidget {
  const ListSearchField({
    super.key,
    required this.hint,
    required this.onSearch,
  });

  final String hint;
  final ValueChanged<String> onSearch;

  @override
  State<ListSearchField> createState() => _ListSearchFieldState();
}

class _ListSearchFieldState extends State<ListSearchField> {
  final _controller = TextEditingController(); // estado efímero del campo

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
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
  );
}
