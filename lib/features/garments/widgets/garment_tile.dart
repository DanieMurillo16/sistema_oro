import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/theme/status_colors.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/utils/garment_labels.dart';
import 'package:sistema_oro/shared/widgets/dot_separated_text.dart';
import 'package:sistema_oro/shared/widgets/network_thumb.dart';
import 'package:sistema_oro/shared/widgets/title_with_amount.dart';
import 'package:sistema_oro/shared/widgets/status_chip.dart';

/// Una prenda en la lista: foto, nombre, precio y cuántas unidades quedan.
class GarmentTile extends StatelessWidget {
  const GarmentTile({super.key, required this.garment, required this.onTap});

  final Garment garment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NetworkThumb(url: garment.thumbnail),
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
                    _GarmentBadges(garment: garment),
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
  const _GarmentBadges({required this.garment});

  final Garment garment;

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
    ],
  );
}
