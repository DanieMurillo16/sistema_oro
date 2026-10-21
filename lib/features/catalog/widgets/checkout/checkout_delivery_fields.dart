import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/checkout_draft.dart';
import 'package:sistema_oro/features/catalog/utils/checkout_rules.dart';
import 'package:sistema_oro/shared/widgets/app_collapse.dart';
import 'package:sistema_oro/shared/widgets/app_toggle.dart';
import 'package:sistema_oro/shared/widgets/app_toggle_option.dart';

/// Recojo o envío; con envío aparecen la ciudad y la dirección.
class CheckoutDeliveryFields extends StatelessWidget {
  const CheckoutDeliveryFields({
    super.key,
    required this.delivery,
    required this.onChanged,
    required this.city,
    required this.address,
  });

  final CatalogDelivery delivery;
  final ValueChanged<CatalogDelivery> onChanged;
  final TextEditingController city;
  final TextEditingController address;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Entrega', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: DesignTokens.spaceSm),
      AppToggle<CatalogDelivery>(
        options: const [
          AppToggleOption(
            value: CatalogDelivery.pickup,
            label: 'Recojo',
            icon: Icons.storefront_outlined,
          ),
          AppToggleOption(
            value: CatalogDelivery.shipping,
            label: 'Envío',
            icon: Icons.local_shipping_outlined,
          ),
        ],
        selected: delivery,
        onSelected: onChanged,
      ),
      AppCollapse(
        visible: delivery == CatalogDelivery.shipping,
        child: Padding(
          padding: const EdgeInsets.only(top: DesignTokens.spaceMd),
          child: Column(
            children: [
              TextFormField(
                key: const Key('checkout_city'),
                controller: city,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  counterText: '',
                ),
                validator: (text) => CheckoutRules.city(text, delivery),
              ),
              const SizedBox(height: DesignTokens.spaceMd),
              TextFormField(
                key: const Key('checkout_address'),
                controller: address,
                maxLength: 200,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  counterText: '',
                ),
                validator: (text) => CheckoutRules.address(text, delivery),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
