import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/shared/utils/validators.dart';
import 'package:sistema_oro/shared/widgets/app_dialog.dart';
import 'package:sistema_oro/shared/widgets/dialog_actions.dart';
import 'package:sistema_oro/shared/widgets/dialog_header.dart';

/// Cuánto se pide de motivo en una confirmación.
enum ConfirmReason { none, optional, required }

/// Lo que devuelve una confirmación aceptada: el motivo escrito (si se pidió).
class ConfirmResult {
  const ConfirmResult({this.reason});

  final String? reason;
}

/// El diálogo de confirmación de la app (se abre con `confirmDestructive`, no
/// directamente). «Cancelar» a la izquierda y el botón con la acción concreta a
/// la derecha (en rojo si es destructivo). El nombre de lo que se va a tocar va
/// en negrita y la consecuencia en una frase. Tocar fuera o «atrás» cancela.
class ConfirmActionDialog extends StatefulWidget {
  const ConfirmActionDialog({
    super.key,
    required this.title,
    required this.message,
    this.itemName,
    this.confirmLabel = 'Confirmar',
    this.cancelLabel = 'Cancelar',
    this.icon = Icons.warning_amber_rounded,
    this.destructive = true,
    this.reason = ConfirmReason.none,
  });

  final String title;
  final String message;

  /// El nombre de lo que se toca (la prenda, la persona), en negrita.
  final String? itemName;
  final String confirmLabel;
  final String cancelLabel;
  final IconData icon;

  /// En rojo para lo irreversible; en el color de marca para confirmar un paso normal.
  final bool destructive;
  final ConfirmReason reason;

  @override
  State<ConfirmActionDialog> createState() => _ConfirmActionDialogState();
}

class _ConfirmActionDialogState extends State<ConfirmActionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController(); // estado efímero del campo
  var _answered = false; // anti doble toque: un solo cierre

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_answered || !_formKey.currentState!.validate()) return;
    _answered = true;
    final text = _reason.text.trim();
    Navigator.of(context).pop(
      widget.reason == ConfirmReason.none
          ? const ConfirmResult()
          : ConfirmResult(reason: text.isEmpty ? null : text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = widget.destructive ? scheme.error : scheme.secondary;
    return AppDialog(
      header: DialogHeader(
        icon: widget.icon,
        title: widget.title,
        subtitle: widget.destructive
            ? 'Confirmación requerida'
            : 'Confirma para continuar',
        color: accent,
        onClose: () => Navigator.of(context).pop(),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.itemName != null) ...[
              Text(widget.itemName!, style: textTheme.titleSmall),
              const SizedBox(height: DesignTokens.spaceXs),
            ],
            Text(widget.message),
            if (widget.reason != ConfirmReason.none) ...[
              const SizedBox(height: DesignTokens.spaceMd),
              TextFormField(
                key: const Key('confirm_reason'),
                controller: _reason,
                maxLength: 200,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: widget.reason == ConfirmReason.required
                      ? 'Motivo'
                      : 'Motivo (opcional)',
                  counterText: '',
                ),
                validator: widget.reason == ConfirmReason.required
                    ? Validators.reason
                    : null,
              ),
            ],
          ],
        ),
      ),
      actions: DialogActions(
        onConfirm: _confirm,
        onCancel: () => Navigator.of(context).pop(),
        confirmLabel: widget.confirmLabel,
        cancelLabel: widget.cancelLabel,
        confirmIcon: widget.icon,
        destructive: widget.destructive,
      ),
    );
  }
}
