import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Toda acción destructiva o irreversible pasa por una confirmación: o por
/// `confirmDestructive(...)` (shared/utils/confirm_destructive.dart), o por un
/// diálogo propio de `widgets/dialogs/` (los que además piden motivo, monto,
/// etc.). Esta prueba lee el código de las vistas y falla si una llamada
/// destructiva aparece en un archivo que no es ninguno de los dos.
///
/// Si agregas una acción destructiva nueva: pide confirmación con
/// `confirmDestructive` (o ponla dentro de un diálogo de `widgets/dialogs/`) y,
/// si su método no está en la lista de abajo, agrégalo.
void main() {
  // Métodos de notifier que eliminan, quitan, anulan, rechazan, cancelan,
  // restauran, reemplazan el logo o cierran sesión.
  const destructive = [
    'delete',
    'deleteMany',
    'remove', // quitar una foto
    'restore', // volver al logo original
    'change', // cambiar el logo
    'logout',
    'voidPayment',
    'reject',
    'cancel',
  ];
  final call = RegExp(
    r'\.notifier\s*\)\s*\.\s*(' + destructive.join('|') + r')\s*\(',
  );

  test('ninguna vista llama a una acción destructiva sin confirmar', () {
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final path = file.path.replaceAll('\\', '/');
      // Providers y repositorios no son vistas: ahí viven las acciones.
      if (path.contains('/providers/') || path.contains('/data/')) continue;
      final code = file.readAsStringSync();
      final calls = call.allMatches(code).toList();
      if (calls.isEmpty) continue;
      final confirmed =
          path.contains('/widgets/dialogs/') ||
          code.contains('confirmDestructive(');
      if (!confirmed) {
        offenders.add('$path → ${calls.map((m) => m.group(1)).toSet()}');
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'Estas vistas llaman a una acción destructiva sin pasar por '
          'confirmDestructive() ni por un diálogo de widgets/dialogs/:\n'
          '${offenders.join('\n')}',
    );
  });

  test('los repositorios destructivos solo se llaman desde providers', () {
    // delete / removeImage / voidPayment / cancel / reject / restoreLogo /
    // logout viven en `data/`; ninguna vista los llama directo.
    final repoCalls = RegExp(
      r'[Rr]epository(?:Provider)?\)?\s*\.\s*(delete|removeImage|voidPayment|cancel|reject|restoreLogo|logout)\s*\(',
    );
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final path = file.path.replaceAll('\\', '/');
      if (path.contains('/providers/') || path.contains('/data/')) continue;
      if (repoCalls.hasMatch(file.readAsStringSync())) offenders.add(path);
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('«Aceptar» nunca es el rótulo de una confirmación', () {
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final code = file.readAsStringSync();
      if (RegExp(r"confirmLabel:\s*'(Aceptar|OK|Ok|Sí)'").hasMatch(code)) {
        offenders.add(file.path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
