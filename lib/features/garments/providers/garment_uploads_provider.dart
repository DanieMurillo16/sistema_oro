import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/core/services/image_picker_service.dart';
import 'package:sistema_oro/features/auth/providers/session_provider.dart';
import 'package:sistema_oro/features/garments/data/garments_repository.dart';
import 'package:sistema_oro/features/garments/models/photo_upload.dart';
import 'package:sistema_oro/features/garments/providers/garment_sync.dart';

/// Las fotos de las prendas recién creadas que aún suben en segundo plano
/// (por prenda). La prenda ya existe y se ve en la lista; las fotos llegan
/// después: la primera sola (con ella ya hay miniatura en el catálogo) y las
/// demás de a [_parallel] a la vez, con reintentos. Las que no se pudieron
/// subir quedan `failed` hasta que se pulse «Reintentar».
final garmentUploadsProvider =
    NotifierProvider<GarmentUploadsNotifier, Map<int, List<PhotoUpload>>>(
      GarmentUploadsNotifier.new,
    );

class GarmentUploadsNotifier extends Notifier<Map<int, List<PhotoUpload>>> {
  static const _parallel = 2;
  static const _attempts = 3;

  final _running = <int>{};

  GarmentsRepository get _repository => ref.read(garmentsRepositoryProvider);

  @override
  Map<int, List<PhotoUpload>> build() {
    ref.watch(sessionUserIdProvider); // otra cuenta: nada de lo anterior
    return const {};
  }

  /// Empieza a subir [photos] a la prenda [garmentId] sin esperar.
  void start(int garmentId, List<PickedImage> photos) {
    if (photos.isEmpty) return;
    state = {
      ...state,
      garmentId: [
        for (var i = 0; i < photos.length; i++)
          PhotoUpload(order: i + 1, image: photos[i]),
      ],
    };
    unawaited(_process(garmentId));
  }

  /// Vuelve a intentar las fotos que fallaron de [garmentId].
  void retry(int garmentId) {
    _update(garmentId, (u) {
      return u.status == UploadStatus.failed
          ? u.withStatus(UploadStatus.queued)
          : u;
    });
    unawaited(_process(garmentId));
  }

  Future<void> _process(int id) async {
    if (!_running.add(id)) return;
    try {
      // La primera, sola: apenas llega, la prenda tiene miniatura.
      var queue = _queued(id);
      if (queue.isNotEmpty && !_anyDone(id)) {
        await _uploadOne(id, queue.first);
        if (!ref.mounted) return;
        await syncGarment(ref, id);
      }
      while (ref.mounted && (queue = _queued(id)).isNotEmpty) {
        await Future.wait([
          for (final upload in queue.take(_parallel)) _uploadOne(id, upload),
        ]);
      }
      if (!ref.mounted) return;
      await syncGarment(ref, id);
      final left = state[id] ?? const [];
      if (left.every((u) => u.status == UploadStatus.done)) {
        state = {...state}..remove(id);
      }
    } finally {
      _running.remove(id);
    }
  }

  Future<void> _uploadOne(int id, PhotoUpload upload) async {
    _set(id, upload.order, UploadStatus.uploading);
    for (var attempt = 1; attempt <= _attempts; attempt++) {
      try {
        await _repository.addImage(
          id,
          order: upload.order,
          image: upload.image,
        );
        if (ref.mounted) _set(id, upload.order, UploadStatus.done);
        return;
      } on AppException {
        if (!ref.mounted) return;
        if (attempt < _attempts) {
          await Future<void>.delayed(Duration(seconds: attempt));
        }
      }
    }
    if (ref.mounted) _set(id, upload.order, UploadStatus.failed);
  }

  List<PhotoUpload> _queued(int id) => [
    for (final u in state[id] ?? const <PhotoUpload>[])
      if (u.status == UploadStatus.queued) u,
  ];

  bool _anyDone(int id) =>
      (state[id] ?? const []).any((u) => u.status == UploadStatus.done);

  void _set(int id, int order, UploadStatus status) =>
      _update(id, (u) => u.order == order ? u.withStatus(status) : u);

  void _update(int id, PhotoUpload Function(PhotoUpload) change) {
    final current = state[id];
    if (current == null) return;
    state = {
      ...state,
      id: [for (final u in current) change(u)],
    };
  }
}
