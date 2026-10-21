import 'package:dio/dio.dart';

import 'fake_api_adapter.dart';

/// Lectura de una petición multipart registrada por el adaptador falso.
extension FormRequest on RecordedRequest {
  FormData get form => body! as FormData;

  Map<String, String> get formFields => {
    for (final field in form.fields) field.key: field.value,
  };

  List<String> get formFileNames => [for (final f in form.files) f.key];
}
