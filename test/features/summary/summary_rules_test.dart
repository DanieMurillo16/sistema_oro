import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/features/summary/utils/summary_rules.dart';

void main() {
  test('la clave del mes es AAAA-MM y la etiqueta va en español', () {
    expect(SummaryRules.key(DateTime(2026, 10, 20)), '2026-10');
    expect(SummaryRules.key(DateTime(2026, 3)), '2026-03');
    expect(SummaryRules.label(DateTime(2026, 10)), 'octubre 2026');
    expect(SummaryRules.label(DateTime(2027, 1)), 'enero 2027');
  });

  test('cambiar de mes cruza el año en ambos sentidos', () {
    expect(SummaryRules.shift(DateTime(2026, 1), -1), DateTime(2025, 12));
    expect(SummaryRules.shift(DateTime(2026, 12), 1), DateTime(2027, 1));
  });

  test('no se avanza más allá del mes actual', () {
    final now = DateTime(2026, 10, 20);
    expect(SummaryRules.canGoNext(DateTime(2026, 9), now), isTrue);
    expect(SummaryRules.canGoNext(DateTime(2026, 10), now), isFalse);
    expect(
      SummaryRules.firstOfMonth(DateTime(2026, 10, 20, 15)),
      DateTime(2026, 10),
    );
  });
}
