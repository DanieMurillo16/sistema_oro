import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/features/catalog/data/catalog_repository.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/models/checkout_draft.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';

/// Enviar la solicitud de compra o separado. El dato es el recibo (código) una
/// vez enviada. Si la prenda ya no está disponible, se recargan el listado y el
/// detalle para que la persona vea la realidad.
final checkoutProvider =
    AsyncNotifierProvider.autoDispose<CheckoutNotifier, RequestReceipt?>(
      CheckoutNotifier.new,
    );

class CheckoutNotifier extends AsyncNotifier<RequestReceipt?> {
  @override
  RequestReceipt? build() => null;

  Future<void> submit(CheckoutDraft draft, PickedImage receipt) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        return await ref
            .read(catalogRepositoryProvider)
            .submitRequest(draft, receipt);
      } on ApiException catch (error) {
        if (error.code == 'NO_DISPONIBLE') {
          ref.invalidate(catalogGarmentsProvider);
          ref.invalidate(catalogGarmentProvider(draft.garmentId));
        }
        rethrow;
      }
    });
  }
}
