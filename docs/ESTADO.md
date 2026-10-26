# Estado — Sistema Oro

Actualizado: 2026-10-19 · **BD (002) y API PHP (entrega 003) instaladas y confirmadas por el dueño.** **App Flutter escrita completa (admin + catálogo público)**; falta probarla contra el servidor real y en teléfono (ver `docs/PROGRESO_FLUTTER.md`).

## Dónde vamos

> **Avance del chat Flutter, paso a paso: [`docs/PROGRESO_FLUTTER.md`](PROGRESO_FLUTTER.md)** (léelo primero si abres un chat nuevo).

- Starter aplicado (tema, componentes compartidos, Dio central, pruebas, build web): `flutter analyze` sin
  problemas y `flutter test` en verde (14 pruebas) tras aplicarlo.
- Fuentes empaquetadas: Inter (cuerpo) + Plus Jakarta Sans (títulos, descargada de su repo oficial, licencia OFL).
- Color de marca `#8A6A2F`. `web/index.html` con título, descripción e imagen de vista previa para WhatsApp.
- `backend/` base creado (login, perfil, logout, health; 23 comprobaciones de integración OK en local; entrega 001
  SQL instalado en el servidor el 2026-10-19; el PHP de login está subido, `health.php` sin confirmar).
- **BD diseñada:** `backend/docs/BD.md` (11 tablas nuevas, vista de finanzas, 38 procedimientos, permisos). `backend/pruebas/bd_oro.py`:
  241 comprobaciones OK (incluye concurrencia, el ejemplo de $580.000 y que el precio de compra no sale en lo público).
  **001 y 002 instaladas en el servidor (confirmado 2026-10-19).**
- **API PHP (entrega 003):** 36 endpoints nuevos (catálogo público aparte de la administración, subida de imágenes y comprobantes).
  `backend/pruebas/api_oro.py`: 234 comprobaciones HTTP OK. **Instalada y confirmada** (health, ajustes/tipos públicos, 403 de `core/`); falta probar login e imágenes con la app.
- **Paso 0 del chat Flutter hecho (2026-10-19):** `AppTheme.dark` (+ `AppDarkColors`, paleta oscura con acento dorado champán), splash
  (`features/splash`, `BrandMark`, `AppPageDots`), `lib/main_catalogo.dart` con su router (`catalog_router.dart`, pantalla marcador),
  `web/index.html` oscuro (admin, `noindex`) y `web_catalogo/index.html` (marfil + vista previa de WhatsApp),
  `scripts/build_catalogo.sh` (verificado: compila a `build/catalogo`). `image_picker` y `url_launcher` agregados (aprobados).
  `flutter analyze` limpio, `flutter test` 22 en verde. Sigue: login y sesión.
- `lib/features/home/` es una pantalla de ejemplo del starter y `test/shared/layout_test.dart` la usa: se borra (y el test se reduce a los
  componentes compartidos) al crear la primera feature real, el login.

## Siguiente (cada paso es un chat distinto en esta carpeta)

1. Chat BD y PHP: **hechos e instalados** (contrato en `backend/docs/API.md`, 41 rutas, `https://cobros.com.co/bd_oro/`). Falta probar con la app el login y
   la subida de imágenes (GD y `upload_max_filesize` ≥ 6 MB en el hosting).
2. **Chat Flutter** (primer mensaje: `docs/ARRANQUE_FLUTTER.md`): en curso. Hecho el paso 0 (tema oscuro, splash, entrada del catálogo);
   siguiente: login/sesión → pedidos → separados → prendas → clientes → ajustes/usuarios → catálogo.

## Decisiones tomadas

- 19/oct/2026 · Catálogo en **Flutter web, mismo código** (como Turco); un **solo enlace general**, no uno por prenda.
- 19/oct/2026 · Reglas del separado (20 %, abonos libres, plazo de 1 mes, +$80.000 por mes vencido, no se entrega
  hasta pagar todo, sale del catálogo, Barón puede cancelar y la prenda se republica): ver `docs/NEGOCIO.md`.
