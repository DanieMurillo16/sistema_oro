import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Abre enlaces externos (WhatsApp). Se inyecta por provider para poder
/// sustituirlo en las pruebas.
final linkLauncherProvider = Provider<LinkLauncher>(
  (ref) => const LinkLauncher(),
);

class LinkLauncher {
  const LinkLauncher();

  /// Abre el chat de WhatsApp con [phone] (solo dígitos, con indicativo) y un
  /// mensaje opcional. Si la app de WhatsApp está instalada se abre directo en
  /// ella (`whatsapp://`); si no, se usa el enlace web `wa.me`. Devuelve
  /// `false` si no se pudo abrir.
  Future<bool> openWhatsApp(String phone, {String? message}) async {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final text = message != null && message.isNotEmpty ? message : null;
    final native = Uri(
      scheme: 'whatsapp',
      host: 'send',
      queryParameters: {'phone': digits, 'text': ?text},
    );
    if (await _canOpen(native)) {
      return launchUrl(native, mode: LaunchMode.externalApplication);
    }
    final web = Uri.https('wa.me', '/$digits', {'text': ?text});
    return launchUrl(web, mode: LaunchMode.externalApplication);
  }

  Future<bool> _canOpen(Uri uri) async {
    try {
      return await canLaunchUrl(uri);
    } on Object {
      return false;
    }
  }
}
