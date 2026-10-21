import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/shared/widgets/app_empty_view.dart';

/// Lo que se ve en el detalle cuando otra persona ya compró o separó la
/// prenda mientras se miraba.
class GarmentGone extends StatelessWidget {
  const GarmentGone({super.key});

  @override
  Widget build(BuildContext context) => AppEmptyView(
    icon: Icons.inventory_2_outlined,
    title: 'Esta prenda ya no está disponible',
    message: 'Alguien acaba de llevársela. Mira el resto del catálogo.',
    action: FilledButton(
      onPressed: () => context.go(AppRoutes.catalog),
      child: const Text('Ver el catálogo'),
    ),
  );
}