- 19/oct/2026 · **Cancelar un separado: lo abonado lo decide Barón caso por caso** (se queda / se devuelve / parcial),
  y la decisión queda registrada con motivo, montos, quién y cuándo.
- 19/oct/2026 · **Ejemplo de separado confirmado** ($1.000.000 → $200.000 / $800.000 → $580.000).
- 19/oct/2026 · **Prendas con cantidad** (hoy 1, puede crecer): `stock` por prenda.
- 19/oct/2026 · **WhatsApp de Barón y datos de transferencia = ajustes editables en la app** (no en el código).
- 19/oct/2026 · Referencia Turco recibida: ver `docs/DISENO_REFERENCIAS.md`.
- 19/oct/2026 · Color de marca dorado envejecido `#8A6A2F` (contraste ≈ 5:1 con blanco).
- 19/oct/2026 · Dos fuentes, **empaquetadas** (no `google_fonts` en ejecución; lo pidió el dueño en el chat y se
  resolvió sin el paquete para evitar el parpadeo de arranque): Inter cuerpo/precios, Plus Jakarta Sans títulos.
  La base solo define una familia; es **candidata a entrar en `flutter-base`**.
- 19/oct/2026 · API en `https://cobros.com.co/bd_oro/` y BD `u668681301_oro` (el sitio de Hostinger del dueño). Sigue pendiente el dominio propio del **catálogo** (`TU-DOMINIO/catalogo/` en `web/index.html`).

- 19/oct/2026 · **Una sola empresa; roles dueño (`ADMINISTRADOR`) y `EMPLEADO`**; permisos `modulo.accion` (`backend/docs/BD.md` §6).
- 19/oct/2026 · **Toda compra/separado del catálogo entra PENDIENTE** y reserva la unidad; Barón confirma o rechaza. Estados:
  compra PENDIENTE→CONFIRMADO→(ENVIADO)→ENTREGADO; separado PENDIENTE→ACTIVO→PAGADO→(ENVIADO)→ENTREGADO.
- 19/oct/2026 · **Medidas** = largo/ancho/grosor opcionales; **SALE** por `precio_anterior`; **NUEVO** automático (30 días, ajustable).
- 19/oct/2026 · El mes del separado corre desde que Barón **confirma**; la caja decorada va al total pero no al 20 %; cancelar con decisión aplica también a compras confirmadas.
- 19/oct/2026 · **Ajustes editables** (WhatsApp, transferencia, %, recargo, caja) y copia del % y recargo aplicados en cada separado.

## Recomendaciones hechas, por confirmar con el dueño

- **(a) `lib/main_catalogo.dart` compilada aparte: APROBADA (2026-10-19) y hecha.** El catálogo carga más liviano por WhatsApp, no
  incluye router/sesión/pantallas del admin y no expone rutas de administración. Implica: `build_web.sh` con
  destino (`-t lib/main_catalogo.dart`, salida aparte, p. ej. `/catalogo/`) y un `index.html` propio del catálogo
  (hoy `web/index.html` ya trae la vista previa de WhatsApp; al separar, el del admin no la necesita).
- **(b) Admin con Barón y empleados, con permisos desde el inicio:** dueño = todo; empleado = pedidos y abonos, sin
  precio de compra, sin cancelar separados, sin usuarios.
- **(c) Aviso de pedido nuevo:** v1 = contador de «Pedidos pendientes» + refresco silencioso (~60 s con la app
  abierta) + correo automático desde el PHP al crear el pedido (sin paquetes nuevos). Push real (Firebase) solo si
  Barón lo pide.

## Pendientes de decidir / aportar

- Dominio y nombre de la BD (marcadores en `CLAUDE.md`, `backend/CLAUDE.md`, `web/index.html`).
- Supuestos de `NEGOCIO.md` no confirmados uno a uno (recargo derivado al consultar, un recargo por mes vencido, el día exacto del
  vencimiento aún sin recargo, caja fuera del 20 %). El mes desde la confirmación de Barón y el resto de decisiones de BD las aprobó el usuario.
