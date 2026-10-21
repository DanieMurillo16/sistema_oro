# Referencias de diseño — Sistema Oro

Las capturas que dio el dueño no pasan a los siguientes chats; esto las describe. Son **referencias de intención**,
no copias: todo se construye con los tokens y componentes de `flutter-base` (`AppColors`, `AppTheme`,
`DesignTokens`).

## 1. Administración: «Cuentas Claras» (app del dueño del proyecto)

Oscura, limpia y sin ruido. Qué tomar de las capturas:

**Pantalla «Nuevo pago recurrente»**
- Fondo casi negro azulado; AppBar apenas más claro con flecha atrás y título a la izquierda.
- Alternador de dos opciones tipo píldora («Me pagan» / «Yo pago»): la activa rellena de color de acento, con icono.
- Campos `filled` oscuros, borde tenue, radio grande (~12–16), etiqueta dentro del campo. Etiqueta flotante en el
  borde cuando el campo tiene valor («Cada»).
- Segundo alternador de 3 opciones (Semanal / Mensual / Anual), la activa en verde azulado.
- Campos cortos **en pareja** (Cada + Desde; Categoría + Contacto), con icono en un cuadro tenue y flecha de
  despliegue. Texto de ayuda pequeño y apagado bajo el campo.
- Un solo botón principal, ancho completo, abajo, con el color de marca.

**Splash**
- Fondo casi negro; al centro un icono redondeado con degradado (verde azulado) y símbolo, el nombre de la app
  en blanco y negrita, una frase corta en gris («Maneja tus gastos, ingresos y pagos, todo en un solo lugar.») y
  **indicadores de página** (el activo alargado en color de acento, los otros puntos tenues).
- Para Sistema Oro: icono dorado (degradado champán → dorado envejecido) con símbolo de joya/anillo, «Sistema Oro»,
  una frase corta propia e indicadores. Limpio, sin más elementos.

**Traducción a Sistema Oro:** misma estructura y densidad, acento **dorado** (`#8A6A2F` como base; una variante más
clara para texto y bordes activos sobre fondo oscuro), no verde azulado. Los tokens oscuros se definen en el primer
chat Flutter.

## 2. Catálogo: referencias de joyería

Objetivo: **elegante y limpio**, con **animaciones minimalistas** que llamen la atención (aparición suave, zoom corto
de imagen al pasar el mouse, cuenta/deslizamiento de cifras, `AppAppear` / `AppCollapse` de la base, siempre con
`motionDuration` y sin rebotes).

### «Paula Mendoza» (nombre que le dio el dueño; la captura adjunta es de decolombiajoyas.com, fondo blanco)
- **Cabecera fija** (se queda al desplazar): logo grande a la izquierda, menú de categorías con despliegue, iconos
  de cuenta, favoritos, búsqueda y carrito a la derecha. Barra superior fina con aviso de marca/comentarios.
- **Migas de pan** («Inicio / Oro 18k») y, debajo, una barra con «Mostrando 1–50 de 327 resultados», botón
  **FILTRO**, selector de **orden** («Orden predeterminado») y alternador cuadrícula/lista.
- **Cuadrícula de 4 columnas** en escritorio, mucho aire entre tarjetas. Cada tarjeta: foto sobre fondo claro sin
  borde, nombre (con talla/medida pequeña y apagada: «Anillo  t: 6»), **precio** y categoría en gris pequeño.
- **Etiquetas sobre la foto:** `NUEVO` · `SALE` · `ÚLTIMA UNIDAD` · `AGOTADO` *(descritas por el dueño; no se ven en las capturas)*.
- Al pasar el mouse sobre la tarjeta aparece el botón **«Seleccionar opciones»** *(descrito por el dueño; no se ve en las capturas)*.
- **Detalle de prenda:** foto grande a la izquierda con **miniaturas** debajo (la activa con borde); a la derecha el
  nombre grande, breve descripción, precio, selector de talla, cantidad (− 1 +), botón **«Añadir al carrito»**
  (gris cuando falta elegir talla), favorito, referencia (`Ref: MCEA14`) y flechas «Atrás / Siguiente» para recorrer
  prendas. Botón flotante de WhatsApp abajo a la derecha (círculo, color de marca).
