import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/features/garments/models/garment.dart';

import '../../helpers/garment_fixtures.dart';

void main() {
  test('el detalle (sin `miniatura`) usa la primera foto: la fila no pierde su imagen', () {
    // `prendas/obtener.php` devuelve `imagenes` pero no `miniatura`; si el
    // modelo solo mirara `miniatura`, al actualizar la lista con el detalle la
    // prenda recién creada mostraba el ícono de joya en vez de su foto.
    final json = garmentRow()
      ..remove('miniatura')
      ..['imagenes'] = [
        {
          'id_imagen': 1,
          'orden': 1,
          'url_miniatura': 'https://x.test/m1.jpg',
          'url_grande': 'https://x.test/g1.jpg',
        },
        {
          'id_imagen': 2,
          'orden': 2,
          'url_miniatura': 'https://x.test/m2.jpg',
          'url_grande': 'https://x.test/g2.jpg',
        },
      ];
    expect(Garment.fromJson(json).thumbnail, 'https://x.test/m1.jpg');
  });

  test(
    'con `miniatura` del listado se respeta; sin ninguna foto queda en null',
    () {
      expect(
        Garment.fromJson(garmentRow()..['miniatura'] = 'https://x.test/l.jpg')
            .thumbnail,
        'https://x.test/l.jpg',
      );
      expect(Garment.fromJson(garmentRow()).thumbnail, isNull);
    },
  );
}