- Abiertas de BD (`backend/docs/BD.md` §9): pedido creado a mano por Barón, seguimiento del pedido para el cliente, vencimiento automático de solicitudes pendientes.
- Valores iniciales de los ajustes: WhatsApp de Barón y datos de transferencia (Barón los carga desde la app).
- Nombre comercial de Barón / logo (hoy «Sistema Oro» es el nombre de la app) y la imagen `og-catalogo.jpg`
  (1200×630, < 300 KB) para la vista previa del enlace.
- Textos de garantía y envíos seguros del catálogo (íconos de confianza).
- **Paquetes:** `image_picker` y `url_launcher` aprobados y agregados el 2026-10-19. Por decidir: un cargador de imágenes con caché para el catálogo.
- `AppTheme.dark`/`AppDarkColors` ya existen (candidatos a la base). Aviso: los estados `success` e `info` de `AppColors` contrastan
  poco como texto sobre fondo oscuro (3,4:1); definir variantes claras al usarlos como texto en el admin.
  `ResponsiveCards` llega a 3 columnas; el catálogo quiere 4 (agregarlo al componente).
- `README.md` de la raíz es el de `flutter create`; reemplazarlo cuando haya algo que contar.
- Plataformas `linux/`, `macos/`, `windows/` creadas por `flutter create`: no se usan (web, iOS, Android).

## Separar siempre

**Implementado** · **Probado localmente** · **Confirmado en el servidor** (solo si el dueño lo confirmó).
Hoy: la app (admin y catálogo) está *implementada y probada localmente* con red falsa (85 pruebas); el **SQL de 001 y 002 y la API PHP están confirmados en el servidor** (2026-10-19). La app contra el servidor real aún no está confirmada.


## Marca y logo (2026-10-20)
- Catálogo público con identidad de **Baron Golden Boss** (negro + dorado champán; ver `docs/DISENO_REFERENCIAS.md` y `docs/NEGOCIO.md`).
- **Logo cambiable desde la app de administración** (Ajustes → «Logo de la marca»): se sube a `uploads/logo/` (PNG grande 800 px y pequeño 200 px) y el catálogo lo lee de `publico/ajustes.php` (`logo_url?v=`) **sin recompilar** (se ve al recargar la página). Mientras no se suba ninguno, o si la imagen falla, se usa el logo empaquetado `assets/brand/logo.png` (150×150, baja resolución: pedir el original en PNG transparente/SVG). Migración **005** y PHP **instalados y confirmados por el usuario el 2026-10-20** (paquete `backend/entregas/SUBIR_TODO`).
- **Límite conocido:** `web_catalogo/index.html`, `manifest.json` y `og-catalogo.jpg` son estáticos: el logo cambiable NO aplica ahí. La vista previa de WhatsApp (og:image) usa la imagen estática (lockup en texto) hasta que se regenere y se vuelva a subir el catálogo.

## Banco, anular pagos, Resumen y cabecera del catálogo (2026-10-20)
- **Instalado y confirmado por el usuario (2026-10-20, probado en producción):** migraciones **006** (campo Banco opcional; anular abonos y el pago inicial con motivo) y **007** (Resumen mensual, permiso `resumen.ver`) + PHP. Paquete: `backend/entregas/SUBIR_TODO/` (importar `importar_todo.sql`, verificar = 8 × OK, subir el PHP).
- App admin: **Resumen** es la primera pestaña; **Clientes** pasó a «Más» para dejarle sitio. Catálogo: la cabecera fija muestra el buscador y, al bajar, los tipos de prenda (ya no hay fila de chips en la página).
- Sin verificar: servidor real, teléfono real, fluidez de animaciones.

