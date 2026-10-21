import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/garments/providers/garments_provider.dart';
import 'package:sistema_oro/features/orders/providers/orders_provider.dart';
import 'package:sistema_oro/features/summary/data/summary_repository.dart';
import 'package:sistema_oro/features/summary/models/monthly_summary.dart';
import 'package:sistema_oro/features/summary/utils/summary_rules.dart';

/// El mes que se está viendo (siempre el día 1). Empieza en el mes actual.
final summaryMonthProvider = NotifierProvider<SummaryMonthNotifier, DateTime>(
  SummaryMonthNotifier.new,
);

class SummaryMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => SummaryRules.firstOfMonth(DateTime.now());

  void previous() => state = SummaryRules.shift(state, -1);

  void next() {
    if (SummaryRules.canGoNext(state, DateTime.now())) {
      state = SummaryRules.shift(state, 1);
    }
  }
}

/// Las cifras del mes elegido. Cambiar de mes o de sesión las vuelve a pedir
/// conservando lo que se ve (no se vacía la pantalla). Se actualizan solas
/// cuando cambian los pedidos (abonos, anulaciones, confirmaciones) o las prendas.
final summaryProvider = AsyncNotifierProvider<SummaryNotifier, MonthlySummary?>(
  SummaryNotifier.new,
);

class SummaryNotifier extends AsyncNotifier<MonthlySummary?> {
  @override
  Future<MonthlySummary?> build() async {
    ref.watch(sessionUserIdProvider);
    final month = ref.watch(summaryMonthProvider);
    if (!ref.watch(canProvider(Permissions.summaryView))) return null;
    ref.listen(ordersProvider, (previous, next) {
      if (previous?.hasValue == true && next.hasValue) ref.invalidateSelf();
    });
    ref.listen(garmentsProvider, (previous, next) {
      if (previous?.hasValue == true && next.hasValue) ref.invalidateSelf();
    });
    return ref.read(summaryRepositoryProvider).month(SummaryRules.key(month));
  }
}

/// ¿Están tapadas las cifras de dinero? Lo comparten todas las vistas con saldos.
final balancesHiddenProvider = NotifierProvider<BalancesHiddenNotifier, bool>(
  BalancesHiddenNotifier.new,
);

class BalancesHiddenNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}
