import 'package:flutter/material.dart';
import 'package:sistema_oro/core/utils/motion.dart';

/// Entrada limpia de un bloque: aparece con fundido mientras se desliza desde
/// [from] (en fracciones de su propio tamaño: `Offset(-0.08, 0)` llega desde la
/// izquierda). Solo anima al montarse; [delay] escalona varios bloques.
class AppSlideIn extends StatelessWidget {
  const AppSlideIn({
    super.key,
    required this.child,
    this.from = const Offset(0, 0.06),
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
  });

  final Widget child;
  final Offset from;
  final Duration delay;

  /// Lo que dura el movimiento (pausado: 550–800 ms).
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final run = motionDuration(context, duration);
    final wait = motionDuration(context, delay);
    final total = run + wait;
    final start = total.inMilliseconds == 0
        ? 0.0
        : wait.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: Curves.easeOutQuart),
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: FractionalTranslation(
          translation: Offset(from.dx * (1 - t), from.dy * (1 - t)),
          child: child,
        ),
      ),
    );
  }
}
