import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/app_catalog_colors.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_card_photo.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_card_price_row.dart';
import 'package:sistema_oro/shared/widgets/app_pressable.dart';
import 'package:sistema_oro/shared/widgets/dot_separated_text.dart';

/// Una prenda en la cuadrícula, sin marco: foto 4:5 (cuadrada en teléfono),
/// nombre, una línea con oro · peso · largo y el precio con «Reservar» al lado
/// (que explica el 20 %). La foto se eleva con el mouse y
/// todo se encoge al presionar.
class CatalogCard extends ConsumerStatefulWidget {
  const CatalogCard({super.key, required this.garment, required this.onTap});

  final CatalogGarment garment;
  final VoidCallback onTap;

  @override
  ConsumerState<CatalogCard> createState() => _CatalogCardState();
}

class _CatalogCardState extends ConsumerState<CatalogCard> {
  var _hover = false; // estado efímero y visual

  @override
  Widget build(BuildContext context) {
    final garment = widget.garment;
    final percent = ref.watch(catalogSettingsProvider).value?.layawayPercent;
    final textTheme = Theme.of(context).textTheme;
    // Tarjeta angosta (teléfono): foto cuadrada y menos aire vertical.
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Semantics(
      button: true,
      label: garment.nameLabel,
      child: AppPressable(
        onTap: widget.onTap,
        onHoverChanged: (value) => setState(() => _hover = value),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sin marco: la foto es la tarjeta; solo se eleva con el mouse.
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CatalogCardPhoto.radius),
                boxShadow: AppCatalogColors.cardShadow(lifted: _hover),
              ),
              child: CatalogCardPhoto(
                garment: garment,
                hover: _hover,
                aspectRatio: compact ? 1 : 4 / 5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              garment.nameLabel,
              style: textTheme.titleSmall?.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 2),
            DotSeparatedText(
              parts: [garment.goldShort, ...garment.shortSpecs],
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            CatalogCardPriceRow(garment: garment, canReserve: percent != null),
          ],
        ),
      ),
    );
  }
}
