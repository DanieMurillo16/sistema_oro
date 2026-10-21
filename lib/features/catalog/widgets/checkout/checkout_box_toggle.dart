import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';
import 'package:sistema_oro/features/catalog/models/checkout_draft.dart';
import 'package:sistema_oro/features/catalog/utils/catalog_labels.dart';
import 'package:sistema_oro/shared/widgets/app_toggle.dart';
import 'package:sistema_oro/shared/widgets/app_toggle_option.dart';

/// Caja gratis o decorada (con su precio).
class CheckoutBoxToggle extends StatelessWidget {
  const CheckoutBoxToggle({
    super.key,
    required this.settings,
    required this.box,
    required this.onChanged,
  });

  final CatalogSettings settings;
  final BoxKind box;
  final ValueChanged<BoxKind> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Caja', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: DesignTokens.spaceSm),
      AppToggle<BoxKind>(
        options: [
          const AppToggleOption(value: BoxKind.free, label: 'Gratis'),
          const AppToggleOption(value: BoxKind.decorated, label: 'Decorada'),
        ],
        selected: box,
        onSelected: onChanged,
      ),
      const SizedBox(height: DesignTokens.spaceXs),
      Text(
        'La caja decorada suma ${settings.decoratedBoxLabel}.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}
