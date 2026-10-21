import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/services/app_toast.dart';
import 'package:sistema_oro/core/services/link_launcher.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/theme/status_colors.dart';
import 'package:sistema_oro/features/orders/models/order.dart';
import 'package:sistema_oro/features/orders/providers/order_filters_provider.dart';
import 'package:sistema_oro/features/orders/utils/order_labels.dart';
import 'package:sistema_oro/shared/widgets/dot_separated_text.dart';
import 'package:sistema_oro/shared/widgets/network_thumb.dart';
import 'package:sistema_oro/shared/widgets/title_with_amount.dart';

/// Una fila de «Recordar»: el separado, hace cuántos días no abona y el botón
/// que abre WhatsApp con un recordatorio amable ya escrito.
class ReminderTile extends ConsumerWidget {
  const ReminderTile({super.key, required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(layawayIdleDaysProvider(order));
    final tone = days >= 30
        ? StatusTone.error
        : days >= 15
        ? StatusTone.warning
        : StatusTone.neutral;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NetworkThumb(url: order.thumbnail),
              const SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleWithAmount(
                      title: order.clientLabel,
                      amount: 'Saldo ${order.balanceLabel}',
                    ),
                    DotSeparatedText(parts: [order.garmentLabel, order.code]),
                    const SizedBox(height: DesignTokens.spaceXs),
                    Text(
                      idleDaysLabel(days),
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: statusColor(context, tone)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              IconButton.filledTonal(
                tooltip: 'Recordar por WhatsApp',
                icon: const Icon(Icons.chat_outlined),
                onPressed: () => _remind(ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _remind(WidgetRef ref) async {
    final opened = await ref
        .read(linkLauncherProvider)
        .openWhatsApp(order.whatsapp, message: order.reminderMessage);
    if (!opened) AppToast.warning('No se pudo abrir WhatsApp.');
  }
}
