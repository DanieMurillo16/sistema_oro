import 'package:sistema_oro/core/services/link_launcher.dart';

/// Anota los enlaces que la app intentó abrir, sin abrir nada.
class FakeLinkLauncher implements LinkLauncher {
  final whatsappCalls = <({String phone, String? message})>[];

  @override
  Future<bool> openWhatsApp(String phone, {String? message}) async {
    whatsappCalls.add((phone: phone, message: message));
    return true;
  }
}
