import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';
import 'package:sistema_oro/shared/widgets/app_form_pair.dart';

import '../support/pump_at_sizes.dart';

void main() {
  testWidgets('el marco de diálogo no desborda en ningún tamaño', (
    tester,
  ) async {
    await expectNoOverflow(tester, const _DialogHost());
  });

  testWidgets('AppFormPair va en fila con ancho útil y apilado sin él', (
    tester,
  ) async {
    const first = SizedBox(key: ValueKey('first'), height: 40);
    const second = SizedBox(key: ValueKey('second'), height: 40);

    Future<bool> sameRow(double width, double scale) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 700);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const Scaffold(
            body: AppFormPair(first: first, second: second),
          ),
        ),
      );
      return tester.getTopLeft(find.byKey(const ValueKey('first'))).dy ==
          tester.getTopLeft(find.byKey(const ValueKey('second'))).dy;
    }

    // El mínimo para ir en fila es formPairMinWidth (280) multiplicado por la
    // escala de texto: el texto grande también cuenta.
    expect(await sameRow(250, 1), isFalse, reason: 'bajo el mínimo: apilado');
    expect(await sameRow(800, 1), isTrue, reason: 'ancho: en fila');
    expect(await sameRow(400, 1.5), isFalse, reason: 'texto grande: apilado');
    expect(await sameRow(800, 1.5), isTrue, reason: 'ancho y texto grande');
  });

  testWidgets('pareja de campos cortos baja a formShortPairMinWidth (240)', (
    tester,
  ) async {
    Future<bool> sameRow(double width) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 700);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppFormPair(
              minWidth: DesignTokens.formShortPairMinWidth,
              first: SizedBox(key: ValueKey('first'), height: 40),
              second: SizedBox(key: ValueKey('second'), height: 40),
            ),
          ),
        ),
      );
      return tester.getTopLeft(find.byKey(const ValueKey('first'))).dy ==
          tester.getTopLeft(find.byKey(const ValueKey('second'))).dy;
    }

    expect(await sameRow(230), isFalse, reason: 'bajo 240: apilado');
    expect(await sameRow(250), isTrue, reason: 'desde 240: en fila');
  });
}

/// Abre el diálogo con `showDialog` al montarse, como en la app real: así el
/// diálogo queda por encima del Scaffold y ve el teclado en su `MediaQuery`.
class _DialogHost extends StatefulWidget {
  const _DialogHost();

  @override
  State<_DialogHost> createState() => _DialogHostState();
}

class _DialogHostState extends State<_DialogHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showDialog<void>(
        context: context,
        builder: (_) => const _SampleDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const Scaffold();
}

/// Un diálogo mínimo con el marco, el encabezado, dos campos en pareja y el
/// pie estándar: lo que usan todos los diálogos reales.
class _SampleDialog extends StatelessWidget {
  const _SampleDialog();

  @override
  Widget build(BuildContext context) => AppDialog(
    header: const DialogHeader(
      icon: Icons.person_add_alt_1_outlined,
      title: 'Título de un diálogo',
      subtitle: 'Subtítulo de ejemplo',
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppFormPair(
          first: TextField(decoration: InputDecoration(labelText: 'Nombre')),
          second: TextField(decoration: InputDecoration(labelText: 'Teléfono')),
        ),
        const SizedBox(height: DesignTokens.spaceMd),
        TextField(
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Notas'),
          controller: TextEditingController(text: 'Texto largo ' * 30),
        ),
      ],
    ),
    actions: DialogActions(onConfirm: () {}, confirmLabel: 'Guardar'),
  );
}
