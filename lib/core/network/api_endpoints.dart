/// Todas las rutas de la API como constantes (relativas a la URL base). Reflejan
/// las filas de backend/docs/API.md; cero URLs literales en repositorios.
abstract final class ApiEndpoints {
  // Base y sesión
  static const health = 'health.php';
  static const login = 'auth/login.php';
  static const profile = 'auth/perfil.php';
  static const logout = 'auth/logout.php';

  // Catálogo público (sin token)
  static const publicTypes = 'publico/tipos.php';
  static const publicSettings = 'publico/ajustes.php';
  static const publicGarments = 'publico/prendas.php';

  /// Contador de versión del catálogo (sondeo barato: pedir el listado solo
  /// cuando cambie). Lo consume el catálogo en Astro; aquí queda reflejado.
  static const publicVersion = 'publico/version.php';
  static const publicGarment = 'publico/prenda.php';
  static const publicRequest = 'publico/solicitud.php';

  // Tipos de prenda
  static const typesList = 'tipos/listar.php';
  static const typesSave = 'tipos/guardar.php';

  // Prendas
  static const garmentsList = 'prendas/listar.php';
  static const garmentsGet = 'prendas/obtener.php';
  static const garmentsCreate = 'prendas/crear.php';
  static const garmentsEdit = 'prendas/editar.php';
  static const garmentsDelete = 'prendas/eliminar.php';
  static const garmentsAdjustStock = 'prendas/ajustar_stock.php';
  static const garmentsImageAdd = 'prendas/imagen_agregar.php';
  static const garmentsImageRemove = 'prendas/imagen_quitar.php';

  // Ajustes
  static const settingsList = 'ajustes/listar.php';
  static const settingsSave = 'ajustes/guardar.php';
  static const settingsLogo = 'ajustes/logo_ver.php';
  static const settingsLogoUpload = 'ajustes/logo_subir.php';
  static const settingsLogoRestore = 'ajustes/logo_restaurar.php';
  static const summary = 'resumen/obtener.php';

  // Pedidos
  static const ordersCounters = 'pedidos/contadores.php';
  static const ordersList = 'pedidos/listar.php';
  static const ordersGet = 'pedidos/obtener.php';
  static const ordersReceipt = 'pedidos/comprobante.php';
  static const ordersConfirm = 'pedidos/confirmar.php';
  static const ordersReject = 'pedidos/rechazar.php';
  static const ordersCancel = 'pedidos/cancelar.php';
  static const ordersEditDelivery = 'pedidos/editar_entrega.php';
  static const ordersShip = 'pedidos/enviar.php';
  static const ordersDeliver = 'pedidos/entregar.php';

  // Pagos
  static const paymentsRegister = 'pagos/registrar.php';
  static const paymentsVoid = 'pagos/anular.php';

  // Clientes
  static const clientsList = 'clientes/listar.php';
  static const clientsGet = 'clientes/obtener.php';
  static const clientsEdit = 'clientes/editar.php';

  // Usuarios
  static const usersRoles = 'usuarios/roles.php';
  static const usersList = 'usuarios/listar.php';
  static const usersCreate = 'usuarios/crear.php';
  static const usersEdit = 'usuarios/editar.php';
  static const usersChangePassword = 'usuarios/cambiar_clave.php';
}
