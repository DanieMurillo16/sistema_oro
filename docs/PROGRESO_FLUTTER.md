# Progreso del chat Flutter — Sistema Oro

> **Si abres un chat nuevo o se acabó el límite de sesión: lee esto primero**, luego `docs/ESTADO.md` y
> `docs/ARRANQUE_FLUTTER.md`. Se actualiza al terminar cada paso. Orden del plan aprobado por el dueño (2026-10-19):
> el dueño pidió aplicar **todo el plan de corrido, sin parar por cada paso**, y probar y ajustar al final.

Leyenda: ✅ hecho · 🔄 en curso · ⬜ pendiente. «Hecho» = escrito, `flutter analyze` limpio y pruebas del paso en verde;
**nada está probado contra el servidor real ni en un teléfono** hasta que el dueño lo diga.

| # | Paso | Estado | Notas |
|---|---|---|---|
| 0 | Base: tema oscuro, splash, `main_catalogo.dart`, `index.html` propio, `build_catalogo.sh`, paquetes aprobados | ✅ | 22 pruebas verdes |
| 1 | Núcleo + login, sesión y shell del admin (`auth`, router, menú por permisos, «Más») | ✅ | Hecho: sesión por token (`sessionProvider`, `canProvider`), login, router con redirect, menú por permisos, «Más». 7 pruebas de flujo. Riverpod sin reintentos automáticos (`noProviderRetry`). Rutas /pedidos, /separados, /prendas, /clientes, /ajustes, /usuarios se agregan en `app_router.dart` al hacer cada feature. |
| 2 | Pedidos: lista, insignia de pendientes, detalle con comprobante, confirmar/rechazar/cancelar/enviar/entregar/editar entrega | ✅ | Hecho: lista (Por revisar/Compras/Todos), búsqueda, insignia de pendientes (refresco cada 60 s, apagado en pruebas), detalle con comprobante, confirmar/rechazar/cancelar con decisión/enviar/entregar/editar entrega. Flujo: pantalla → `ordersProvider` (lista única, `upsert`) / `orderActionsProvider` → `OrdersRepository` → `pedidos/*`. 8 pruebas de flujo. |
| 3 | Separados y abonos: lista, registrar y anular abono | ✅ | Hecho: pestañas Activos/Vencidos/Todos, registrar abono (multipart, comprobante), anular pago; `paymentActionsProvider` → `PaymentsRepository`. 6 pruebas de flujo. Al hacer Prendas: invalidar `garmentsProvider` en `syncOrder` (el stock cambia con confirmar/rechazar/cancelar). |
| 4 | Prendas: lista, crear/editar, stock, imágenes, tipos | ✅ | Hecho: lista con pestañas, crear/editar prenda (costo solo con `prendas.ver_costo`), ajustar stock, fotos (multipart, hasta 6), tipos. Flujo: pantalla → `garmentsProvider` (lista única) / `garmentActionsProvider` / `garmentPhotosProvider` → `GarmentsRepository` → `prendas/*`, `tipos/*`. Confirmar/rechazar/cancelar un pedido invalida `garmentsProvider`. 11 pruebas de flujo. |
| 5 | Clientes, Ajustes y Usuarios | ✅ | Hecho: Clientes (lista con saldo, ficha con historial, editar), Ajustes (agrupados, editor por tipo: texto/entero/pesos/%/sí-no) y Usuarios (crear, editar, cambiar clave; solo dueño). Menú «Más» marca ajustes/usuarios. 16 pruebas de flujo. |
| 6 | Catálogo público (`main_catalogo.dart`): cuadrícula, detalle, comprar/separar, «Te la conseguimos», WhatsApp | ✅ | Hecho: catálogo público claro/marfil (`AppTheme.catalog`), cabecera fija con búsqueda, tipos, orden, cuadrícula 2/3/4 con etiquetas y zoom, «Ver más», detalle con galería y barra fija Comprar/Separar en teléfono, comprar/separar (multipart, `clave_envio` UUID reutilizada al reintentar, caja, entrega, comprobante), «Te la conseguimos» y botón de WhatsApp. El catálogo no importa nada del admin. 15 pruebas de flujo. Única suma de dinero de la app: `CheckoutRules.total` (el contrato exige monto exacto en COMPRA). |
| 7 | Cierre: pruebas de flujo, `ui_audit.sh`, reviewer, tester, bloque final de lo que se sube | ✅ | Hecho: `ui_audit.sh` en 0 pistas (build() ≤ 60, sin métodos que devuelven Widget), `features/home` borrada, reviewer pasado (corregidos los hallazgos altos y la mayoría de los medios), builds web del admin y del catálogo compilan (Wasm). 85 pruebas verdes. NO se corrió el agente `flutter-tester` (las pruebas de flujo ya cubren lo que cambió) ni se probó contra el servidor real ni en un teléfono. |

