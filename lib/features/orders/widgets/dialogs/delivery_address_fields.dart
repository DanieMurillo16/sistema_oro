import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/orders/models/order_enums.dart';
import 'package:sistema_oro/features/orders/utils/order_rules.dart';
import 'package:sistema_oro/shared/widgets/app_collapse.dart';

/// Ciudad y dirección: aparecen solo cuando la entrega es por envío.
class DeliveryAddressFields extends StatelessWidget {
  const DeliveryAddressFields({
    super.key,
    required this.delivery,
    required this.city,
    required this.address,
  });

  final DeliveryType delivery;
  final TextEditingController city;
  final TextEditingController address;

  @override
  Widget build(BuildContext context) => AppCollapse(
    visible: delivery == DeliveryType.shipping,
    child: Padding(
      padding: const EdgeInsets.only(top: DesignTokens.spaceMd),
      child: Column(
        children: [
          TextFormField(
            key: const Key('delivery_city'),
            controller: city,
            maxLength: 80,
            decoration: const InputDecoration(
              labelText: 'Ciudad',
              counterText: '',
            ),
            validator: (text) => OrderRules.city(text, delivery),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          TextFormField(
            key: const Key('delivery_address'),
            controller: address,
            maxLength: 200,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Dirección',
              counterText: '',
            ),
            validator: (text) => OrderRules.address(text, delivery),
          ),
        ],
      ),
    ),
  );
}
