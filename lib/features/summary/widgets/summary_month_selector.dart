import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/motion.dart';
import 'package:sistema_oro/features/summary/providers/summary_provider.dart';
import 'package:sistema_oro/features/summary/utils/summary_rules.dart';
import 'package:sistema_oro/shared/widgets/visibility_toggle_button.dart';

/// «‹ octubre 2026 ›» para cambiar de mes y el ojo que tapa las cifras de
/// dinero. No se avanza más allá del mes actual.
class SummaryMonthSelector extends ConsumerWidget {
  const SummaryMonthSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(summaryMonthProvider);
    final hidden = ref.watch(balancesHiddenProvider);
    final canNext = SummaryRules.canGoNext(month, DateTime.now());
    final notifier = ref.read(summaryMonthProvider.notifier);
    return Row(
      children: [
        IconButton(
          tooltip: 'Mes anterior',
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: notifier.previous,
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: motionDuration(context, DesignTokens.animationFast),
            child: FittedBox(
              key: ValueKey(month),
              fit: BoxFit.scaleDown,
              child: Text(
                SummaryRules.label(month),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Mes siguiente',
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: canNext ? notifier.next : null,
        ),
        VisibilityToggleButton(
          hidden: hidden,
          onTap: ref.read(balancesHiddenProvider.notifier).toggle,
        ),
      ],
    );
  }
}