## Estado actual (2026-10-19): todo el plan está escrito; falta PROBARLO con el dueño

Lo que sigue es **probar y ajustar** (no hay pasos de construcción pendientes). Lo que NO se ha verificado:
- Login real, subida de imágenes de prendas y de comprobantes contra `https://cobros.com.co/bd_oro/` (GD y `upload_max_filesize` ≥ 6 MB).
- Cómo se ve en un teléfono y en pantalla grande (las pruebas de layout usan una fuente de prueba más ancha que Inter; el reviewer midió con Inter).
- CORS: el servidor solo acepta los orígenes de `origenes_permitidos` en `privado/oro.php`; hay que agregar el dominio del catálogo y el de la administración web.
- Dominio real del catálogo (`TU-DOMINIO` en `web_catalogo/index.html`) y la imagen `og-catalogo.jpg` (1200×630) para la vista previa de WhatsApp.
- iOS/Android: no se compiló nativo (solo web). Se agregaron permisos de fotos/cámara en `Info.plist`.

## Mapa de lo construido (para ubicarse rápido)

`pantalla → provider → repositorio → endpoint`
- Login: `LoginScreen → loginProvider/sessionProvider → AuthRepository → auth/*` (router redirige por sesión; menú por permisos).
- Pedidos: `OrdersScreen/OrderDetailScreen → ordersProvider (lista única) + orderActionsProvider → OrdersRepository → pedidos/*`.
- Separados y abonos: `LayawaysScreen` (misma lista) + `paymentActionsProvider → PaymentsRepository → pagos/*`.
- Prendas: `GarmentsScreen/GarmentDetailScreen → garmentsProvider + garmentActionsProvider/garmentPhotosProvider → GarmentsRepository → prendas/*, tipos/*`.
- Clientes, Ajustes, Usuarios: `clientsProvider`, `settingsProvider`, `usersProvider` (+ `*ActionsProvider`) → `clientes/*`, `ajustes/*`, `usuarios/*`.
- Catálogo público: `CatalogScreen/CatalogGarmentScreen → catalogGarmentsProvider/catalogSettingsProvider/checkoutProvider → CatalogRepository → publico/*` (otro router: `catalog_router.dart`; no importa nada del admin).

## Decisiones del chat Flutter (no están en el código)

- Riverpod 3 reintenta solo los providers que fallan: se apagó (`noProviderRetry`) para mostrar el error con «Intentar nuevamente».
- Los listados (pedidos, prendas, clientes, ajustes) se piden por páginas de 200 y se guardan completos en un provider de sesión; buscar y filtrar es local. Escribir hace `upsert` de esa fila y marca viejo el detalle.
- Insignia del menú: `pedidos/contadores.php` cada 60 s con la app abierta; si cambia, se refresca la lista sin vaciarla. En pruebas se apaga (`orderRefreshIntervalProvider`).
- Teléfono: los indicadores (KPI) de Pedidos/Separados se esconden (repiten las pestañas y le quitan sitio a la lista).
- Única suma de dinero de la app: `CheckoutRules.total` (precio × cantidad + caja), porque el contrato exige que el `monto` de una COMPRA sea exacto. El 20 % lo calcula el servidor (`valor_separado`).
- Separado desde el catálogo: cantidad 1 y el monto va del 20 % al total; compra: hasta lo que haya (máx. 20).
- El catálogo usa URL con `#` (sin configuración del servidor). Cuadrícula de 2 columnas en teléfono, 3 desde 700 px y 4 desde 1000 px.
- «Ajustes» y «Usuarios» viven dentro de «Más» (la barra inferior admite 5 destinos).
- Nombres de personas se muestran con cada palabra en mayúscula (`formatPersonName`); los datos guardados no se tocan.

