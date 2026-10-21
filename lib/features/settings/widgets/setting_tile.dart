import 'package:flutter/material.dart';
import 'package:sistema_oro/features/settings/models/app_setting.dart';
import 'package:sistema_oro/features/settings/utils/setting_rules.dart';

/// Una fila de ajustes: nombre, valor actual y, si se puede, lápiz.
class SettingTile extends StatelessWidget {
  const SettingTile({super.key, required this.setting, this.onTap});

  final AppSetting setting;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: EdgeInsets.zero,
    title: Text(SettingRules.infoOf(setting).label),
    subtitle: Text(SettingRules.display(setting)),
    trailing: onTap == null ? null : const Icon(Icons.edit_outlined),
  );
}