## Catálogo: navegación, cabecera y diálogo (2026-10-20, tanda 2)
- **Atrás en el detalle:** las prendas ya se abrían con `push`, pero go_router no refleja `push` en la URL/historial del navegador (`optionURLReflectsImperativeAPIs=false`), así que «atrás» del navegador salía al inicio. Ahora el router del catálogo lo activa y la ruta `prenda/:id` es hija de `/`: cada prenda abierta queda en el historial (`#/prenda/<id>`), atrás vuelve prenda por prenda y, al llegar a la primera, al listado con su scroll. Un enlace directo a una prenda deja el catálogo debajo.
- **Cabecera:** arriba del todo solo el logo centrado; al bajar, logo a la izquierda + tipos de prenda + botón de chat (en teléfono, tipos en su fila). Alto fijo, cambio con fundido.
- **Buscador retirado** (UI, `search()` del provider, `query` del filtro y el parámetro `buscar` del repositorio). El endpoint `publico/prendas.php` sigue aceptando `buscar`. **Posible mejora (no hecha):** con muchas prendas conviene un icono de búsqueda en la cabecera compacta que abra el buscador.
- **Diálogo comprar/separar:** miniatura = primera foto del detalle (el detalle no trae `miniatura`, ver API.md); cantidad centrada con la fila.

## Tarjeta de «Pedidos»: comprobante, tipo y banco (2026-10-22)
- **Instalado (el usuario subió SQL y PHP el 2026-10-22; falta que confirme el resultado en la app):** migración **008** (`comprobante` y `banco` del pago inicial vigente en `pedidos/listar.php`) + PHP (`pedidos/comprobante.php?miniatura=1`: JPEG ≤ 240 px con caché en `privado/comprobantes_oro/miniaturas/`). Paquete: `backend/entregas/SUBIR_TODO/` (solo la 008 + PHP completo).
- App admin: en «Pedidos» cada tarjeta lleva chip de contorno **Compra / Separación** (aparte del chip de estado), el banco (si existe) y la miniatura del comprobante (toque → visor con zoom). En Separados la tarjeta no cambia.
- Sin verificar: servidor real (GD y permisos de la carpeta `miniaturas/` en Hostinger), teléfono real, imagen real decodificada.

## Eliminar prenda y velocidad al crear (2026-10-24)
- **Instalado (confirmado por el usuario el 2026-10-26: SQL 009 y 010, PHP y catálogo Astro subidos):** migración **009** (`eliminar prenda` lógica: columna `eliminada`, `sp_eliminar_prenda`, permiso `prendas.eliminar`, cola diferida de borrado de fotos) y **010** (contador `catalogo_version` + `publico/version.php`, tiempos y procesado eficiente de imágenes) + PHP. Paquete: `backend/entregas/SUBIR_TODO/` (importar 009 y 010 juntas, verificar, subir PHP). **Respaldar la base antes**: la 009 altera `prendas`.
- App admin: Eliminar prenda con permiso, optimista; crear prenda con fotos en segundo plano (consumidas por Flutter). `publico/version.php` lo consume el catálogo Astro; la app Flutter solo tiene la constante.
- Sin verificar: tiempos en el servidor real (MariaDB de Hostinger, GD, `fastcgi_finish_request`), teléfono real y red móvil.

## Cambio de dominio del catálogo (checklist, sin ejecutar)
Hoy el catálogo público está en `oro.murillocode.com` / `oro2.murillocode.com` (Astro) y habla con la API en `https://cobros.com.co/bd_oro/`. Si pasa a un dominio propio (p. ej. `https://bossprendas.com`), **la API NO cambia**: solo hay que permitir el origen nuevo y actualizar lo que se publica. Usa `NUEVO` = el origen exacto, con `https://`, sin `/` final y con o sin `www` según el que vaya a servir (si sirven los dos, permite los dos).

