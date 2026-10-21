import 'dart:io';

import 'package:flutter/services.dart';

/// Carga Inter y Plus Jakarta Sans de `assets/fonts/` en el motor de pruebas.
/// Por defecto `flutter test` pinta con Ahem (≈1,8× más ancha que Inter): con
/// esto las afirmaciones de líneas y anchos se acercan a lo que verá la persona.
/// Llamar al inicio de la prueba (una vez por archivo basta).
Future<void> loadRealFonts() async {
  const families = {
    'Inter': ['Inter-Regular', 'Inter-Medium', 'Inter-SemiBold', 'Inter-Bold'],
    'PlusJakartaSans': [
      'PlusJakartaSans-Regular',
      'PlusJakartaSans-Medium',
      'PlusJakartaSans-SemiBold',
      'PlusJakartaSans-Bold',
    ],
  };
  for (final entry in families.entries) {
    final loader = FontLoader(entry.key);
    for (final file in entry.value) {
      final bytes = File('assets/fonts/$file.ttf').readAsBytesSync();
      loader.addFont(
        Future.value(ByteData.sublistView(Uint8List.fromList(bytes))),
      );
    }
    await loader.load();
  }
}