## Lo que hay que subir al servidor (resumen)

- **SQL:** nada nuevo (001 y 002 ya instaladas). **PHP:** nada nuevo (entrega 003 ya instalada).
- **Web del administrador:** subir el CONTENIDO de `build/web` (`bash scripts/build_web.sh --dart-define=API_BASE_URL=https://cobros.com.co/bd_oro/`).
- **Web del catálogo:** subir el CONTENIDO de `build/catalogo` a la carpeta del catálogo (`bash scripts/build_catalogo.sh --dart-define=API_BASE_URL=...`; poner antes el dominio real en `web_catalogo/index.html`).
- **Configuración privada del backend:** agregar a `origenes_permitidos` (en `privado/oro.php`) el dominio del catálogo y el de la administración web.

## Para retomar

- Comandos: `flutter analyze` · `flutter test` · `bash scripts/build_catalogo.sh --dart-define=API_BASE_URL=https://cobros.com.co/bd_oro/`
- Sincronía del contrato: `python3 -I ~/.claude/flutter-base/tools/api_sync_check.py backend/docs/API.md lib/core/network/api_endpoints.dart backend`
- Ajustes visuales o de flujo que pida el dueño tras probar: se anotan aquí con fecha.


## Ajustes tras probar en el simulador (2026-10-19/20)

- **Pedidos:** refresco cada 1 s mientras se está en la pantalla (60 s fuera de ella); «Por revisar» en orden de llegada; botones de acción
  flotantes, pequeños y sin banda de fondo; detalles en dos columnas (`InfoGrid`).
- **Separados → pestaña «Recordar»:** separados activos con más días sin abonar primero; botón de WhatsApp que abre la app instalada
  (`whatsapp://`) y, si no, `wa.me`, con un mensaje amable. Usa `ultimo_pago` de `pedidos/listar.php` (**requiere la migración 003 /
  entrega 004**; sin ella cuenta desde la fecha del pedido). Declarado `whatsapp` en `Info.plist` y `AndroidManifest.xml`.
- **Clientes:** mini foto en cada pedido de la ficha y la flecha «atrás» del pedido vuelve a la ficha (`?from=`).
- **Prendas:** carrusel de hasta 3 fotos (animación sutil, «x» pequeña en la esquina), fotos también al crear, stock junto a «Publicada» con
  lápiz para ajustarlo, tarjeta «Ventas» (unidades y clientes) y resumen del inventario (prendas, unidades, peso, valor). Toggle centrado.
- Pruebas: 90 de la app en verde (+5 de reglas nuevas); `flutter analyze` limpio. **Sin verificar:** abrir WhatsApp real (el simulador no lo tiene).
- **Precarga (2026-10-20):** al entrar a la administración, `appPreloadProvider` (en `MainShell`) pide a la vez pedidos, prendas, clientes, tipos,
  ajustes e insignia, y refresca prendas y clientes en silencio cada 60 s (pedidos ya se refrescan solos). Cada lista solo se pide si hay permiso.
- **Ver el catálogo en el simulador:** `flutter run -d <simulador> -t lib/main_catalogo.dart --dart-define=API_BASE_URL=https://cobros.com.co/bd_oro/`
  (nativo: no necesita CORS). En web hace falta agregar su origen en `origenes_permitidos` de `privado/oro.php`.
- **Pulido visual (2026-10-20):** detalle del pedido con UNA tarjeta resumen (prenda + estado + cliente + franja Total/Pagado/Saldo + desglose en 3 columnas;
  se eliminó `OrderMoneyCard`). Catálogo: buscador suave en píldora (dorado al enfocar), bloque «Joyería en oro», chips más finos, contador + «Ordenar» en una
  fila (menú discreto), etiquetas en píldora (SALE dorada, NUEVO oscuro), fotos con más radio, botones de compra en píldora (Separar con borde dorado).
- **Catálogo: velocidad y animaciones (2026-10-20):** `CatalogPhoto` (miniatura al instante + foto buena con fundido, decodificada al tamaño que hace falta);
  la foto de la tarjeta «viaja» al detalle (Hero) y el detalle se abre YA con lo del listado (la galería completa lo reemplaza al llegar);
  entrada del detalle con `AppSlideIn` (galería desde un lado, datos desde el otro); galería deslizable de lado a lado con miniaturas redondas en franja
  (la elegida, más grande y con borde dorado). Tarjetas blancas con sombra suave y precio al lado del tachado; barra de compra del teléfono con precio + «Comprar».
