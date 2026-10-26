import 'package:sistema_oro/core/services/image_picker_service.dart';

/// En qué va la subida de una foto en segundo plano.
enum UploadStatus { queued, uploading, done, failed }

/// Una foto que se está subiendo a una prenda recién creada: la imagen local
/// sirve de vista previa mientras llega al servidor.
class PhotoUpload {
  const PhotoUpload({
    required this.order,
    required this.image,
    this.status = UploadStatus.queued,
  });

  final int order;
  final PickedImage image;
  final UploadStatus status;

  PhotoUpload withStatus(UploadStatus next) =>
      PhotoUpload(order: order, image: image, status: next);
}
