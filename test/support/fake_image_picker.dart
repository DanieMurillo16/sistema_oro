import 'dart:typed_data';

import 'package:sistema_oro/core/services/image_picker_service.dart';

/// Elige siempre la misma foto (o un problema) sin abrir ninguna galería.
class FakeImagePicker implements ImagePickerService {
  FakeImagePicker({this.result});

  PickResult? result;
  int picks = 0;

  static final sample = PickedImage(
    bytes: Uint8List.fromList([
      137,
      80,
      78,
      71,
      13,
      10,
      26,
      10,
      0,
      0,
      0,
      13,
      73,
      72,
      68,
      82,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      1,
      8,
      6,
      0,
      0,
      0,
      31,
      21,
      196,
      137,
      0,
      0,
      0,
      13,
      73,
      68,
      65,
      84,
      120,
      218,
      99,
      252,
      207,
      192,
      80,
      15,
      0,
      4,
      133,
      1,
      128,
      132,
      169,
      140,
      33,
      0,
      0,
      0,
      0,
      73,
      69,
      78,
      68,
      174,
      66,
      96,
      130,
    ]),
    name: 'comprobante.png',
  );

  @override
  Future<PickResult> pick({bool camera = false}) async {
    picks++;
    return result ?? PickResult(image: sample);
  }
}
