import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/motion.dart';

/// Micro-interacción para tarjetas y botones: con el mouse (web/iPad con
/// ratón) cursor de mano y se eleva [lift] píxeles; al presionar, se encoge un
/// poco. No cambia el contenido ni el tamaño que ocupa en el layout.
class AppPressable extends StatefulWidget {
  const AppPressable({
    super.key,
    required this.child,
    this.onTap,
    this.lift = 4,
    this.pressedScale = 0.97,
    this.onHoverChanged,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double lift;
  final double pressedScale;
  final ValueChanged<bool>? onHoverChanged;

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
  var _hover = false; // estado efímero y visual
  var _pressed = false;

  void _setHover(bool value) {
    setState(() => _hover = value);
    widget.onHoverChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final duration = motionDuration(context, DesignTokens.animationNormal);
    return MouseRegion(
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedSlide(
            duration: duration,
            curve: Curves.easeOutCubic,
            offset: Offset(0, _hover ? -widget.lift / 400 : 0),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              scale: _pressed ? widget.pressedScale : 1,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
