import 'package:sistema_oro/core/utils/text_formatter.dart';
import 'package:sistema_oro/features/clients/models/client.dart';
import 'package:sistema_oro/shared/utils/search_options.dart';

enum ClientsTab {
  all('Todos'),
  withBalance('Con saldo');

  const ClientsTab(this.label);

  final String label;
}

abstract final class ClientRules {
  static String? name(String? value) =>
      (value ?? '').trim().length < 2 ? 'Escribe el nombre del cliente.' : null;

  static List<Client> filtered(List<Client> all, ClientsTab tab, String query) {
    final byTab = switch (tab) {
      ClientsTab.all => all,
      ClientsTab.withBalance => all.where((c) => c.pendingBalance > 0),
    };
    final text = normalizeSearch(query);
    if (text.isEmpty) return byTab.toList();
    return byTab
        .where(
          (c) =>
              normalizeSearch('${formatDisplayText(c.name)} ${c.whatsapp}')
                  .contains(text),
        )
        .toList();
  }
}
