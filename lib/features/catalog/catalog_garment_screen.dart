import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_back_button.dart';
import 'package:sistema_oro/features/catalog/widgets/garment_detail_body.dart';
import 'package:sistema_oro/features/catalog/widgets/garment_gone.dart';
import 'package:sistema_oro/features/catalog/widgets/purchase_bar.dart';
import 'package:sistema_oro/features/catalog/widgets/whatsapp_fab.dart';
import 'package:sistema_oro/shared/widgets/app_async_view.dart';

/// El detalle público de una prenda: galería a un lado y datos al otro (en
/// teléfono, uno debajo del otro).
class CatalogGarmentScreen extends ConsumerWidget {
  const CatalogGarmentScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garment = ref.watch(catalogGarmentProvider(id));
    // Lo que ya se conoce del listado se muestra al instante; el detalle
    // completo (galería, 20 %) lo reemplaza cuando llega.
    final preview = ref
        .watch(catalogGarmentsProvider)
        .value
        ?.items
        .where((g) => g.id == id)
        .firstOrNull;
    final gone = isGarmentGone(garment);
    final shown = gone ? null : garment.value ?? preview;
    final narrow =
        MediaQuery.sizeOf(context).width <
        DesignTokens.catalogThreeColumnsWidth;
    return Scaffold(
      // En teléfono el flotante taparía la barra de compra.
      floatingActionButton: narrow
          ? null
          : WhatsAppFab(
              message:
                  'Hola, quiero preguntar por ${shown?.name ?? 'una prenda'} del catálogo.',
            ),
      bottomNavigationBar: narrow && shown != null
          ? PurchaseBar(garment: shown)
          : null,
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                DesignTokens.spaceMd,
                MediaQuery.paddingOf(context).top + DesignTokens.spaceSm,
                DesignTokens.spaceMd,
                DesignTokens.spaceSm,
              ),
              child: const CatalogBackButton(),
            ),
          ),
          Expanded(
            child: gone
                ? const GarmentGone()
                : shown != null
                ? GarmentDetailBody(garment: shown, showActions: !narrow)
                : AppAsyncView<CatalogGarment>(
                    state: garment,
                    isEmpty: (_) => false,
                    onRetry: () => ref.invalidate(catalogGarmentProvider(id)),
                    builder: (data) =>
                        GarmentDetailBody(garment: data, showActions: !narrow),
                  ),
          ),
        ],
      ),
    );
  }
}
