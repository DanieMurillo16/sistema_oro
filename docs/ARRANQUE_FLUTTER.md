# Mensaje de arranque — chat Flutter de Sistema Oro (sesión NUEVA abierta en esta carpeta)

Todo este archivo es el primer mensaje del chat Flutter: se copia entero y se pega (más las capturas de la referencia visual, si las hay).

---

Eres el chat Flutter de «Sistema Oro» (joyería en oro de Barón). Usa mi base (flutter-new-project, flutter-feature, flutter-ui, flutter-testing). Lee primero CLAUDE.md, docs/ESTADO.md, docs/NEGOCIO.md y docs/DISENO_REFERENCIAS.md.

BACKEND (./backend; servidor `public_html/bd_oro/`, URL base `https://cobros.com.co/bd_oro/`)
- Contrato único: **backend/docs/API.md** (41 rutas, con permisos, errores y formas de respuesta). Qué hay y qué falta: backend/docs/REGISTRO.md («Pendiente para Flutter»). No leas ni asumas el esquema de la BD ni edites backend/ a mano.
- **Estado real:** el SQL (001 y 002) y la API PHP (entrega **003**) están **instalados y confirmados** en `https://cobros.com.co/bd_oro/` (probé health, ajustes y tipos públicos; la API tiene 234 comprobaciones HTTP + 241 de BD en local). **Por probar contra el servidor real con la app:** login, subida de imágenes de prendas y de comprobantes (depende de GD y del límite de subida de Hostinger). Si algo de eso falla, me lo dices y lo resolvemos con el backend.
- Si falta un dato, un campo, un filtro o un endpoint: no lo inventes. Junta el pedido (pantalla, datos que entran y salen, filtros, reglas) y llama al subagente backend-builder con la ruta ./backend. Puedes juntar varios pedidos en una sola llamada. Te devuelve el contrato exacto y un paquete en backend/entregas/NNN_*/; yo lo subo y te confirmo. Si te devuelve preguntas de negocio, me las haces a mí.

MODELO
- **Una sola empresa (Barón).** Dos piezas con los mismos datos: **administración** (iOS/Android/web, oscura, con login por token) y **catálogo público** (Flutter web, sin login, claro y elegante, UN solo enlace general).
- **Prenda** (nombre, tipo editable, peso, largo/ancho/grosor opcionales, oro NACIONAL/ITALIANO, precio de venta, `precio_anterior` para SALE, **precio de compra PRIVADO**, hasta 6 imágenes, referencia, descripción, **stock**). Etiquetas derivadas que ya vienen en la respuesta: `es_nueva`, `en_oferta`, `ultima_unidad`, `agotada`.
- **Solicitud → pedido.** Toda compra o separado del catálogo entra PENDIENTE con comprobante y reserva una unidad; Barón confirma o rechaza. Compra: PENDIENTE→CONFIRMADO→(ENVIADO)→ENTREGADO. Separado: PENDIENTE→ACTIVO→PAGADO→(ENVIADO)→ENTREGADO. También RECHAZADO y CANCELADO (con decisión sobre lo abonado).
- **Roles:** ADMINISTRADOR (dueño: todo) y EMPLEADO (ver pedidos y clientes, registrar abonos; **sin** precio de compra, sin confirmar/rechazar/entregar/cancelar/anular, sin usuarios). La app lee `permisos` del login y oculta lo que no corresponde (el servidor igual lo impide).
- **Histórico, no se borra:** pagos (solo se anulan), historial de stock, cancelaciones, pedidos. Los valores del pedido (precio, caja, 20 %, recargo) son una foto del momento.

PANTALLAS (todo sale de API.md; rutas relativas a la URL base)
Catálogo público (`lib/main_catalogo.dart`, sin login):
- Inicio/listado con filtro por tipo, búsqueda, orden y contador → `publico/prendas.php`, `publico/tipos.php`
- Detalle de prenda (galería, medidas, «Separar con el 20 %» = `valor_separado` ya calculado) → `publico/prenda.php`
- Comprar o separar (caja gratis/decorada, entrega recoge/envío, datos de transferencia, nombre y WhatsApp, subir comprobante) → `publico/ajustes.php`, `POST publico/solicitud.php` (multipart)
- «Te la conseguimos» y botón flotante de WhatsApp (número = ajuste `whatsapp_baron`) → `publico/ajustes.php`
Administración (`lib/main.dart`, con login):
- Login / sesión → `auth/login.php`, `auth/perfil.php`, `auth/logout.php`
- Pedidos y solicitudes (insignia de pendientes, lista, detalle con comprobante, confirmar/rechazar/cancelar/enviar/entregar, editar entrega) → `pedidos/contadores.php`, `pedidos/listar.php`, `pedidos/obtener.php`, `pedidos/comprobante.php`, `pedidos/confirmar.php`, `pedidos/rechazar.php`, `pedidos/cancelar.php`, `pedidos/enviar.php`, `pedidos/entregar.php`, `pedidos/editar_entrega.php`
- Separados y abonos (saldo, fecha límite, meses vencidos; registrar abono con comprobante; anular) → `pagos/registrar.php`, `pagos/anular.php` (y el detalle de `pedidos/obtener.php`)
- Prendas (lista, crear/editar, stock, imágenes, tipos) → `prendas/listar.php`, `prendas/obtener.php`, `prendas/crear.php`, `prendas/editar.php`, `prendas/ajustar_stock.php`, `prendas/imagen_agregar.php`, `prendas/imagen_quitar.php`, `tipos/listar.php`, `tipos/guardar.php`
- Clientes (ficha con sus pedidos y separados) → `clientes/listar.php`, `clientes/obtener.php`, `clientes/editar.php`
- Ajustes (WhatsApp, datos de transferencia, %, recargo, caja) → `ajustes/listar.php`, `ajustes/guardar.php`
- Usuarios (solo dueño) → `usuarios/roles.php`, `usuarios/listar.php`, `usuarios/crear.php`, `usuarios/editar.php`, `usuarios/cambiar_clave.php`