- **Fotos más livianas (entrega 005, solo `core/archivos.php`):** grande 1200 px (antes 1600), calidad 80, JPEG progresivo; miniatura 420 px. Solo afecta fotos
  NUEVAS; las ya subidas hay que volver a subirlas para aligerarlas.
- **Catálogo: portada y movimiento (2026-10-20):** fondo blanco; portada oscura con titular dorado y adornos FLOTANTES (`AppFloat`: círculo con diamante, destello y tarjeta «20 % para separar»,
  que suben y bajan sin parar; `ambientMotionProvider` los apaga en pruebas y con «reducir movimiento»). Al hacer scroll las tarjetas entran por los lados (`AppSlideIn`: primera columna
  desde la izquierda, última desde la derecha). El detalle se abre con `context.push` y se cierra con `pop` (antes era `go`, por eso la vuelta no animaba): botón «atrás» en un círculo
  blanco (`CatalogBackButton`), y la foto «viaja» de ida y de vuelta (Hero).
- **Rediseño del catálogo «joyería» (2026-10-20):** paleta marfil `#FAF7F2` + tarjetas blancas con borde champán `#EAE2D6` y sombra multicapa; botón principal NEGRO obsidiana, dorado para
  insignias/oferta/bordes activos (`AppCatalogColors`). Cabecera fija translúcida (blur); portada oscura (compacta ~150 px en móvil); tarjetas 4:5 (cuadradas en móvil) con
  micro-badges (oro, peso, largo) y «Sepárala con el 20 %» (SIN el monto); al pasar el mouse las fotos de la prenda rotan con fundido; escalonado al entrar; micro-interacciones
  (`AppPressable`). Detalle: badge de categoría + ref monoespaciada + disponibilidad, «Ahorras $…», bento 2×2, plan separe (pago inicial / saldo), botones negro y dorado,
  sellos, barra fija en móvil, galería con fundido automático cada 4,5 s (pausa 9 s tras tocar), zoom (pellizco/doble toque) y «Otras piezas que te pueden gustar»
  (flotan despacio; si no hay otras, banda de beneficios). Hero de ida y vuelta con esquinas interpoladas. Precio anterior más pequeño y tenue.
  Textos de beneficios: solo lo que el negocio ofrece (no se afirma «garantía/verificado/bóveda»; confirmar con Barón si quiere esas frases).
- **Ajustes de detalle y compra (2026-10-20):** precio anterior pequeño ARRIBA del actual en el detalle y la barra móvil; botón «Comprar» más grande; tocar la foto grande abre un visor
  (`showGalleryZoom`: fondo oscuro, zoom con pellizco/doble toque, desliza entre fotos); en el diálogo de compra/abono/fotos el adjunto es UNA fila (miniatura + nombre + iconos cambiar y quitar)
  en `ImagePickerField`; etiquetas SALE/NUEVO en horizontal; puntitos de «hay más fotos» sobre la foto de la tarjeta (`fotos` del listado, **requiere la entrega 006**) y deslizar la foto
  de la tarjeta cambia de imagen.

### 2026-10-20 · Catálogo en vivo, código → WhatsApp y detalle
- Tras enviar el comprobante: botón **Copiar código** y **Enviar por WhatsApp** (abre la app si está instalada, con el mensaje y el código ya escritos; `RequestKindLabels.whatsappMessage`).
- **Inventario en vivo**: el listado (`CatalogGarmentsNotifier`) y el detalle (`catalogGarmentProvider`) se revisan cada 2 s sin cargadores (`catalogPollIntervalProvider`; las pruebas lo apagan). Si otra persona se lleva la prenda: el listado la quita, el detalle muestra `GarmentGone` y el formulario de compra se cierra con aviso (no si ya se está enviando o ya se envió).
- Detalle: miniaturas dentro de la foto (translúcidas), sin barra superior (solo «atrás»), sin precio ni «Ahorras» en el cuerpo en teléfono (están en la barra de compra), «Comprar» late (`AppPulse`), y una miniatura flotante (`GalleryFloatingThumb`) aparece al pasar la galería; al tocarla sube al inicio y abre el visor con zoom.
- Tarjeta del listado: precio anterior arriba y más pequeño.

