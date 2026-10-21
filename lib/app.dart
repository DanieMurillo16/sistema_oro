import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/config/app_config.dart';
import 'package:sistema_oro/shared/widgets/dismiss_keyboard.dart';

/// Marco común de las dos entradas (administración oscura y catálogo claro):
/// cada una pasa su tema y su router.
class App extends ConsumerWidget {
  const App({super.key, required this.theme, required this.routerProvider});

  final ThemeData theme;
  final Provider<GoRouter> routerProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: ref.watch(routerProvider),
      // El overlay donde AppToast dibuja los avisos: va por encima de cualquier
      // diálogo. Y dentro de él, DismissKeyboard cierra el teclado al tocar
      // fuera de un campo en cualquier pantalla o diálogo.
      builder: FlutterSmartDialog.init(
        builder: (context, child) =>
            DismissKeyboard(child: child ?? const SizedBox.shrink()),
      ),
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
