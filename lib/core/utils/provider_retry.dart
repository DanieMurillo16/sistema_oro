/// Riverpod 3 reintenta solo los providers que fallan; aquí no: el error se
/// muestra con «Intentar nuevamente» (`AppErrorView`) y la persona decide.
Duration? noProviderRetry(int retryCount, Object error) => null;
