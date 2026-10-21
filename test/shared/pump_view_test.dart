import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/services/app_toast.dart';

import '../support/pump_at_sizes.dart';

void main() {
  testWidgets('pumpView monta la vista y el aviso se ve', (tester) async {
    await pumpView(
      tester,
      Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => AppToast.success('Guardado'),
            child: const Text('Guardar'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Guardar'));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Guardado'), findsOneWidget);
    await dismissToasts(tester);
  });
}
