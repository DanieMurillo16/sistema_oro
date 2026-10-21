import 'package:flutter/material.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/currency_formatter.dart';
import 'package:sistema_oro/core/utils/uuid.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/models/checkout_draft.dart';
import 'package:sistema_oro/features/catalog/utils/checkout_rules.dart';
import 'package:sistema_oro/features/catalog/widgets/checkout/checkout_amount_field.dart';
import 'package:sistema_oro/features/catalog/widgets/checkout/checkout_box_toggle.dart';
import 'package:sistema_oro/features/catalog/widgets/checkout/checkout_contact_fields.dart';
import 'package:sistema_oro/features/catalog/widgets/checkout/checkout_delivery_fields.dart';
import 'package:sistema_oro/features/catalog/widgets/checkout/checkout_quantity_row.dart';
import 'package:sistema_oro/features/catalog/widgets/checkout/checkout_summary.dart';
import 'package:sistema_oro/features/catalog/widgets/checkout/transfer_card.dart';
import 'package:sistema_oro/shared/widgets/image_picker_field.dart';

/// El formulario de compra o separado. Dueño de su estado (campos, opciones,
/// comprobante y la clave de envío); el diálogo lo manda a validar con
/// `currentState.submit()` y recibe el resultado en [onSubmit].
class CheckoutForm extends StatefulWidget {
  const CheckoutForm({
    super.key,
    required this.garment,
    required this.kind,
    required this.settings,
    required this.onSubmit,
  });

  final CatalogGarment garment;
  final RequestKind kind;
  final CatalogSettings settings;
  final void Function(CheckoutDraft draft, PickedImage receipt) onSubmit;

  @override
  State<CheckoutForm> createState() => CheckoutFormState();
}

class CheckoutFormState extends State<CheckoutForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _whatsapp = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _amount = TextEditingController();
  final _bank = TextEditingController();
  final _submitKey = uuidV4(); // se reutiliza si la persona reintenta
  var _quantity = 1;
  var _box = BoxKind.free;
  var _delivery = CatalogDelivery.pickup;
  PickedImage? _receipt;
  var _submitted = false; // para mostrar el error del comprobante

  bool get _isLayaway => widget.kind == RequestKind.layaway;

  int get _total =>
      CheckoutRules.total(widget.garment, _quantity, _box, widget.settings);

  int get _minimum => CheckoutRules.minimumDeposit(widget.garment);

  @override
  void initState() {
    super.initState();
    if (_isLayaway) _amount.text = formatCopInput(_minimum);
  }

  @override
  void dispose() {
    for (final c in [_name, _whatsapp, _city, _address, _amount, _bank]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Valida y, si todo está bien, entrega el borrador y el comprobante.
  void submit() {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate() || _receipt == null) return;
    final shipping = _delivery == CatalogDelivery.shipping;
    widget.onSubmit(
      CheckoutDraft(
        submitKey: _submitKey,
        kind: widget.kind,
        garmentId: widget.garment.id,
        quantity: _isLayaway ? 1 : _quantity,
        box: _box,
        name: _name.text.trim(),
        whatsapp: _whatsapp.text.replaceAll(RegExp(r'\D'), ''),
        delivery: _delivery,
        city: shipping ? _city.text.trim() : null,
        address: shipping ? _address.text.trim() : null,
        amount: _isLayaway ? parseCopInput(_amount.text)!.round() : _total,
        bank: _bank.text.trim().isEmpty ? null : _bank.text.trim(),
      ),
      _receipt!,
    );
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: DesignTokens.spaceLg);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CheckoutSummary(
            garment: widget.garment,
            kind: widget.kind,
            trailing:
                !_isLayaway && CheckoutRules.maxQuantityFor(widget.garment) > 1
                ? (inline) => CheckoutQuantityRow(
                    inline: inline,
                    garment: widget.garment,
                    quantity: _quantity,
                    onChanged: (value) => setState(() => _quantity = value),
                  )
                : null,
          ),
          gap,
          CheckoutBoxToggle(
            settings: widget.settings,
            box: _box,
            onChanged: (value) => setState(() => _box = value),
          ),
          gap,
          CheckoutDeliveryFields(
            delivery: _delivery,
            onChanged: (value) => setState(() => _delivery = value),
            city: _city,
            address: _address,
          ),
          gap,
          CheckoutContactFields(name: _name, whatsapp: _whatsapp),
          gap,
          TransferCard(
            settings: widget.settings,
            amount: _isLayaway ? _minimum : _total,
          ),
          if (_isLayaway) ...[
            const SizedBox(height: DesignTokens.spaceMd),
            CheckoutAmountField(
              controller: _amount,
              minimum: _minimum,
              total: _total,
            ),
          ],
          const SizedBox(height: DesignTokens.spaceMd),
          // El banco va junto al comprobante: de dónde salió la transferencia.
          TextFormField(
            key: const Key('checkout_bank'),
            controller: _bank,
            maxLength: 60,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Banco (opcional)',
              counterText: '',
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          ImagePickerField(
            image: _receipt,
            onChanged: (image) => setState(() => _receipt = image),
            errorText: _submitted && _receipt == null
                ? 'Adjunta el comprobante de la transferencia.'
                : null,
          ),
        ],
      ),
    );
  }
}
