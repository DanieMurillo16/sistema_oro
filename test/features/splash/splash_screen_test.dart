import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/theme/app_theme.dart';
import 'package:sistema_oro/features/splash/splash_screen.dart';

import '../../support/expect_layout.dart';
import '../../support/pump_at_sizes.dart';

void main() {
  testWidgets('el splash no desborda en ningún tamaño', (tester) async {
    await expectNoOverflow(tester, const SplashScreen(), theme: AppTheme.dark);
  });

  testWidgets('el nombre cabe en una línea a 320 px con texto 1.0', (
    tester,
  ) async {
    await pumpView(
      tester,
      const SplashScreen(),
      theme: AppTheme.dark,
      width: 320,
    );

    expectSingleLine(tester, find.text('Sistema Oro'));
  });

  testWidgets('la frase no pasa de 3 líneas a 390 px', (tester) async {
    await pumpView(tester, const SplashScreen(), theme: AppTheme.dark);

    expectMaxLines(
      tester,
      find.textContaining('Pedidos, separados y clientes'),
      3, // la fuente de prueba es más ancha que Inter: en real son 2
    );
  });
}