### 2026-10-20 · Catálogo más limpio (referencias Airbnb / Rappi)
- Tarjeta sin marco (`CatalogCard`): foto redondeada que se eleva con el mouse, nombre, una sola línea «Oro · peso · largo» (reemplaza los `SpecChip`, eliminado), precio y nota del 20 %. Más aire entre tarjetas.
- Portada ancha más baja: titular en una línea + una frase; se quitaron los adornos duplicados (la banda de beneficios ya los dice).
- Detalle: se quitaron los sellos de confianza repetidos y la banda de beneficios de relleno cuando no hay sugerencias; medidas una por línea; el pulso de «Comprar» es más suave en pantallas anchas.

### 2026-10-20 · Home: cabecera estilo Airbnb y «Reservar»
- Cabecera: marca a la izquierda, búsqueda en píldora blanca centrada con círculo dorado y WhatsApp a la derecha (teléfono: búsqueda en su propia fila).
- Tarjeta del listado: sin precio anterior; precio y botón **Reservar** en la misma fila (`CatalogReserveButton`). Reservar abre `LayawayInfoDialog` (pagas hoy / saldo / 1 mes y recargo de los ajustes) y «Continuar» abre el formulario de separar. Se quitó la nota «Sepárala con el 20 %».

### 2026-10-20 · Dominio del catálogo: `oro.murillocode.com` (raíz del subdominio)
- `web_catalogo/index.html` apunta a `https://oro.murillocode.com/` (og:url y og:image `og-catalogo.jpg`); `scripts/build_catalogo.sh` compila con base href `/` y copia `web_catalogo/og-catalogo.jpg`.
- Servidor: ya instaladas 003 y 004 (SQL) y el PHP completo (`health.php` ok). Falta en `privado/oro.php`: `'origenes_permitidos' => ['https://oro.murillocode.com']` (ver `backend/docs/PUBLICACION.md`).


### 2026-10-20 · Rediseño de marca «Baron Golden Boss» + logo cambiable
- Catálogo oscuro: tokens en `AppCatalogColors` (negro del logo `#010101`, carbón, marfil, dorado champán), `AppTheme.catalog` en oscuro; cabecera con `BrandLogo` + «BARON / GOLDEN BOSS»; portada con la pieza más reciente; tarjetas casi solo foto (radio 6, poca separación); «Comprar» dorado (2/3, con pulso) y «Separar» de contorno lado a lado; franja de confianza; «Te la conseguimos» con borde dorado.
- `BrandLogoImage` (shared) pinta `logo_url` o el asset `assets/brand/logo.png`; admin: `BrandLogoSection` en Ajustes (cambiar / restaurar); datos: `brandLogoProvider` + `ajustes/logo_*.php`.
- `web_catalogo/` (index, manifest, og-catalogo.jpg) con el nombre y colores de la marca; `build_catalogo.sh` copia manifest y og.
- Pendiente en el servidor: migración 005 + PHP (paquete `SUBIR_TODO`) y `origenes_permitidos` con el dominio del catálogo.

### 2026-10-20 · Lote de 12 ajustes (Banco, anular, Resumen, cabecera, creación de prendas)
- Comprar/separar: cantidad en fila, nombre+WhatsApp en pareja, campo **Banco**, al cerrar la confirmación va al inicio (sin «ya no está disponible» para quien acaba de reservar).
- Catálogo: cabecera fija con buscador arriba y **tipos de prenda al bajar** (`catalogHeaderCompactProvider`, `CatalogHeaderMiddle`, `CatalogTypeStrip`); se quitó la fila de chips de `CatalogFilters`.
- Admin: Resumen mensual (`features/summary`), Anular abono/pago (con motivo) y Banco en el detalle del pedido, Nombre+Tipo en pareja en «Nueva prenda», `AppToggle` con texto centrado, arreglo del cargador infinito al crear prenda (subida de fotos dentro de la operación observada, `keepAlive`) y de las miniaturas.
- Migraciones **006 y 007** + PHP + catálogo instalados y probados por el usuario en producción.

