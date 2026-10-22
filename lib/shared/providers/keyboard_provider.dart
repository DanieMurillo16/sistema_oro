import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ¿Está abierto el teclado? Mira la ventana real: el `Scaffold` del menú le
/// quita la altura del teclado al `MediaQuery` que ven las pantallas de dentro,
/// así que ahí `viewInsets` siempre vale 0.
final keyboardOpenProvider = NotifierProvider<KeyboardOpenNotifier, bool>(
  KeyboardOpenNotifier.new,
);

class KeyboardOpenNotifier extends Notifier<bool> with WidgetsBindingObserver {
  bool _read() =>
      (WidgetsBinding
              .instance
              .platformDispatcher
              .implicitView
              ?.viewInsets
              .bottom ??
          0) >
      0;

  @override
  bool build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));
    return _read();
  }

  @override
  void didChangeMetrics() => state = _read();
}