- Para Sistema Oro: en lugar de talla, medidas en cm y tipo de oro; en lugar de «Añadir al carrito», **«Comprar»** y
  **«Separar con el 20 %»**; mostrar cuánto es el 20 % ya calculado.

### Élite Joyería (negro y dorado)
- **Hero** oscuro a pantalla ancha con titular grande dorado (serif) («Compra oro de 18k / Garantizado de por vida»),
  fotografía de modelo a la derecha y botón destacado.
- **Categorías con foto grande** en franja horizontal (CADENAS · ANILLOS · PULSERAS…), título dorado en mayúsculas
  bajo cada foto y barra de progreso del desplazamiento.
- **Carruseles** por categoría («Dijes Exclusivas Oro 18k», «Cadenas Exclusivas Oro 18k»): 4 tarjetas visibles,
  flechas circulares blancas a los lados, foto cuadrada grande (la prenda en la mano o en su caja), nombre completo
  con peso y largo («… 18k 1,65 Gr / 0,5 mm / 50 Cm»), precio pequeño y botón redondo dorado de carrito.
- **Íconos de garantía y envíos seguros** (franja de confianza), botón flotante de **WhatsApp** («¿Necesitas
  ayuda?») y botón «subir» circular.
- Para Sistema Oro: tomar el negro/dorado para el hero y los acentos, no para todo el fondo; la cuadrícula y el
  detalle van sobre fondo **marfil/blanco cálido** para que el oro de las fotos resalte.
- Los nombres de prenda **crecen** (no se recortan con «…») y dicen peso y medidas, como en esta referencia.

### Catálogo del sistema Turco (mismo dueño; referencia de estructura, ya vista en capturas)
- **Entrada:** pantalla centrada con logo cuadrado, «Bienvenido al catálogo de …», un campo (documento o NIT con contador
  0/30) y botón ancho «Entrar al catálogo». En Turco el cliente se identifica; **en Sistema Oro NO hay entrada ni
  login**: el catálogo abre directo.
- **Cabecera** azul oscuro con logo pequeño + nombre del negocio a la izquierda y botón de salir a la derecha.
- **Barra de búsqueda** ancha («Buscar nombre o referencia…») con dos botones cuadrados a la derecha: **refrescar** e
  **historial**. En Sistema Oro: buscar por nombre o referencia + refrescar; el historial se reemplaza por «Mis pedidos»
  solo si se define (sin login no hay historial).
- **Cuadrícula de 4 columnas** en escritorio, tarjetas blancas de radio grande sin borde, con foto arriba (hoy marcador
  gris con icono de imagen), **nombre**, **referencia + unidad** en gris pequeño, **precio** en negrita y
  «Disponible: N …», y un botón cuadrado tenue con **carrito** abajo a la derecha.
- Fondo gris azulado claro, mucho aire entre tarjetas, texto Inter. Flujo: buscar → tarjetas → carrito → pedido.
- Para Sistema Oro: misma estructura (buscar → tarjetas → detalle), pero con **«Comprar / Separar»** de una prenda
  (cantidad permitida, aunque hoy sea 1), foto protagonista y etiquetas; se agrega el comprobante de transferencia.

### Jerarquía visual «ANTES / DESPUÉS» (tienda oscura; captura del dueño, 2026-10-20)
- El «antes» es plano: banner de descuento, íconos de categorías, tarjetas grises y barra de cuotas pesan todo igual.
- El «después» tiene **UN héroe dominante**: etiqueta pequeña en mayúsculas («NUEVA COLECCIÓN»), titular grande,
  subtítulo corto, **un solo botón relleno con flecha** («Descubrir ahora →»), el producto a la derecha con un halo
  luminoso y puntos de carrusel; luego «Productos destacados» con «Ver todo →», tarjetas compactas (foto, nombre,
  precio) y una **franja de confianza** de 3 ítems (ícono + título + subtítulo) con divisores finos.
- Lección aplicada: contraste de tamaño/peso/color, **una sola acción primaria**, espacio generoso, menos cajas.
  En el catálogo: portada oscura con titular de 56 px, botón dorado «Ver el catálogo →» y la pieza más reciente con
  halo dorado (`CatalogHero`, `HeroProduct`); `CatalogTrustStrip` (3 ítems con divisores); tarjetas sin marco; detalle
  con «Comprar» (2/3, primario, con pulso) y «Separar» (1/3, contorno) **lado a lado**.
