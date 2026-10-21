import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/shared/widgets/app_float.dart';

/// Hace «latir» su hijo (crece y encoge un poco, sin parar) para llamar la
/// atención al botón principal. Con «reducir movimiento» del sistema, o
/// apagado por [ambientMotionProvider], se queda quieto.
class AppPulse extends ConsumerStatefulWidget {
  const AppPulse({super.key, required this.child, this.scale = 1.05});

  final Widget child;

  /// Cuánto crece en el punto más grande (1.05 = 5 %).
  final double scale;

  @override
  ConsumerState<AppPulse> createState() => _AppPulseState();
}

class _AppPulseState extends ConsumerState<AppPulse>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final on =
        ref.read(ambientMotionProvider) &&
        !MediaQuery.disableAnimationsOf(context);
    if (on && _controller == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1100),
      )..repeat(reverse: true);
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
    return ScaleTransition(
      scale: Tween<double>(
        begin: 1,
        end: widget.scale,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}
