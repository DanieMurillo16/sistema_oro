import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/core/utils/motion.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_trust_strip.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_filters.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_fixed_header.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_hero.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_results.dart';
import 'package:sistema_oro/features/catalog/widgets/find_it_banner.dart';
import 'package:sistema_oro/features/catalog/widgets/load_more_button.dart';
import 'package:sistema_oro/features/catalog/widgets/whatsapp_fab.dart';

/// El catálogo público: cabecera fija translúcida, portada, tipos, orden y la
/// cuadrícula de prendas con «Ver más». Sin login.
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _piecesKey =
      GlobalKey(); // estado visual: a dónde lleva «Ver el catálogo»
  final _scroll = ScrollController(); // avisa al provider cuánto se bajó

  void _report() => ref
      .read(catalogHeaderCompactProvider.notifier)
      .scrolled(_scroll.hasClients ? _scroll.offset : 0);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_report);
    // Una pantalla nueva arranca arriba aunque la anterior hubiera bajado.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _report();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _goToPieces() {
    final target = _piecesKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: motionDuration(context, const Duration(milliseconds: 500)),
      curve: DesignTokens.curve,
      alignment: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = ref.watch(catalogGarmentsProvider);
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= DesignTokens.catalogThreeColumnsWidth;
    // El ancho del contenido se centra y no pasa de 1320: en pantallas grandes
    // los lados quedan en blanco, no estirados.
    final side = ((width - DesignTokens.catalogMaxWidth) / 2).clamp(
      0.0,
      double.infinity,
    );
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);
    final headerHeight =
        MediaQuery.paddingOf(context).top +
        (wide
            ? DesignTokens.catalogHeaderWideHeight +
                  (scale - 1) * DesignTokens.catalogHeaderWideGrowth
            : DesignTokens.catalogHeaderNarrowHeight +
                  (scale - 1) * DesignTokens.catalogHeaderNarrowGrowth);
    return Scaffold(
      floatingActionButton: const WhatsAppFab(
        message: 'Hola, quiero información sobre el catálogo.',
      ),
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: CatalogFixedHeader(headerHeight),
          ),
          if (page.isLoading && page.hasValue)
            const SliverToBoxAdapter(
              child: LinearProgressIndicator(minHeight: 2),
            ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              side + DesignTokens.spaceMd,
              DesignTokens.spaceMd,
              side + DesignTokens.spaceMd,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CatalogHero(onExplore: _goToPieces),
                  KeyedSubtree(key: _piecesKey, child: const CatalogFilters()),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: side),
            sliver: const CatalogResults(),
          ),
          if (page.value?.hasMore ?? false)
            const SliverToBoxAdapter(child: LoadMoreButton()),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              side + DesignTokens.spaceMd,
              DesignTokens.spaceXl,
              side + DesignTokens.spaceMd,
              0,
            ),
            sliver: const SliverToBoxAdapter(child: CatalogTrustStrip()),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              side + DesignTokens.spaceMd,
              DesignTokens.spaceLg,
              side + DesignTokens.spaceMd,
              side + DesignTokens.spaceMd,
            ),
            sliver: const SliverToBoxAdapter(child: FindItBanner()),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: DesignTokens.listBottomSpace),
          ),
        ],
      ),
    );
  }
}
