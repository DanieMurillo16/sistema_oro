# Negocio — Sistema Oro

Cliente: **Barón**, vende joyería en oro (cadenas, pulseras, dijes, topos; debe poder crecer a anillos, aretes…).
Hoy no alcanza a responder cliente por cliente por WhatsApp porque está muy ocupado: el sistema recibe la compra o
el separado con el comprobante ya adjunto, y él solo lo revisa.

## Vocabulario

| Término | Significa |
|---|---|
| **Prenda** | Una joya en venta (nombre, tipo, peso, medidas, tipo de oro, precios, imágenes) |
| **Tipo** | Categoría de prenda (pulseras, cadenas, dijes, topos…). Es un catálogo que crece, no una lista fija |
| **Tipo de oro** | Nacional o italiano |
| **Pedido** | Compra directa de una prenda: cliente + prenda + caja + comprobante de transferencia |
| **Solicitud** | Compra o separado enviado desde el catálogo, con comprobante: entra **PENDIENTE** y Barón la confirma o rechaza |
| **Te la conseguimos** | Aviso del catálogo para quien no encuentra la prenda: abre WhatsApp con Barón (no se guarda en la BD) |
| **Separado** | Prenda apartada para un cliente que pagó el 20 % y abona hasta completar el 100 % |
| **Abono** | Cada pago que el cliente hace sobre un separado |
| **Saldo** | Lo que falta por pagar de un separado (incluye recargos por mes vencido) |
| **Caja** | Empaque de la compra: la gratis que trae, o una decorada (+$12.000) |
| **Comprobante** | Imagen (captura) de la transferencia que sube el cliente |

## Roles y permisos (propuesta; ver `docs/ESTADO.md`)

- **Dueño (Barón):** todo.
- **Empleado (quien Barón autorice):** ver pedidos y registrar abonos. **Sin** precio de compra, sin cancelar
  separados, sin administrar usuarios. Permisos por operación `modulo.accion`, por ejemplo `prendas.ver_costo`.
- **Cliente (catálogo público):** sin cuenta ni login. Solo deja nombre y WhatsApp al comprar o separar.

## Prenda

Campos: nombre · tipo · peso (g) · medidas (cm) · tipo de oro (nacional / italiano) · **precio de venta** ·
**precio de compra (PRIVADO)** · ~3 imágenes.

- **El precio de compra nunca sale en el catálogo**: ni en la respuesta de la API pública ni en un modelo del
  catálogo.
- Imágenes: se guardan en el servidor en **dos tamaños** (miniatura y grande) al subirlas; la BD guarda las URL.
- **Disponibilidad = unidades libres (`stock`)**, no un estado. Una solicitud pendiente, un separado o una compra
  reservan una unidad; si se rechaza o se cancela, vuelve. Solo con unidades libres aparece en el catálogo.
- **Medidas:** largo (cm), ancho (cm) y grosor (mm), todos opcionales. **Etiquetas:** NUEVO (automático, 30 días, ajustable),
  SALE (si tiene `precio_anterior` mayor al de venta), ÚLTIMA UNIDAD (queda 1) y AGOTADO (0).
- **Cantidad (decisión del dueño, 19/oct/2026):** el modelo permite cantidad por prenda, aunque hoy casi todo sea 1 y
  en el futuro pueda crecer. «ÚLTIMA UNIDAD» = queda 1; «AGOTADO» = 0. Una prenda separada reserva una unidad.

## Compra directa (pedido)

1. El cliente abre el catálogo, elige una prenda y toca comprar.
2. Elige caja: **gratis** o **decorada (+$12.000)**.
3. Deja nombre y WhatsApp, y sube la captura de la transferencia.
4. Barón ve en «Pedidos»: qué cliente quiere qué prenda, la imagen del comprobante y sus datos.

## Solicitud, estados y entrega (decisiones de 19/oct/2026)

- Toda compra o separado del catálogo entra **PENDIENTE** (con nombre, WhatsApp y comprobante). La unidad se **reserva al
  enviar**; si Barón **rechaza** vuelve al catálogo y el pago inicial se anula (él devuelve el dinero por fuera). Si dos
  clientes eligen la misma pieza a la vez, gana el primero y el otro ve «ya no está disponible».
- **Compra:** PENDIENTE → CONFIRMADO → (ENVIADO, con guía opcional) → ENTREGADO. **Separado:** PENDIENTE → ACTIVO → PAGADO
  (automático al cubrir el total) → (ENVIADO) → ENTREGADO. Ambos pueden ser RECHAZADO (desde PENDIENTE) o CANCELADO.
- **Entrega:** el pedido guarda si el cliente recoge o se envía; si se envía, ciudad y dirección. Sin costo de envío en el sistema.
- **Quién puede qué:** el empleado ve pedidos y clientes y registra abonos; confirmar/rechazar, entregar, cancelar y anular
  pagos son del dueño (dar más poder al empleado es agregarle un permiso).
- **Contra el spam:** comprobante obligatorio, máximo 3 solicitudes pendientes por WhatsApp y 10 envíos por hora por IP.
- **Ajustes editables** (con auditoría): WhatsApp de Barón, datos de transferencia, % de separado (20), recargo por mes
  vencido (80.000) y precio de la caja decorada (12.000). Al crear un pedido se **guarda una copia** del precio, la caja, el
  % y el recargo aplicados: cambiar los ajustes después no altera pedidos ya creados.

## Separado — reglas confirmadas

