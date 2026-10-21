import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/garments/providers/garments_filter_provider.dart';
import 'package:sistema_oro/features/garments/providers/garments_provider.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/garment_form_dialog.dart';
import 'package:sistema_oro/features/garments/widgets/garment_tile.dart';
import 'package:sistema_oro/features/garments/widgets/garments_app_bar.dart';
import 'package:sistema_oro/features/garments/widgets/garments_header.dart';
import 'package:sistema_oro/shared/widgets/app_async_view.dart';
import 'package:sistema_oro/shared/widgets/app_fab.dart';
import 'package:sistema_oro/shared/widgets/list_header_padding.dart';
import 'package:sistema_oro/shared/widgets/page_body.dart';
import 'package:sistema_oro/shared/widgets/responsive_cards.dart';

/// El inventario: todas las prendas, su stock y sus precios.
class GarmentsScreen extends ConsumerWidget {
  const GarmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garments = ref.watch(filteredGarmentsProvider);
    final canCreate = ref.watch(canProvider(Permissions.garmentsCreate));
    return Scaffold(
      appBar: const GarmentsAppBar(),
      floatingActionButton: canCreate
          ? AppFab(
              heroTag: 'garments_new',
              icon: Icons.add,
              label: 'Nueva prenda',
              compactOnPhone: true,
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const GarmentFormDialog(),
              ),
            )
          : null,
      body: PageBody(
        child: Column(
          children: [
            const ListHeaderPadding(child: GarmentsHeader()),
            Expanded(
              child: AppAsyncView(
                state: ref.watch(garmentsProvider),
                isEmpty: (_) => garments.isEmpty,
                onRetry: () => ref.invalidate(garmentsProvider),
                emptyIcon: Icons.diamond_outlined,
                emptyTitle: 'Sin prendas',
                emptyMessage: 'No hay prendas que coincidan con este filtro.',
                builder: (_) => ResponsiveCards(
                  bottomPadding: DesignTokens.listBottomSpace,
                  itemCount: garments.length,
                  itemBuilder: (context, index) => GarmentTile(
                    key: ValueKey(garments[index].id),
                    garment: garments[index],
                    onTap: () =>
                        context.go(AppRoutes.garment(garments[index].id)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
