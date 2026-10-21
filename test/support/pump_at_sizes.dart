import 'package:flutter/material.dart';
import 'package:sistema_oro/features/catalog/providers/catalog_providers.dart';
import 'package:sistema_oro/shared/widgets/app_float.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/app.dart';
import 'package:sistema_oro/core/router/app_router.dart';
import 'package:sistema_oro/core/router/catalog_router.dart';
import 'package:sistema_oro/core/theme/app_theme.dart';
import 'package:sistema_oro/core/utils/provider_retry.dart';

/// Anchos que toda vista debe resistir: teléfono pequeño, teléfono, tablet y
/// escritorio (ver ~/.claude/flutter-base/responsive.md).
const testWidths = [320.0, 390.0, 800.0, 1300.0];

/// Alturas de teclado: cerrado y abierto.
const testKeyboards = [0.0, 300.0];

/// Escalas de texto: normal y ampliado.
const testTextScales = [1.0, 1.5];

/// Monta [view] en cada combinación de ancho × teclado × escala de texto y
/// falla si Flutter lanza cualquier excepción. Un `RenderFlex overflowed` ES una
/// excepción real, así que esto detecta desbordes de verdad.
///
/// [overrides] sustituye repositorios y providers por falsos. [theme] cambia el
/// tema (por defecto el claro; la administración usa `AppTheme.dark`).
Future<void> expectNoOverflow(
  WidgetTester tester,
  Widget view, {
  List<Override> overrides = const [],
  ThemeData? theme,
  double height = 700,
  List<double> widths = testWidths,
  List<double> keyboards = testKeyboards,
  List<double> scales = testTextScales,
}) async {
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewInsets);

  for (final width in widths) {
    tester.view.physicalSize = Size(width, height);
    for (final keyboard in keyboards) {
      tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
      for (final scale in scales) {
        await tester.pumpWidget(
          ProviderScope(
            retry: noProviderRetry,
            overrides: overrides,
            child: MaterialApp(
              theme: theme ?? AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: view,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '$width px · teclado $keyboard · texto $scale',
        );
      }
    }
  }
}

/// Monta [view] como en la app (tema, `ProviderScope` y el overlay de `AppToast`)
/// para las pruebas de flujo: se llena, se toca y se afirma lo enviado y lo
/// mostrado. Para una sola combinación de tamaño; la matriz es `expectNoOverflow`.
/// Si la vista navega con go_router, monta un `GoRouter` mínimo en su prueba.
Future<void> pumpView(
  WidgetTester tester,
  Widget view, {
  List<Override> overrides = const [],
  ThemeData? theme,
  double width = 390,
  double height = 800,
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      retry: noProviderRetry,
      overrides: overrides,
      child: MaterialApp(
        theme: theme ?? AppTheme.light,
        navigatorObservers: [FlutterSmartDialog.observer],
        builder: FlutterSmartDialog.init(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
        home: view,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Deja correr el reloj hasta vaciar los avisos (`AppToast`), para no dejar
/// temporizadores pendientes al terminar la prueba.
Future<void> dismissToasts(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(seconds: 4));
  }
  await tester.pumpAndSettle();
}

/// Monta la app de administración completa (router, sesión, tema oscuro y el
/// overlay de avisos) para las pruebas de flujo de punta a punta.
Future<void> pumpAdminApp(
  WidgetTester tester, {
  required List<Override> overrides,
  double width = 390,
  double height = 800,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      retry: noProviderRetry,
      overrides: overrides,
      child: App(theme: AppTheme.dark, routerProvider: appRouterProvider),
    ),
  );
  await tester.pumpAndSettle();
}

/// Monta el catálogo público completo (router, tema claro y avisos).
Future<void> pumpCatalogApp(
  WidgetTester tester, {
  required List<Override> overrides,
  double width = 390,
  double height = 800,
  Duration? pollInterval,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      retry: noProviderRetry,
      overrides: [
        ambientMotionProvider.overrideWithValue(false),
        catalogPollIntervalProvider.overrideWithValue(pollInterval),
        ...overrides,
      ],
      child: App(
        theme: AppTheme.catalog,
        routerProvider: catalogRouterProvider,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
