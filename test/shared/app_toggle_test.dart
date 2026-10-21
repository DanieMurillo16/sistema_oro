import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/theme/app_theme.dart';
import 'package:sistema_oro/shared/widgets/app_toggle.dart';
import 'package:sistema_oro/shared/widgets/app_toggle_option.dart';

void main() {
  testWidgets(
    'el texto de cada opción queda centrado verticalmente en la pastilla',
    (tester) async {
      // Antes la fila de opciones quedaba pegada arriba dentro de la pastilla
      // (alto mínimo sin que la fila lo llenara): el texto salía ≈5 px más arriba
      // que el centro. Se mide la caja del texto contra la de la pastilla.
      for (final compact in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  child: AppToggle<int>(
                    compact: compact,
                    options: const [
                      AppToggleOption(value: 1, label: 'Gratis'),
                      AppToggleOption(value: 2, label: 'Decorada'),
                    ],
                    selected: 1,
                    onSelected: (_) {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final pill = tester.getRect(find.byType(AppToggle<int>));
        for (final label in ['Gratis', 'Decorada']) {
          final text = tester.getRect(find.text(label));
          expect(
            (text.center.dy - pill.center.dy).abs(),
            lessThan(1),
            reason:
                '«$label» compact=$compact: centro del texto ${text.center.dy} vs pastilla ${pill.center.dy}',
          );
        }
      }
    },
  );
}
