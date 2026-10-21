import 'package:flutter/material.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_header.dart';

/// Delegado de la cabecera fija (alto constante: no salta al compactarse).
class CatalogFixedHeader extends SliverPersistentHeaderDelegate {
  const CatalogFixedHeader(this.height);

  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => const CatalogHeader(blur: true);

  @override
  bool shouldRebuild(CatalogFixedHeader old) => old.height != height;
}
