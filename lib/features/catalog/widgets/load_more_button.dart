import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/services/app_toast.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';

/// «Ver más prendas»: trae la página siguiente del listado.
class LoadMoreButton extends ConsumerStatefulWidget {
  const LoadMoreButton({super.key});

  @override
  ConsumerState<LoadMoreButton> createState() => _LoadMoreButtonState();
}

class _LoadMoreButtonState extends ConsumerState<LoadMoreButton> {
  var _loading = false; // estado efímero del botón

  Future<void> _load() async {
    setState(() => _loading = true);
    final ok = await ref.read(catalogGarmentsProvider.notifier).loadMore();
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      AppToast.error('No pudimos traer más prendas. Intenta nuevamente.');
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceLg),
    child: Center(
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _load,
        icon: _loading
            ? const SizedBox.square(
                dimension: DesignTokens.progressSize,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.expand_more),
        label: const Text('Ver más prendas'),
      ),
    ),
  );
}
