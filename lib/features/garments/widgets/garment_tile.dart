import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/theme/status_colors.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/models/photo_upload.dart';
import 'package:sistema_oro/features/garments/providers/garment_uploads_provider.dart';
import 'package:sistema_oro/features/garments/utils/garment_labels.dart';
import 'package:sistema_oro/shared/widgets/dot_separated_text.dart';
import 'package:sistema_oro/shared/widgets/network_thumb.dart';
import 'package:sistema_oro/shared/widgets/title_with_amount.dart';
import 'package:sistema_oro/shared/widgets/status_chip.dart';

/// Una prenda en la lista: foto, nombre, precio y cuántas unidades quedan.
class GarmentTile extends ConsumerWidget {
  const GarmentTile({
    super.key,
    required this.garment,
    required this.onTap,
    this.onLongPress,
    this.selecting = false,
    this.selected = false,
  });

  final Garment garment;
  final VoidCallback onTap;

  /// Mantener pulsada: el menú con «Eliminar» (solo con permiso).
  final VoidCallback? onLongPress;

  /// Con la selección múltiple activa: casilla a la izquierda y tarjeta resaltada.
  final bool selecting;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: selected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.14)
          : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // La marca de selección va ENCIMA de la foto: no gasta ancho, así
              // que la tarjeta no cambia de alto al entrar en selección.
              Semantics(
                selected: selected,
                child: Stack(
                  children: [
                    NetworkThumb(url: garment.thumbnail),
                    if (selecting)
                      Positioned(
                        top: DesignTokens.spaceXs,
                        left: DesignTokens.spaceXs,
                        child: _SelectionMark(selected: selected),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleWithAmount(
                      title: garment.nameLabel,
                      amount: garment.priceLabel,
                    ),
                    DotSeparatedText(
                      parts: [
                        garment.typeLabel,
                        garment.reference ?? '',
                        garment.goldType.label,
                        garment.weightLabel,
                      ],
                    ),
                    const SizedBox(height: DesignTokens.spaceXs),
                    _GarmentBadges(
                      garment: garment,
                      photos: ref.watch(
                        garmentUploadsProvider.select((all) => all[garment.id]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GarmentBadges extends StatelessWidget {
  const _GarmentBadges({required this.garment, this.photos});

  final Garment garment;

  /// Fotos que aún suben (o que fallaron) de esta prenda.
  final List<PhotoUpload>? photos;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: DesignTokens.spaceSm,
    runSpacing: DesignTokens.spaceXs,
    children: [
      StatusChip(
        label: garment.soldOut ? 'Agotada' : garment.stockLabel,
        tone: garment.soldOut ? StatusTone.error : StatusTone.success,
      ),
      if (!garment.active)
        const StatusChip(label: 'Oculta', tone: StatusTone.neutral),
      if (garment.onSale)
        const StatusChip(label: 'Oferta', tone: StatusTone.warning),
      if (garment.pendingRequests > 0)
        StatusChip(label: garment.pendingLabel, tone: StatusTone.info),
      if (photos != null)
        photos!.any((u) => u.status == UploadStatus.failed)
            ? const StatusChip(label: 'Fotos sin subir', tone: StatusTone.error)
            : const StatusChip(label: 'Subiendo fotos', tone: StatusTone.info),
    ],
  );
}

/// Círculo con check sobre la foto: lleno si la prenda está marcada.
class _SelectionMark extends StatelessWidget {
  const _SelectionMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? scheme.primary : scheme.scrim.withValues(alpha: 0.5),
        border: Border.all(color: scheme.onSurface, width: 1.5),
      ),
      child: SizedBox.square(
        dimension: 22,
        child: selected
            ? Icon(Icons.check, size: 16, color: scheme.onPrimary)
            : null,
      ),
    );
  }
}