- Decisión: **quitar el fondo crema/amarillo** y las cajas beige (píldora «Ahorras», caja «Plan separe», recuadros de
  medidas). Primero se probó fondo blanco/gris; el dueño mostró el Instagram de la marca y **la referencia principal
  pasó a ser esa identidad oscura** (ver abajo).

### Identidad real de la marca: Instagram @barongoldenboss (2026-10-20) — REFERENCIA PRINCIPAL del catálogo
- **Marca:** «BARON · GOLDEN BOSS · PORTE DE BOSS» (nombre comercial del catálogo: **Baron Golden Boss**; la app de
  administración sigue como «Sistema Oro» hasta que el dueño decida). Logo: monograma «BG» entrelazado en dorado con una
  estrella pequeña, «BARON» en mayúsculas finas con mucho espaciado, «— GOLDEN BOSS —» y «PORTE DE BOSS» en minúscula pequeña
  espaciada, sobre negro. Archivo: `assets/brand/logo.png` (150×150, fondo `#010101`; baja resolución: pedir el original).
- **Paleta** (`AppCatalogColors`): negro `#010101` (fondo = fondo del logo), carbón cálido `#12100D` (superficies), marfil
  `#F4EFE6` (texto), gris cálido `#A59C8C` (secundario), borde `#2B2620`, **dorado champán** `#C9A24A` (líneas, bordes,
  relleno pequeño), `#E6CB82` (texto dorado sobre negro, ≈11:1) y `#A8812F` (degradado). Sin azules ni amarillo plano.
- **Estilo fotográfico:** joyas de oro sobre manos y muñecas, luz cálida lateral, fondo oscuro difuminado o beige claro,
  logo BARON marcado arriba de la foto; etiqueta «ORO ITALIANO» con bandera en una esquina. La foto manda: cuadrícula de fotos
  grandes (cuadradas/verticales 4:5), esquinas casi rectas (radio 6) y poco espacio entre ellas; casi sin cajas ni texto.
- **Tipografía:** logo en sans fina, mayúsculas, tracking amplio (`BARON` con 6 px de espaciado en la cabecera); títulos Plus
  Jakarta Sans, cifras Inter.
- **Componentes:** botón primario dorado con texto negro (`Comprar`), secundario de contorno dorado (`Separar`), chips de
  categoría (elegido = dorado), plan de separado como bloque con línea dorada a la izquierda, franja de confianza fina con
  divisores, «Te la conseguimos» con borde dorado (no un bloque amarillo).

## 3. Resumen de decisiones visuales

| Tema | Decisión |
|---|---|
| Admin | Oscuro, limpio, acento dorado, splash con logo + nombre + frase + indicadores |
| Catálogo | **Oscuro, de marca «Baron Golden Boss»** (2026-10-20, decisión del dueño tras ver su Instagram @barongoldenboss): fondo negro profundo (el mismo del logo), carbón cálido en superficies, **dorado champán como único acento**; botón principal dorado con texto negro; fotos casi rectas y pegadas; sin fondo crema ni cajas beige; cabecera fija con logo + «BARON / GOLDEN BOSS» |
| Tarjeta | Foto sin borde, nombre completo, precio, etiqueta (NUEVO/SALE/ÚLTIMA UNIDAD/AGOTADO), botón al pasar el mouse |
| Listado | Cuadrícula de 4 en escritorio (`ResponsiveCards`: 1/2/3/4 según ancho), filtro, orden, contador de resultados |
| Detalle | Foto grande + miniaturas; comprar o separar (20 % calculado); caja gratis o decorada (+$12.000) |
| Confianza | Íconos de garantía/envío seguro (si el dueño confirma los textos) y botón flotante de WhatsApp |
| Aviso | «Te la conseguimos»: llamativo, lleva a WhatsApp de Barón |
| Movimiento | Minimalista: fundido + deslizamiento de 8 px, zoom corto de imagen; nada de rebotes (`motion.md`) |
| Tipografía | Plus Jakarta Sans en títulos, Inter en cuerpo y precios |

Nota: la base fija 3 columnas máximo en `ResponsiveCards`; la de 4 del catálogo es una decisión del proyecto
(se agrega al componente, no en la vista).
