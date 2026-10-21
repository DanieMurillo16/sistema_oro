import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Si `true`, los adornos flotantes se mueven sin parar. Las pruebas lo apagan
/// (una animación infinita impide que `pumpAndSettle` termine).
final ambientMotionProvider = Provider<bool>((ref) => true);

/// Un adorno que flota: sube y baja despacio, sin parar. Con «reducir
/// movimiento» del sistema, o apagado por [ambientMotionProvider], se queda quieto.
class AppFloat extends ConsumerStatefulWidget {
  const AppFloat({
    super.key,
    required this.child,
    this.distance = 8,
    this.period = const Duration(milliseconds: 3200),
    this.phase = 0,
  });

  final Widget child;

  /// Cuánto sube y baja, en píxeles.
  final double distance;
  final Duration period;

  /// Desfase (0 a 1) para que varios adornos no se muevan a la vez.
  final double phase;

  @override
  ConsumerState<AppFloat> createState() => _AppFloatState();
}

class _AppFloatState extends ConsumerState<AppFloat>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final on =
        ref.read(ambientMotionProvider) &&
        !MediaQuery.disableAnimationsOf(context);
    if (on && _controller == null) {
      _controller = AnimationController(vsync: this, duration: widget.period)
        ..forward(from: widget.phase)
        ..repeat(reverse: true);
    } else if (!on) {
      _controller?.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return widget.child;
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(
          0,
          (controller.drive(CurveTween(curve: Curves.easeInOut)).value - 0.5) *
              2 *
              widget.distance,
        ),
        child: child,
      ),
    );
  }
}
