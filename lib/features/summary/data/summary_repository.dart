import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/network/api_client.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';
import 'package:sistema_oro/features/summary/models/monthly_summary.dart';

final summaryRepositoryProvider = Provider<SummaryRepository>(
  (ref) => SummaryRepository(ref.watch(apiClientProvider)),
);

/// Única puerta de la vista de resumen al servidor.
class SummaryRepository {
  const SummaryRepository(this._api);

  final ApiClient _api;

  /// [monthKey] es `AAAA-MM`.
  Future<MonthlySummary> month(String monthKey) async =>
      MonthlySummary.fromJson(
        await _api.get(
          ApiEndpoints.summary,
          queryParameters: {'mes': monthKey},
        ),
      );
}
