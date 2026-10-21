import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/date_formatter.dart';

/// Campo de fecha: toca y elige en el calendario. La fecha se escribe con el
/// formateador de la app (dd/mm/aaaa).
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.errorText,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? errorText;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: value,
        firstDate: firstDate,
        lastDate: lastDate,
      );
      if (picked != null) onChanged(picked);
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      child: Text(formatDate(value)),
    ),
  );
}