- Para separar se paga el **20 % del valor de venta** de la prenda.
- Después el cliente abona **las veces que quiera** sobre el valor de la prenda, hasta pagar el **100 %**. Lo ideal es
  que la pague en un solo mes.
- **La prenda NO se entrega hasta que esté pagada completa.** Cuando paga todo se la lleva.
- **Plazo máximo: 1 mes.** Si termina el mes y no ha completado el pago, se suman **$80.000 al saldo** y se le da
  otro mes. Esto se repite **por cada mes vencido**. No hay recargo al separar, solo por mes vencido.
- La prenda separada **deja de aparecer en el catálogo**.
- Si el cliente nunca paga, Barón **cancela el separado desde el sistema** y la prenda **vuelve a publicarse**.

### Ejemplo (confirmado por el dueño, 19/oct/2026)

Prenda de $1.000.000:

| Momento | Pagado | Saldo |
|---|---|---|
| Separa con el 20 % | $200.000 | $800.000 |
| Al mes, el cliente había abonado hasta dejar $500.000 por pagar | $500.000 | $500.000 |
| Mes vencido: +$80.000 al saldo, empieza otro mes | $500.000 | **$580.000** |

Total a pagar = precio de venta + recargos acumulados. El 20 % se calcula solo sobre el precio.

### Supuestos (asumidos; el dueño confirmó el ejemplo, no cada supuesto)

- El mes corre desde la fecha en que **Barón confirma** el separado (19 oct → 19 nov); si el día no existe en el mes
  siguiente, cae el último día. El mismo día del vencimiento todavía se puede pagar sin recargo.
- El recargo se calcula **al consultar** (derivado de las fechas), sin depender de un cron; así no hay recargos
  duplicados ni perdidos si el servidor no corre una tarea.
- Un mes vencido recarga **una vez** aunque el cliente haya abonado algo en ese mes.
- Cada abono se registra con fecha, monto, medio y comprobante; nunca se borra, solo se anula (solo el dueño anula).
- La caja decorada se suma al total a pagar del separado, pero **no** entra en el cálculo del 20 %.
- Un abono no puede superar lo que falta por pagar.

### Cancelación de un separado (decisión del dueño, 19/oct/2026)

**Lo que ya abonó el cliente lo decide Barón caso por caso.** Al cancelar elige una de: *se queda todo* · *se devuelve
todo* · *se devuelve una parte (monto)*, y escribe el motivo. El sistema debe **registrar esa decisión** en el
separado: qué se decidió, cuánto se retuvo, cuánto se devolvió, quién la tomó y cuándo (historial inmutable: decisión, monto retenido, monto devuelto, motivo, quién y cuándo). La unidad vuelve al catálogo. Solo el
dueño puede cancelar; también aplica a una compra ya confirmada que no se entregó.

## «Te la conseguimos»

Aviso llamativo en el catálogo, para quien no encuentra la prenda: lleva a escribirle a Barón por WhatsApp con un
mensaje ya armado. **El número de WhatsApp de Barón es un dato de configuración que él edita desde la app** (BD +
pantalla de ajustes), nunca en el código; el catálogo lo lee de la API pública. Igual los datos de la transferencia
(banco, cuenta, titular) y el texto de la caja decorada/precio: ajustes editables.

## Datos que se guardan del cliente

Nombre y WhatsApp, solo cuando compra o separa (sin cuenta). Un mismo cliente se reconoce por WhatsApp para juntar
sus pedidos y separados en la ficha de **Clientes** del admin. Son datos personales: no se muestran en el catálogo.

## Flujo (una línea)

`catálogo público → pedido/separado (con comprobante) → «Pedidos» en el admin → Barón confirma → abonos → entrega`

## Riesgos a cuidar desde el diseño

- Dos clientes eligiendo la misma prenda a la vez: el backend decide quién gana (transacción), el otro ve
  «ya no está disponible».
- Endpoints públicos que reciben archivos: límite de tamaño, validar que sea imagen real, nombre generado por el
  servidor, límite por IP y campo trampa (honeypot) contra spam.
- Enlace general y vista previa de WhatsApp: título, descripción e imagen son estáticos en `index.html` del
  catálogo (el rastreador no ejecuta Flutter).


## Marca (catálogo público) — 2026-10-20
- **Nombre comercial:** **Baron Golden Boss** («BARON · GOLDEN BOSS · PORTE DE BOSS»). Instagram: @barongoldenboss (perfil «VENTAS 🇨🇴»).
  La app de administración puede seguir llamándose «Sistema Oro».
- **Logo:** monograma «BG» dorado entrelazado + «BARON» / «— GOLDEN BOSS —» / «PORTE DE BOSS» sobre negro (`assets/brand/logo.png`).
  El dueño podrá **cambiarlo desde Ajustes** de la administración y se refleja en el catálogo sin recompilar (ver `docs/ESTADO.md`).
- **Paleta:** negro profundo y marrones cálidos muy oscuros, **dorado champán** (cepillado, no amarillo plano) como único acento,
  marfil para el texto.
- **Estilo fotográfico:** joyas de oro sobre manos y muñecas, luz cálida lateral, fondo oscuro difuminado o beige claro, logo BARON
  arriba de la foto y etiqueta «ORO ITALIANO» con bandera; fotos grandes verticales/cuadradas que mandan sobre el texto.
- **Tono:** «Porte de boss»: elegante, seguro y directo; no se promete lo que el negocio no hace (sin «garantizado/verificado»).
