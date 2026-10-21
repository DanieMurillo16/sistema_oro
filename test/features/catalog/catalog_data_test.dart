import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_oro/core/network/api_endpoints.dart';
import 'package:sistema_oro/features/catalog/data/catalog_repository.dart';
import 'package:sistema_oro/features/catalog/models/catalog_models.dart';

import '../../helpers/catalog_fixtures.dart';

void main() {
  group('CatalogGarment.fromJson · miniatura', () {
    Map<String, dynamic> row({Object? own, List<Object?>? images}) {
      final json = publicGarment()..remove('miniatura');
      if (own != null) json['miniatura'] = own;
      if (images != null) json['imagenes'] = images;
      return json;
    }

    Map<String, Object> image(String thumb) => {
      'orden': 1,
      'url_miniatura': thumb,
      'url_grande': 'https://x.test/g.jpg',
    };

    test('propia > primera foto > null (URL vacía o sin fotos)', () {
      final cases = <String, ({Map<String, dynamic> json, String? expected})>{
        'propia gana a las fotos': (
          json: row(
            own: 'https://x.test/own.jpg',
            images: [image('https://x.test/m1.jpg')],
          ),
          expected: 'https://x.test/own.jpg',
        ),
        'sin propia: primera foto': (
          json: row(
            images: [
              image('https://x.test/m1.jpg'),
              image('https://x.test/m2.jpg'),
            ],
          ),
          expected: 'https://x.test/m1.jpg',
        ),
        'primera foto con URL vacía': (
          json: row(images: [image('')]),
          expected: null,
        ),
        'sin propia ni fotos': (json: row(), expected: null),
      };
      cases.forEach((name, c) {
        expect(
          CatalogGarment.fromJson(c.json).thumbnail,
          c.expected,
          reason: name,
        );
      });
    });
  });

  group('CatalogRepository.garments', () {
    test('pide solo los filtros del contrato y no manda «buscar»', () async {
      final server = CatalogServer();
      final repo = CatalogRepository(server.harness.api);

      await repo.garments(typeId: 2, sort: 'RECIENTES', offset: 24);
      await repo.garments(sort: 'PRECIO_ASC');

      final requests = server.harness.adapter.to(ApiEndpoints.publicGarments);
      expect(requests[0].query, {
        'tipo': 2,
        'orden': 'RECIENTES',
        'limite': CatalogRepository.pageSize,
        'desplazamiento': 24,
      });
      // Sin tipo, la llave tampoco viaja.
      expect(requests[1].query.keys, isNot(contains('tipo')));
      expect(requests[1].query.keys, isNot(contains('buscar')));
    });
  });
}
