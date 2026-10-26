import 'package:flutter/material.dart';
import 'package:sistema_oro/shared/widgets/confirm_action_dialog.dart';

/// **La única forma de pedir confirmación** antes de algo destructivo o
/// irreversible (eliminar, quitar, restaurar, cerrar sesión, desactivar…).
/// Devuelve `null` si la persona cancela (botón «Cancelar», la ✕, tocar fuera o
/// «atrás») y el [ConfirmResult] (con el motivo, si se pidió) si confirma.
///
/// Quien la use solo dispara la acción cuando la respuesta NO es `null`: la
/// eliminación optimista, la petición y el aviso ocurren DESPUÉS. Un test de
/// arquitectura (`test/core/confirmacion_destructiva_test.dart`) falla si una
/// vista llama a una acción destructiva sin pasar por aquí o por un diálogo
/// propio de `widgets/dialogs/`.
Future<ConfirmResult?> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? itemName,
  IconData icon = Icons.delete_outline,
  ConfirmReason reason = ConfirmReason.none,
  bool destructive = true,
}) => showDialog<ConfirmResult>(
  context: context,
  builder: (_) => ConfirmActionDialog(
    title: title,
    message: message,
    itemName: itemName,
    confirmLabel: confirmLabel,
    icon: icon,
    reason: reason,
    destructive: destructive,
  ),
);
