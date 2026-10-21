import 'package:flutter/material.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/garment_form_photos.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';
import 'package:sistema_oro/features/garments/models/garment_draft.dart';
import 'package:sistema_oro/features/garments/providers/garment_actions_provider.dart';
import 'package:sistema_oro/features/garments/providers/garment_types_provider.dart';
import 'package:sistema_oro/features/garments/utils/garment_rules.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/garment_form_controllers.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/garment_basics_fields.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/garment_extra_fields.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/garment_price_fields.dart';
import 'package:sistema_oro/features/garments/widgets/dialogs/garment_spec_fields.dart';
import 'package:sistema_oro/shared/utils/listen_action.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';

/// Crear o editar una prenda. Con [garment] edita; sin él crea (con las fotos
/// elegidas) y, al terminar, abre su detalle.
class GarmentFormDialog extends ConsumerStatefulWidget {
  const GarmentFormDialog({super.key, this.garment});

  final Garment? garment;

  @override
  ConsumerState<GarmentFormDialog> createState() => _GarmentFormDialogState();
}

class _GarmentFormDialogState extends ConsumerState<GarmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controllers = GarmentFormControllers(widget.garment);
  late GoldType _goldType = widget.garment?.goldType ?? GoldType.national;
  late bool _active = widget.garment?.active ?? true;
  GarmentType? _type;
  var _photos = <PickedImage>[];
  var _typeInitialized = false;

  bool get _isEdit => widget.garment != null;

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  GarmentDraft _draft(bool canSeeCost) {
    final c = _controllers;
    String? text(TextEditingController controller) =>
        controller.text.trim().isEmpty ? null : controller.text.trim();
    int? money(TextEditingController controller) =>
        parseCopInput(controller.text)?.round();
    return GarmentDraft(
      typeId: _type!.id,
      name: c.name.text.trim(),
      goldType: _goldType,
      weight: GarmentRules.decimalText(c.weight.text)!,
      salePrice: money(c.salePrice)!,
      reference: text(c.reference),
      description: text(c.description),
      length: GarmentRules.decimalText(c.length.text),
      width: GarmentRules.decimalText(c.width.text),
      thickness: GarmentRules.decimalText(c.thickness.text),
      previousPrice: money(c.previousPrice),
      purchasePrice: canSeeCost ? money(c.purchasePrice) : null,
      stock: int.tryParse(c.stock.text.trim()) ?? 0,
      active: _active,
    );
  }

  void _submit(bool canSeeCost) {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(garmentActionsProvider.notifier);
    final draft = _draft(canSeeCost);
    if (_isEdit) {
      notifier.edit(widget.garment!.id, draft);
    } else {
      notifier.create(draft, photos: _photos);
    }
  }

  /// Al guardar (la prenda y sus fotos ya están en el servidor): cierra el
  /// diálogo y, si era nueva, abre su detalle.
  void _onSaved() {
    final createdId = ref.read(garmentActionsProvider.notifier).createdId;
    if (!mounted) return;
    Navigator.of(context).pop();
    if (!_isEdit && createdId != null) {
      context.go(AppRoutes.garment(createdId));
    }
  }

  /// Al editar, deja elegido el tipo que ya tiene la prenda (una sola vez, en
  /// cuanto llegan los tipos).
  void _resolveType(List<GarmentType> types) {
    if (_typeInitialized || widget.garment == null || types.isEmpty) return;
    _type = types.where((t) => t.id == widget.garment!.typeId).firstOrNull;
    _typeInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    listenAction(ref, garmentActionsProvider, onSuccess: _onSaved);
    final types =
        (ref.watch(garmentTypesProvider).value ?? const <GarmentType>[])
            .where((t) => t.active || t.id == widget.garment?.typeId)
            .toList();
    _resolveType(types);
    final canSeeCost = ref.watch(canProvider(Permissions.garmentsCost));
    return AppDialog(
      header: DialogHeader(
        icon: Icons.diamond_outlined,
        title: _isEdit ? 'Editar prenda' : 'Nueva prenda',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GarmentBasicsFields(
              controllers: _controllers,
              types: types,
              type: _type,
              onTypeChanged: (value) => setState(() => _type = value),
              goldType: _goldType,
              onGoldTypeChanged: (value) => setState(() => _goldType = value),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            GarmentSpecFields(controllers: _controllers, isEdit: _isEdit),
            const SizedBox(height: DesignTokens.spaceMd),
            GarmentPriceFields(
              controllers: _controllers,
              canSeeCost: canSeeCost,
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            if (!_isEdit) ...[
              GarmentFormPhotos(
                photos: _photos,
                onChanged: (value) => setState(() => _photos = value),
              ),
              const SizedBox(height: DesignTokens.spaceMd),
            ],
            GarmentExtraFields(
              controllers: _controllers,
              isEdit: _isEdit,
              active: _active,
              onActiveChanged: (value) => setState(() => _active = value),
            ),
          ],
        ),
      ),
      actions: DialogActions(
        onConfirm: () => _submit(canSeeCost),
        isLoading: ref.watch(garmentActionsProvider).isLoading,
        confirmLabel: _isEdit ? 'Guardar cambios' : 'Crear prenda',
      ),
    );
  }
}
