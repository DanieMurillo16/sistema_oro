import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_brand.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_chat_button.dart';
import 'package:sistema_oro/features/catalog/widgets/catalog_type_strip.dart';

/// La cabecera al bajar la lista: marca, tipos de prenda y WhatsApp. En ancho,
/// todo en una fila; en teléfono, los tipos debajo.
class CatalogHeaderCompact extends StatelessWidget {
  const CatalogHeaderCompact({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) =>
        constraints.maxWidth >= DesignTokens.compactLayoutWidth
        ? const _Wide()
        : const _Narrow(),
  );
}

class _Wide extends StatelessWidget {
  const _Wide();

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      // Los tipos quedan en el centro de la pantalla; marca y chat, a los lados.
      const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.catalogHeaderSideReserve,
        ),
        child: CatalogTypeStrip(),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth:
                DesignTokens.catalogHeaderSideReserve - DesignTokens.spaceMd,
          ),
          child: const CatalogBrand(),
        ),
      ),
      const Align(alignment: Alignment.centerRight, child: CatalogChatButton()),
    ],
  );
}

class _Narrow extends StatelessWidget {
  const _Narrow();

  @override
  Widget build(BuildContext context) => const Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: CatalogBrand(),
            ),
          ),
          SizedBox(width: DesignTokens.spaceSm),
          CatalogChatButton(),
        ],
      ),
      SizedBox(height: DesignTokens.spaceSm),
      CatalogTypeStrip(),
    ],
  );
}
