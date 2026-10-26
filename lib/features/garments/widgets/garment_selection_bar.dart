import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/delete_garments_dialog.dart';
import 'package:sistema_oro/shared/providers/keyboard_provider.dart';
import 'package:sistema_oro/shared/widgets/app_collapse.dart';

/// Barra inferior (zona del pulgar) con la acción sobre las prendas marcadas:
/// «Eliminar N». Va en `Scaffold.bottomNavigationBar` mientras hay selección;
/// con el teclado abierto se esconde (con animación) para dejarle sitio a la
/// lista, y su texto crece hasta 1.2× como el de las demás barras.
class GarmentSelectionBar extends ConsumerWidget {
  const GarmentSelectionBar({super.key, required this.selected});

  final List<Garment> selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(keyboardOpenProvider);
    final scheme = Theme.of(context).colorScheme;
    return AppCollapse(
      visible: !hidden,
      child: hidden
          ? const SizedBox.shrink()
          : Material(
              color: scheme.surface,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: scheme.outline)),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding:
                        DesignTokens.pagePaddingFor(
                          MediaQuery.sizeOf(context).width,
                        ).copyWith(
                          top: DesignTokens.spaceSm,
                          bottom: DesignTokens.spaceSm,
                        ),
                    child: MediaQuery.withClampedTextScaling(
                      maxScaleFactor: 1.2,
                      child: FilledButton.icon(
                        onPressed: selected.isEmpty
                            ? null
                            : () => showDialog<void>(
                                context: context,
                                builder: (_) =>
                                    DeleteGarmentsDialog(garments: selected),
                              ),
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.error,
                          minimumSize: const Size.fromHeight(
                            DesignTokens.dialogButtonHeight,
                          ),
                        ),
                        icon: const Icon(Icons.delete_outline),
                        label: Text(
                          selected.length == 1
                              ? 'Eliminar 1 seleccionada'
                              : 'Eliminar ${selected.length} seleccionadas',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
