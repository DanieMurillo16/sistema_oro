import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/settings/models/app_setting.dart';
import 'package:sistema_oro/features/settings/providers/settings_provider.dart';
import 'package:sistema_oro/features/settings/utils/setting_rules.dart';
import 'package:sistema_oro/features/settings/widgets/brand_logo_section.dart';
import 'package:sistema_oro/features/settings/widgets/edit_setting_dialog.dart';
import 'package:sistema_oro/features/settings/widgets/setting_tile.dart';
import 'package:sistema_oro/shared/widgets/app_async_view.dart';
import 'package:sistema_oro/shared/widgets/page_body.dart';
import 'package:sistema_oro/shared/widgets/section_card.dart';

/// Ajustes de la tienda: WhatsApp, datos de transferencia, % para separar,
/// recargo y caja. El catálogo los lee de aquí.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEdit = ref.watch(canProvider(Permissions.settingsEdit));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.more),
        ),
        title: const Text('Ajustes'),
      ),
      body: PageBody(
        child: AppAsyncView<List<AppSetting>>(
          state: ref.watch(settingsProvider),
          isEmpty: (list) => list.isEmpty,
          onRetry: () => ref.invalidate(settingsProvider),
          emptyIcon: Icons.tune,
          emptyTitle: 'Sin ajustes',
          emptyMessage: 'El servidor no devolvió ajustes.',
          builder: (settings) => ListView(
            padding: DesignTokens.pagePaddingFor(
              MediaQuery.sizeOf(context).width,
            ),
            children: [
              const BrandLogoSection(),
              const SizedBox(height: DesignTokens.spaceMd),
              for (final group in SettingRules.groups)
                if (SettingRules.inGroup(settings, group).isNotEmpty) ...[
                  SectionCard(
                    title: group,
                    child: Column(
                      children: [
                        for (final setting in SettingRules.inGroup(
                          settings,
                          group,
                        ))
                          SettingTile(
                            key: ValueKey(setting.key),
                            setting: setting,
                            onTap: canEdit
                                ? () => showDialog<void>(
                                    context: context,
                                    builder: (_) =>
                                        EditSettingDialog(setting: setting),
                                  )
                                : null,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceMd),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
