import 'package:flutter/material.dart';

/// La foto con zoom: pellizcar o doble toque la acerca (hasta 3×); al soltar
/// con el zoom en 1× vuelve a deslizar entre fotos.
class ZoomablePhoto extends StatefulWidget {
  const ZoomablePhoto({
    super.key,
    required this.child,
    required this.onZoomChanged,
  });

  final Widget child;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<ZoomablePhoto> createState() => ZoomablePhotoState();
}

class ZoomablePhotoState extends State<ZoomablePhoto>
    with SingleTickerProviderStateMixin {
  final _controller = TransformationController(); // estado efímero y visual
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  Animation<Matrix4>? _tween;
  Offset _tapAt = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller.addListener(
      () => widget.onZoomChanged(_controller.value.getMaxScaleOnAxis() > 1.02),
    );
    _anim.addListener(() {
      if (_tween != null) _controller.value = _tween!.value;
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleZoom() {
    final zoomed = _controller.value.getMaxScaleOnAxis() > 1.02;
    final end = zoomed
        ? Matrix4.identity()
        : (Matrix4.identity()
            ..translateByDouble(-_tapAt.dx * 1.5, -_tapAt.dy * 1.5, 0, 1)
            ..scaleByDouble(2.5, 2.5, 1, 1));
    _tween = Matrix4Tween(
      begin: _controller.value,
      end: end,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onDoubleTapDown: (details) => _tapAt = details.localPosition,
    onDoubleTap: _toggleZoom,
    child: InteractiveViewer(
      transformationController: _controller,
      minScale: 1,
      maxScale: 3,
      child: widget.child,
    ),
  );
}