1. **Antes de apuntar el dominio (DNS y hosting):** crear el dominio/subdominio en Hostinger con su carpeta de publicación y SSL activo (HTTPS obligatorio: la API y WhatsApp lo exigen).
2. **CORS del backend — `privado/oro.php`** (fuera de `public_html`, a mano): agregar `NUEVO` a `'origenes_permitidos'` **conservando los viejos** durante la transición, p. ej. `['https://bossprendas.com', 'https://www.bossprendas.com', 'https://oro.murillocode.com', 'https://oro2.murillocode.com']`. Sin `/` final y sin comodín. Después de guardar: abrir el catálogo nuevo y comprobar que lista prendas (si sale en blanco, casi siempre es este origen) y que `publico/version.php` responde. No hay que subir PHP ni importar SQL.
3. **Catálogo Astro** (carpeta `sistema_oro_astro`, otro chat): poner `site: 'https://NUEVO'` en `astro.config.mjs` (hoy no tiene `site`); revisar en el layout/cabecera que `og:url`, `og:image`, `canonical` y cualquier URL absoluta apunten a `NUEVO` (la imagen `og-catalogo.jpg` debe quedar accesible en el dominio nuevo, URL absoluta, 1200×630); `PUBLIC_API_BASE_URL` se queda en `https://cobros.com.co/bd_oro/`; recompilar y subir el zip a la carpeta del dominio nuevo (borrando antes el contenido anterior; incluir `.htaccess` y `robots.txt`/`sitemap` si existen y que apunten al dominio nuevo).
4. **Catálogo Flutter** (solo si se vuelve a usar): en `web_catalogo/index.html` cambiar `og:url` (`https://oro.murillocode.com/` → `NUEVO/`) y `og:image` (`…/og-catalogo.jpg`); `web_catalogo/manifest.json` usa `start_url: "."` (relativo, no necesita cambio); `CATALOGO_BASE_HREF` queda en `/` si el catálogo vive en la raíz; recompilar con `bash scripts/build_catalogo.sh --dart-define=API_BASE_URL=https://cobros.com.co/bd_oro/` y regenerar `build/catalogo_oro.zip`. El comentario de `scripts/build_catalogo.sh` menciona `oro.murillocode.com` (solo texto).
5. **App de administración (web):** si el admin web se publica en un dominio propio, ese origen también va en `origenes_permitidos` (la app móvil nativa no usa CORS). La app del teléfono no cambia: usa `https://cobros.com.co/bd_oro/`.
6. **Redirección del dominio viejo:** en el hosting de `oro.murillocode.com` y `oro2.murillocode.com`, redirección **301** permanente a `NUEVO` conservando la ruta (`https://oro.murillocode.com/(.*)` → `NUEVO/$1`), por `.htaccess` o por el panel. Mantener los orígenes viejos en CORS hasta que nadie los use; luego quitarlos.
7. **Vista previa de WhatsApp (caché):** WhatsApp, Facebook e Instagram guardan la vista previa del enlace por URL. Con el dominio nuevo la URL es nueva y se genera sola, pero hay que comprobarla: pegar `NUEVO` en un chat y confirmar título, descripción e imagen. Si queda una vista vieja o sin imagen, forzar la recarga en el depurador de Facebook (Sharing Debugger → «Scrape Again»); WhatsApp puede tardar horas en refrescar. Los enlaces ya compartidos con el dominio viejo seguirán abriendo por la redirección 301.
8. **Textos y documentación:** actualizar el dominio en `backend/docs/PUBLICACION.md` (sección «Catálogo público»), en `docs/PROGRESO_FLUTTER.md` y en el mensaje de «Te la conseguimos»/WhatsApp si lleva el enlace; avisar a quien tenga el enlace guardado (Instagram @barongoldenboss, tarjetas, bio).
9. **Verificación final:** (a) `NUEVO` lista prendas y abre un detalle; (b) comprar/separar envía la solicitud (CORS del POST con comprobante); (c) `NUEVO/` y el dominio viejo (redirige); (d) vista previa de WhatsApp; (e) `health.php` sigue en `https://cobros.com.co/bd_oro/health.php`. Marcar como «instalado» solo cuando el usuario lo confirme.