### 2026-10-22 · Tarjeta de Pedidos con comprobante
- `OrderTile(showTypeAndReceipt: true)` (solo «Pedidos»): `OrderTypeChip`, `ReceiptThumb` (miniatura 44 px, `receiptThumbProvider` → `OrdersRepository.receiptThumb` → `pedidos/comprobante.php?miniatura=1`), banco con icono. `Order` ganó `receipt` y `bank`. Migración 008 + PHP subidos por el usuario (2026-10-22).

### 2026-10-22 · Pestañas de Pedidos y Separados al pie (una mano)
- `BottomToggleBar` (shared) en `Scaffold.bottomNavigationBar` de las dos pantallas (`OrdersTabsBar`, `LayawaysTabsBar`); la búsqueda y los KPI siguen arriba. `AppToggle(touch: true)` da ≥ 44 px de toque; el texto de la barra crece hasta 1.2×. Se esconde con el teclado (`keyboardOpenProvider`, que mira la ventana real: el Scaffold del menú le quita el teclado al `MediaQuery`). Clientes y Prendas siguen con las pestañas arriba (`ListFilterBar`).

### 2026-10-24 · Eliminar prenda y crear prenda más rápido
- **Eliminar (lógica):** `DeleteGarmentDialog` (nombre en negrita, motivo opcional, «Solo ocultar» solo desde el detalle porque la fila de la lista no trae la descripción), `GarmentDeleteCard` al final del detalle, ⋮ en el AppBar y menú al mantener pulsada la tarjeta (`GarmentActionsSheet`); solo con el permiso `prendas.eliminar` (dueño). Flujo: diálogo → `garmentDeleteProvider` (optimista: `GarmentsNotifier.remove(id)` al instante, vuelve con `upsert` si el servidor lo rechaza) → `GarmentsRepository.delete` → `POST prendas/eliminar.php`. El aviso (éxito o el mensaje del 422) lo da `GarmentsScreen` con `listenAction`.
- **Crear:** la prenda aparece en la lista apenas existe (`create` → `syncGarment`); las fotos suben en segundo plano (`garmentUploadsProvider`: la primera sola, las demás de a 2, 3 intentos, «Reintentar»), con vista previa local y avance en el detalle (`GarmentUploadStrip`) y un chip «Subiendo fotos» / «Fotos sin subir» en la tarjeta. La foto ya se reduce antes de subir (`ImagePickerService`: 1600 px, calidad 85).

### 2026-10-25 · Ocultar vs Eliminar, selección múltiple, confirmaciones y regla del separado
- **Prendas:** «Ocultar del catálogo» (reversible: `garmentVisibilityProvider` pide la prenda completa y reenvía `prendas/editar.php` con `activa`; la fila de la lista no trae la descripción) y «Eliminar» (la saca de la app y del catálogo) son acciones distintas en el detalle, el ⋮ y el menú de la lista. Pestaña **Ocultas**. Selección múltiple (mantener pulsada → «Seleccionar varias» → «Eliminar N seleccionadas»): `GarmentDeleteNotifier.deleteMany` elimina una por una (optimista; las rechazadas vuelven y el resumen dice «Se eliminaron N, M no se pudieron: motivo»). La selección se descarta al cambiar de pestaña o buscar.
- **Confirmación obligatoria:** `confirmDestructive()` (`shared/utils/confirm_destructive.dart`) + `ConfirmActionDialog` (nombre en negrita, consecuencia, motivo opcional/obligatorio, anti doble toque). Pasan por él: cerrar sesión, cambiar y restaurar el logo, quitar foto, desactivar usuario. Eliminar prenda, anular pago, rechazar y cancelar pedido tienen diálogo propio en `widgets/dialogs/`. `test/core/confirmacion_destructiva_test.dart` falla si una vista llama a una acción destructiva sin ninguno de los dos.
- **Catálogo Flutter:** «Separar no es llevarte la prenda…» en el plan, el aviso del separado (plazo y recargo de ajustes), casilla obligatoria que habilita «Enviar separado», confirmación y mensaje de WhatsApp.

### 2026-10-26 · Estado del servidor
- **Instalado y confirmado por el usuario (2026-10-26):** migraciones **009** (eliminar prenda lógica) y **010** (versión del catálogo), el PHP asociado y el zip del catálogo Astro (en `oro2`). Flutter ya consume 008 (miniatura/banco) y 009 (Eliminar prenda); `publico/version.php` (010) lo consume el catálogo Astro, no la app Flutter.
