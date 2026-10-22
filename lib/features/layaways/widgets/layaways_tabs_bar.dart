import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/orders/providers/order_filters_provider.dart';
import 'package:sistema_oro/features/orders/utils/order_rules.dart';
import 'package:sistema_oro/shared/widgets/app_toggle_option.dart';
import 'package:sistema_oro/shared/widgets/bottom_toggle_bar.dart';

/// Pestañas de Separados, al pie de la pantalla.
class LayawaysTabsBar extends ConsumerWidget {
  const LayawaysTabsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      BottomToggleBar<LayawaysTab>(
        selected: ref.watch(layawaysFilterProvider.select((f) => f.tab)),
        options: [
          for (final tab in LayawaysTab.values)
            AppToggleOption(value: tab, label: tab.label),
        ],
        onSelected: ref.read(layawaysFilterProvider.notifier).selectTab,
      );
}