DIRECCIÓN VISUAL
Ver docs/DISENO_REFERENCIAS.md (Cuentas Claras para el admin oscuro; Paula Mendoza/Élite/Turco para el catálogo claro, cuadrícula de 4, etiquetas, animaciones mínimas). Color de marca dorado `#8A6A2F`; Inter (cuerpo) + Plus Jakarta Sans (títulos), ya empaquetadas. Antes de la primera pantalla: tokens y `AppTheme.dark` del admin, splash, y `lib/main_catalogo.dart` (ver docs/ESTADO.md). *(Hueco para el dueño: si tienes capturas o cambios de dirección visual, pégalos junto a este mensaje.)*

REGLAS QUE NO SE NEGOCIAN
- **La app no calcula dinero.** `total_a_pagar`, `saldo`, `recargos`, `meses_vencidos`, `fecha_limite`, `valor_separado` y `monto_separado_minimo` vienen del servidor; solo se formatean con los formateadores de `core/utils`. Dinero y decimales viajan como **texto con 2 decimales** (`"1000000.00"`), nunca `double` ni números JSON con decimales al enviar.
- **El precio de compra es privado**: no existe en ningún modelo del catálogo; en el admin viene `null` sin `prendas.ver_costo` y la UI lo oculta.
- Identidad por token: nunca se envía un id de usuario. Un 401 con token cierra la sesión local.
- Lo que no se borra se **anula** (pagos) o se **cancela con decisión** (pedidos); confirmación en rojo para lo irreversible.
- **Solicitud del catálogo:** genera un UUID v4 (`clave_envio`) al abrir el formulario y reutilízalo si reintenta; deja el campo oculto `sitio_web` vacío; al público solo se le muestra el `codigo` (8 caracteres). Errores con mensaje listo en español: `NO_DISPONIBLE` («ya no está disponible»; refresca la prenda), `DEMASIADAS_PENDIENTES`, `DEMASIADOS_INTENTOS`, `VALIDACION`.
- **Archivos:** multipart con Dio `FormData`. Reduce la foto antes de subirla (máx. 4 MB y 16 millones de píxeles; JPG/PNG/WebP). El comprobante se ve descargando `pedidos/comprobante.php?archivo=…` **con el Bearer** (bytes → `Image.memory`); las imágenes de prendas son URL públicas absolutas (miniatura en la cuadrícula, grande en el detalle).
- **Un dato vive en un solo provider** (`upsert`/`invalidate`): crear/editar/anular actualiza las demás vistas sin recargar; refrescar conserva lo que se ve (`motion.md`).
- Paquetes: **no agregues ninguno sin preguntarme.** Pendientes por aprobar en docs/ESTADO.md: `image_picker` (fotos y comprobante) y `url_launcher` (abrir WhatsApp). El UUID se genera con `dart:math` (`Random.secure`), sin paquete.
- CORS: el servidor solo acepta los orígenes listados en su configuración; el dominio del catálogo y el de la administración web hay que registrarlos cuando existan (te aviso).
- Cada pantalla resuelve datos / cargando / error / vacío.

HAZ ESTO
1. Plan de 5 a 10 líneas (features, orden, dudas de diseño y qué pedirías al backend) y espera mi visto bueno. Sugerencia de orden: tema oscuro + splash + login/sesión → pedidos (el corazón: confirmar/rechazar con comprobante) → separados y abonos → prendas e imágenes → clientes → ajustes y usuarios → catálogo público (`main_catalogo.dart`, comprar/separar).
2. Una feature por vez, con ApiEndpoints sincronizado: python3 -I ~/.claude/flutter-base/tools/api_sync_check.py backend/docs/API.md lib/core/network/api_endpoints.dart backend
3. Pruebas por vista: una prueba de FLUJO con red falsa (qué se envía —cuerpo exacto según API.md— y qué se muestra) + desbordes según el tamaño del cambio; nada de pruebas por cobertura. Al cerrar cada feature: ui_audit.sh + flutter-ui-reviewer + flutter-tester, y dime el resultado real y lo que no se pudo verificar.
4. Al terminar, un solo bloque final con lo que debo subir (SQL, PHP, en qué orden) y qué entregas están instaladas o pendientes.
