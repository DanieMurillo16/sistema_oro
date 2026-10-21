import 'package:flutter/material.dart';
import 'package:sistema_oro/core/utils/motion.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_trust_strip.dart';
import 'package:sistema_oro/features/catalog/widgets/related_garments.dart';
import 'package:sistema_oro/shared/widgets/app_slide_in.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/widgets/garment_gallery.dart';
import 'package:sistema_oro/features/catalog/widgets/garment_info_panel.dart';
import 'package:sistema_oro/features/catalog/widgets/gallery_floating_thumb.dart';
import 'package:sistema_oro/features/catalog/widgets/gallery_zoom_dialog.dart';

/// El cuerpo del detalle: galería y datos lado a lado (en teléfono, uno
/// debajo del otro).
class GarmentDetailBody extends StatefulWidget {
  const GarmentDetailBody({
    super.key,
    required this.garment,
    required this.showActions,
  });

  final CatalogGarment garment;
  final bool showActions;

  @override
  State<GarmentDetailBody> createState() => _GarmentDetailBodyState();
}

class _GarmentDetailBodyState extends State<GarmentDetailBody> {
  // Estado visual efímero: el scroll y si la galería ya salió de la vista.
  final _scroll = ScrollController();
  final _galleryKey = GlobalKey();
  final _thumbVisible = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _thumbVisible.dispose();
    super.dispose();
  }

  void _onScroll() {
    final height = _galleryKey.currentContext?.size?.height ?? 400;
    _thumbVisible.value = _scroll.offset > height * 0.85;
  }

  /// Vuelve a la foto grande y abre el visor con zoom.
  Future<void> _backToPhoto() async {
    await _scroll.animateTo(
      0,
      duration: motionDuration(context, const Duration(milliseconds: 450)),
      curve: DesignTokens.curve,
    );
    if (!mounted || widget.garment.images.isEmpty) return;
    await showGalleryZoom(context, garment: widget.garment, initial: 0);
  }

  String? get _thumbUrl {
    final garment = widget.garment;
    if (garment.images.isNotEmpty) return garment.images.first.thumbUrl;
    return garment.thumbnail;
  }

  @override
  Widget build(BuildContext context) {
    final url = _thumbUrl;
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(
            DesignTokens.spaceMd,
            0,
            DesignTokens.spaceMd,
            DesignTokens.listBottomSpace,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: DesignTokens.catalogMaxWidth,
              ),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final gallery = GarmentGallery(
                        key: _galleryKey,
                        garment: widget.garment,
                      );
                      final info = GarmentInfoPanel(
                        garment: widget.garment,
                        showActions: widget.showActions,
                      );
                      if (constraints.maxWidth <
                          DesignTokens.catalogThreeColumnsWidth) {
                        return Column(
                          children: [
                            AppSlideIn(
                              from: const Offset(0, 0.04),
                              child: gallery,
                            ),
                            const SizedBox(height: DesignTokens.spaceLg),
                            AppSlideIn(
                              from: const Offset(0.1, 0),
                              delay: const Duration(milliseconds: 140),
                              child: info,
                            ),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppSlideIn(
                              from: const Offset(-0.08, 0),
                              child: gallery,
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spaceXl),
                          Expanded(
                            child: AppSlideIn(
                              from: const Offset(0.08, 0),
                              delay: const Duration(milliseconds: 120),
                              child: info,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: DesignTokens.spaceXl),
                  RelatedGarments(currentId: widget.garment.id),
                  const SizedBox(height: DesignTokens.spaceLg),
                  const CatalogTrustStrip(),
                ],
              ),
            ),
          ),
        ),
        if (url != null && url.isNotEmpty)
          Positioned(
            top: DesignTokens.spaceSm,
            right: DesignTokens.spaceMd,
            child: ValueListenableBuilder(
              valueListenable: _thumbVisible,
              builder: (context, visible, _) => GalleryFloatingThumb(
                visible: visible,
                url: url,
                onTap: _backToPhoto,
              ),
            ),
          ),
      ],
    );
  }
}
