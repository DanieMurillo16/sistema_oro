import 'package:flutter/material.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';

class ConfirmActionDialog extends StatelessWidget {
  const ConfirmActionDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirmar',
    this.cancelLabel = 'Cancelar',
    this.icon = Icons.warning_amber_rounded,
    this.destructive = true,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final IconData icon;

  /// En rojo para lo irreversible; en el color de marca para confirmar un paso normal.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final accent = destructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.secondary;
    return AppDialog(
      header: DialogHeader(
        icon: icon,
        title: title,
        subtitle: destructive
            ? 'Confirmación requerida'
            : 'Confirma para continuar',
        color: accent,
        onClose: () => Navigator.of(context).pop(false),
      ),
      content: Text(message),
      actions: DialogActions(
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmIcon: icon,
        destructive: destructive,
      ),
    );
  }
}
