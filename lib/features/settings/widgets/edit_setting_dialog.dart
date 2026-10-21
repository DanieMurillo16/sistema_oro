import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/utils/cop_currency_input_formatter.dart';
import 'package:sistema_oro/features/settings/models/app_setting.dart';
import 'package:sistema_oro/features/settings/providers/settings_provider.dart';
import 'package:sistema_oro/features/settings/utils/setting_rules.dart';
import 'package:sistema_oro/shared/utils/listen_action.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';

/// Cambiar un ajuste. El campo se adapta al tipo: texto, número, pesos,
/// porcentaje o sí/no.
class EditSettingDialog extends ConsumerStatefulWidget {
  const EditSettingDialog({super.key, required this.setting});

  final AppSetting setting;

  @override
  ConsumerState<EditSettingDialog> createState() => _EditSettingDialogState();
}

class _EditSettingDialogState extends ConsumerState<EditSettingDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(
    text: SettingRules.initialInput(widget.setting),
  );
  late var _flag =
      widget.setting.value == 'true' || widget.setting.value == '1';

  AppSetting get _setting => widget.setting;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final input = _setting.kind == SettingKind.boolean
        ? '$_flag'
        : _controller.text;
    ref
        .read(settingActionsProvider.notifier)
        .save(_setting.key, SettingRules.toApi(_setting, input));
  }

  @override
  Widget build(BuildContext context) {
    listenAction(
      ref,
      settingActionsProvider,
      onSuccess: () => Navigator.of(context).pop(),
    );
    final info = SettingRules.infoOf(_setting);
    return AppDialog(
      header: DialogHeader(
        icon: Icons.tune,
        title: info.label,
        subtitle: info.group,
      ),
      content: Form(
        key: _formKey,
        child: _setting.kind == SettingKind.boolean
            ? SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(info.label),
                value: _flag,
                onChanged: (value) => setState(() => _flag = value),
              )
            : TextFormField(
                key: const Key('setting_value'),
                controller: _controller,
                maxLength: _setting.kind == SettingKind.text ? 500 : 12,
                keyboardType: _keyboard,
                inputFormatters: _formatters,
                decoration: InputDecoration(
                  labelText: info.label,
                  counterText: '',
                  prefixText: _setting.kind == SettingKind.money ? r'$ ' : null,
                  suffixText: _setting.kind == SettingKind.percent ? '%' : null,
                ),
                validator: (text) => SettingRules.validate(_setting, text),
              ),
      ),
      actions: DialogActions(
        onConfirm: _submit,
        isLoading: ref.watch(settingActionsProvider).isLoading,
        confirmLabel: 'Guardar ajuste',
      ),
    );
  }

  TextInputType get _keyboard => switch (_setting.kind) {
    SettingKind.text =>
      _setting.key == 'whatsapp_baron'
          ? TextInputType.phone
          : TextInputType.text,
    SettingKind.boolean => TextInputType.text,
    _ => TextInputType.number,
  };

  List<TextInputFormatter> get _formatters => switch (_setting.kind) {
    SettingKind.money => [
      FilteringTextInputFormatter.digitsOnly,
      const CopCurrencyInputFormatter(),
    ],
    SettingKind.integer ||
    SettingKind.percent => [FilteringTextInputFormatter.digitsOnly],
    _ =>
      _setting.key == 'whatsapp_baron'
          ? [FilteringTextInputFormatter.digitsOnly]
          : const [],
  };
}
