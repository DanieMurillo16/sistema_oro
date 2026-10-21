import 'package:flutter_riverpod/flutter_riverpod.dart';

/// La hora de «ahora», inyectable para que las pruebas no dependan del día
/// en que corren.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
