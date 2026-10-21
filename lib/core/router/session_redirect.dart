import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/router/app_routes.dart';
import 'package:sistema_oro/features/auth/models/app_session.dart';

/// A dónde mandar según la sesión (`null` = quedarse donde está):
/// recuperándola → splash; sin sesión → login; con sesión no se queda en el
/// splash ni en el login.
String? sessionRedirect({
  required AsyncValue<AppSession?> session,
  required String location,
  required String homePath,
}) {
  final recovering =
      session.isLoading || (session.hasError && !session.hasValue);
  if (recovering) return location == AppRoutes.splash ? null : AppRoutes.splash;
  final user = session.value;
  if (user == null) return location == AppRoutes.login ? null : AppRoutes.login;
  final onEntry = location == AppRoutes.splash || location == AppRoutes.login;
  return onEntry ? homePath : null;
}
