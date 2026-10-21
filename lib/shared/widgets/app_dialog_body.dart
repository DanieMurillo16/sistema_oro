import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';

class AppDialogBody extends StatelessWidget {
  const AppDialogBody({
    super.key,
    required this.header,
    required this.content,
    required this.actions,
    required this.scrollContent,
  });
  final Widget header;
  final Widget content;
  final Widget actions;
  final bool scrollContent;

  @override
  Widget build(BuildContext context) {
    // Con el teclado abierto el encabezado se oculta para dejar sitio a los
    // campos (en un teléfono de 320 px con texto ampliado, encabezado + pie
    // solos ya desbordan). Al tocar fuera del campo el teclado se cierra
    // (DismissKeyboard) y el encabezado vuelve.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final padding = DesignTokens.pagePaddingFor(
      MediaQuery.sizeOf(context).width,
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: DesignTokens.dialogMaxWidth,
        maxHeight: DesignTokens.dialogMaxHeight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!keyboardOpen) ...[header, const Divider(height: 1)],
          Flexible(
            child: scrollContent
                ? SingleChildScrollView(padding: padding, child: content)
                : Padding(padding: padding, child: content),
          ),
          actions,
        ],
      ),
    );
  }
}
