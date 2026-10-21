String formatCop(num value) {
  final grouped = _groupDigits(value.round().abs().toString());
  final sign = value < 0 ? '-' : '';
  return '$sign\$ $grouped';
}

String formatCopInput(num? value) {
  if (value == null) return '';
  return _groupDigits(value.round().abs().toString());
}

double? parseCopInput(String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  return digits.isEmpty ? null : double.tryParse(digits);
}

String normalizeCopInput(String value) {
  final parsed = parseCopInput(value);
  return parsed == null ? '' : parsed.round().toString();
}

String formatQuantity(num value) {
  final text = value.toStringAsFixed(3);
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}

String _groupDigits(String digits) {
  return digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
}
