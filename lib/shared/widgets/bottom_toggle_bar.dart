import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/shared/providers/keyboard_provider.dart';
import 'package:sistema_oro/shared/widgets/app_collapse.dart';
import 'package:sistema_oro/shared/widgets/app_toggle.dart';
import 'package:sistema_oro/shared/widgets/app_toggle_option.dart';

/// Pestañas de una lista al pie de la pantalla, en la zona del pulgar (el
/// teléfono se usa con una mano). Va en `Scaffold.bottomNavigationBar`, encima
/// del menú. Con el teclado abierto se esconde (con animación) para dejarle
/// sitio a la lista. Es navegación, como la barra de abajo del menú: su texto
/// crece hasta 1.2× y no más, para que las opciones se vean parejas.
class BottomToggleBar<T> extends ConsumerWidget {
  const BottomToggleBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<AppToggleOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  static const double _maxTextScale = 1.2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(keyboardOpenProvider);
    final width = MediaQuery.sizeOf(context).width;
    final scheme = Theme.of(context).colorScheme;
    return AppCollapse(
      visible: !hidden,
      child: hidden
          ? const SizedBox.shrink()
          : Material(
              color: scheme.surface,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: scheme.outline)),
                ),
                child: SafeArea(
                  top: false,
                  child: Center(
                    heightFactor: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: DesignTokens.contentMaxWidth,
                      ),
                      child: Padding(
                        padding: DesignTokens.pagePaddingFor(width).copyWith(
                          top: DesignTokens.spaceSm,
                          bottom: DesignTokens.spaceSm,
                        ),
                        child: MediaQuery.withClampedTextScaling(
                          maxScaleFactor: _maxTextScale,
                          child: AppToggle<T>(
                            compact: true,
                            touch: true,
                            options: options,
                            selected: selected,
                            onSelected: onSelected,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
