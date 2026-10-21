import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/settings/data/settings_repository.dart';
import 'package:sistema_oro/features/settings/models/app_setting.dart';
import 'package:sistema_oro/features/settings/models/brand_logo_state.dart';

/// Los ajustes de la sesión (único lugar donde viven).
final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, List<AppSetting>>(
      SettingsNotifier.new,
    );

class SettingsNotifier extends AsyncNotifier<List<AppSetting>> {
  @override
  Future<List<AppSetting>> build() async {
    ref.watch(sessionUserIdProvider);
    if (!ref.watch(canProvider(Permissions.settingsView))) return const [];
    return ref.read(settingsRepositoryProvider).list();
  }

  void upsert(AppSetting setting) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final s in current)
        if (s.key == setting.key) setting else s,
    ]);
  }
}

/// Guardar un ajuste.
final settingActionsProvider =
    AsyncNotifierProvider.autoDispose<SettingActionsNotifier, String?>(
      SettingActionsNotifier.new,
    );

class SettingActionsNotifier extends AsyncNotifier<String?> {
  @override
  String? build() => null;

  Future<void> save(String key, Object value) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final saved = await ref.read(settingsRepositoryProvider).save(key, value);
      ref.read(settingsProvider.notifier).upsert(saved);
      return 'Ajuste guardado';
    });
  }
}

/// El logo de la marca (un dato, un provider): lo leen la sección de Ajustes y
/// la vista previa; al cambiarlo se actualiza aquí y en la vista.
final brandLogoProvider =
    AsyncNotifierProvider<BrandLogoNotifier, BrandLogoState>(
      BrandLogoNotifier.new,
    );

class BrandLogoNotifier extends AsyncNotifier<BrandLogoState> {
  @override
  Future<BrandLogoState> build() async {
    ref.watch(sessionUserIdProvider);
    if (!ref.watch(canProvider(Permissions.settingsView))) {
      return const BrandLogoState(url: '', version: 0);
    }
    return ref.read(settingsRepositoryProvider).logo();
  }

  void set(BrandLogoState logo) => state = AsyncData(logo);
}

/// Cambiar o restaurar el logo. El dato es el mensaje para el aviso.
final brandLogoActionsProvider =
    AsyncNotifierProvider.autoDispose<BrandLogoActionsNotifier, String?>(
      BrandLogoActionsNotifier.new,
    );

class BrandLogoActionsNotifier extends AsyncNotifier<String?> {
  @override
  String? build() => null;

  Future<void> change(PickedImage image) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final logo = await ref.read(settingsRepositoryProvider).uploadLogo(image);
      ref.read(brandLogoProvider.notifier).set(logo);
      return 'Logo actualizado. El catálogo lo mostrará al recargar.';
    });
  }

  Future<void> restore() async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final logo = await ref.read(settingsRepositoryProvider).restoreLogo();
      ref.read(brandLogoProvider.notifier).set(logo);
      return 'Volvió el logo original.';
    });
  }
}
