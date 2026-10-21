String formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}

String apiDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

String formatTime(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

String formatDateTime(DateTime value) =>
    '${formatDate(value)} ${formatTime(value)}';

String apiDateTime(DateTime value) =>
    '${apiDate(value)} ${formatTime(value)}:${value.second.toString().padLeft(2, '0')}';
