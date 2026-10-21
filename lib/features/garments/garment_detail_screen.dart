import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/providers/garment_detail_provider.dart';
import 'package:sistema_oro/features/garments/utils/garment_labels.dart';
import 'package:sistema_oro/features/garments/widgets/detail/garment_images_card.dart';
import 'package:sistema_oro/features/garments/widgets/detail/garment_info_card.dart';
import 'package:sistema_oro/features/garments/widgets/detail/garment_sales_card.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/garment_form_dialog.dart';
import 'package:sistema_oro/shared/widgets/app_action_button.dart';
import 'package:sistema_oro/shared/widgets/app_async_view.dart';
import 'package:sistema_oro/shared/widgets/page_body.dart';

/// Una prenda: sus datos, fotos y stock.
class GarmentDetailScreen extends ConsumerWidget {
  const GarmentDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(garmentDetailProvider(id));
    final canEdit = ref.watch(canProvider(Permissions.garmentsEdit));
    final canStock = ref.watch(canProvider(Permissions.garmentsStock));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.garments),
        ),
        title: Text(detail.value?.nameLabel ?? 'Prenda'),
        actions: [
          if (canEdit && detail.value != null)
            AppActionButton(
              icon: Icons.edit_outlined,
              tooltip: 'Editar prenda',
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => GarmentFormDialog(garment: detail.value),
              ),
            ),
          const SizedBox(width: DesignTokens.spaceSm),
        ],
      ),
      body: PageBody(
        child: AppAsyncView<Garment>(
          state: detail,
          isEmpty: (_) => false,
          onRetry: () => ref.invalidate(garmentDetailProvider(id)),
          builder: (garment) => ListView(
            padding: DesignTokens.pagePaddingFor(
              MediaQuery.sizeOf(context).width,
            ),
            children: [
              GarmentImagesCard(garment: garment, canEdit: canEdit),
              const SizedBox(height: DesignTokens.spaceMd),
              GarmentInfoCard(garment: garment, canAdjustStock: canStock),
              const SizedBox(height: DesignTokens.spaceMd),
              GarmentSalesCard(garmentId: garment.id),
            ],
          ),
        ),
      ),
    );
  }
}
