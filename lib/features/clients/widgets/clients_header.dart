import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/clients/providers/clients_provider.dart';
import 'package:sistema_oro/features/clients/utils/client_rules.dart';
import 'package:sistema_oro/shared/widgets/app_toggle_option.dart';
import 'package:sistema_oro/shared/widgets/list_filter_bar.dart';

class ClientsHeader extends ConsumerWidget {
  const ClientsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(clientsFilterProvider);
    return ListFilterBar<ClientsTab>(
      hint: 'Buscar por nombre o WhatsApp',
      selected: filter.tab,
      options: [
        for (final tab in ClientsTab.values)
          AppToggleOption(value: tab, label: tab.label),
      ],
      onSelected: ref.read(clientsFilterProvider.notifier).selectTab,
      onSearch: ref.read(clientsFilterProvider.notifier).search,
    );
  }
}
