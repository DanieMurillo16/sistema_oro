import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Una foto elegida: bytes ya reducidos y un nombre con extensión.
class PickedImage {
  const PickedImage({required this.bytes, required this.name});

  final Uint8List bytes;
  final String name;

  /// Tipo para el envío multipart (el servidor valida el contenido real).
  String get mimeType {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}

/// Resultado de elegir: la imagen, o el motivo por el que no sirve. `null` en
/// los dos = la persona canceló.
class PickResult {
  const PickResult({this.image, this.problem});

  final PickedImage? image;
  final String? problem;
}

/// Elige fotos de la galería o la cámara y las reduce antes de subirlas (el
/// servidor acepta máx. 4 MB y 16 millones de píxeles). Se inyecta por provider
/// para sustituirlo en las pruebas.
final imagePickerServiceProvider = Provider<ImagePickerService>(
  (ref) => ImagePickerService(),
);

class ImagePickerService {
  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const maxBytes = 4 * 1024 * 1024;
  static const _maxSide = 1600.0;
  static const _quality = 85;

  Future<PickResult> pick({bool camera = false}) async {
    final file = await _picker.pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: _maxSide,
      maxHeight: _maxSide,
      imageQuality: _quality,
    );
    if (file == null) return const PickResult();
    final bytes = await file.readAsBytes();
    if (bytes.length > maxBytes) {
      return const PickResult(
        problem: 'La imagen pesa más de 4 MB. Elige una más liviana.',
      );
    }
    return PickResult(
      image: PickedImage(bytes: bytes, name: _nameOf(file)),
    );
  }

  String _nameOf(XFile file) {
    final name = file.name.isEmpty ? 'foto.jpg' : file.name;
    return name.contains('.') ? name : '$name.jpg';
  }
}
