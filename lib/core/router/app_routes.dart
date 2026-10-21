/// Todas las rutas como constantes, en un solo lugar.
abstract final class AppRoutes {
  // Arranque y sesión
  static const splash = '/';
  static const login = '/login';

  // Administración (dentro del menú)
  static const summary = '/resumen';
  static const orders = '/pedidos';
  static const orderPattern = '/pedidos/:id';

  /// [from] = pantalla a la que vuelve la flecha «atrás» (p. ej. la ficha de un
  /// cliente); sin él vuelve a la lista de pedidos.
  static String order(int id, {String? from}) => '/pedidos/$id${_from(from)}';
  static const layaways = '/separados';
  static const layawayPattern = '/separados/:id';
  static String layaway(int id, {String? from}) =>
      '/separados/$id${_from(from)}';
  static const garments = '/prendas';
  static const garmentPattern = '/prendas/:id';
  static String garment(int id) => '/prendas/$id';
  static const clients = '/clientes';
  static const clientPattern = '/clientes/:id';
  static String client(int id) => '/clientes/$id';
  static const more = '/mas';
  static const settings = '/ajustes';
  static const users = '/usuarios';

  static String _from(String? from) =>
      from == null ? '' : '?from=${Uri.encodeQueryComponent(from)}';

  // Catálogo público (otro router; su raíz es '/')
  static const catalog = '/';

  /// Hija de la raíz: abrir el enlace directo deja el catálogo debajo.
  static const catalogGarmentPattern = 'prenda/:id';
  static String catalogGarment(int id) => '/prenda/$id';
}
