# Sistema Oro — administración y catálogo público de joyería en oro

App para **Barón**, que vende joyería en oro (cadenas, pulseras, dijes, topos…). Son **dos piezas con los mismos
datos**, en un solo código Flutter:

1. **Administración** (iOS / Android / web; oscura): Barón y quien él autorice crean y editan prendas, ven
   pedidos y solicitudes, separados, abonos y clientes.
2. **Catálogo público** (Flutter web, sin login; elegante y claro): UN solo enlace general con todo el inventario.
   El cliente elige una prenda, la compra o la separa (nombre y WhatsApp solo en ese momento) y sube la captura de
   la transferencia. Barón lo ve en «Pedidos».

Hereda las reglas de `~/.claude/CLAUDE.md` y la base de `~/.claude/flutter-base/` (diseño, diálogos, formularios,
responsive, pruebas, web). Aquí va **solo lo propio del proyecto**.

> **Antes de tocar nada** lee [`docs/PROGRESO_FLUTTER.md`](docs/PROGRESO_FLUTTER.md) (en qué paso va el chat Flutter) y [`docs/ESTADO.md`](docs/ESTADO.md): dónde vamos, qué sigue y qué está pendiente de
> decidir. El negocio y las reglas de dinero están en [`docs/NEGOCIO.md`](docs/NEGOCIO.md); las referencias de
> diseño (las capturas no pasan entre chats) en [`docs/DISENO_REFERENCIAS.md`](docs/DISENO_REFERENCIAS.md).

## Estructura

```
lib/
  core/        config, errors, network (un solo Dio), router, services (AppToast), theme, utils
  features/<x>/{data,models,providers,utils,widgets,<x>_screen.dart}
  shared/      widgets reutilizables (diálogos, formularios, tarjetas), navigation
  main.dart             entrada de la administración (con login)
  main_catalogo.dart    entrada del catálogo público, compilada aparte: sin código de administración
```

Features previstas (admin): `garments` (prendas), `orders` (pedidos y solicitudes), `layaways` (separados y
abonos), `clients`, `users` (usuarios y permisos), `settings` (caja, WhatsApp, datos de transferencia).
Catálogo público: `catalog` (solo lectura) y `checkout` (comprar / separar / comprobante), con modelos **públicos**
que no tienen precio de compra.

## Reglas propias

- Riverpod a mano + go_router + un solo Dio. Sin domain/usecases/codegen/freezed.
- Nombres de archivos y clases en inglés; textos de UI y errores en español; llaves JSON del backend no se tocan.
- **El precio de compra es PRIVADO.** Nunca viaja en un endpoint público ni existe en un modelo del catálogo. En el
  admin solo se ve con el permiso `prendas.ver_costo`.
- **Dinero de separados**: se calcula en SQL/`utils/*_rules.dart`, nunca en la vista. Reglas en `docs/NEGOCIO.md`
  (20 % para separar, abonos libres, plazo de 1 mes, recargo de $80.000 por mes vencido sobre el saldo). Dinero:
  `DECIMAL` como texto, solo con los formateadores de `core/utils`.
- La prenda separada o vendida **sale del catálogo**; si el separado se cancela, **vuelve a publicarse**.
- Imágenes: el servidor genera **miniatura y grande** al subirlas; la BD guarda las URLs. El catálogo usa la
  miniatura en la cuadrícula y la grande en el detalle.
- El catálogo público no pide login: nombre y WhatsApp solo al comprar/separar. Endpoints públicos aparte de los del
  admin, con límite por IP y validación estricta de la imagen del comprobante.
- Datos compartidos: un dato vive en un solo provider (`upsert`/`invalidate`), ver `flutter-base/architecture.md`.
- **Tipografía (decisión del proyecto, distinta a la base):** dos familias **empaquetadas** (nunca `google_fonts`
  en ejecución): `Inter` para cuerpo, precios y tablas (`AppTheme.fontFamily`) y `PlusJakartaSans` para títulos
  (`AppTextTheme.displayFontFamily`, solo headlineSmall/titleLarge/titleMedium).
- Toda vista nueva: skill `flutter-ui` + agentes `flutter-ui-reviewer` y `flutter-tester` al terminar.
- **No agregar paquetes sin preguntar.** Aprobados: `image_picker`, `url_launcher`.

## Backend (API + base de datos)

- **Carpeta:** `backend/` (PHP + MariaDB; dentro de la app, ignorada por git). Su `CLAUDE.md` tiene las reglas.
  Estructura: `php/` (lo que se sube) · `sql/` (lo que se importa) · `entregas/` (paquetes por cambio) · `docs/`.
- **Bitácora:** `backend/docs/REGISTRO.md` — qué se hizo, estado de cada entrega y **qué sigue para Flutter**.
  Léela al empezar.
- **Contrato (única fuente de verdad):** `backend/docs/API.md`. `ApiEndpoints` refleja sus filas; comprobar con
  `python3 -I ~/.claude/flutter-base/tools/api_sync_check.py backend/docs/API.md lib/core/network/api_endpoints.dart backend`.
- **Servidor:** `public_html/bd_oro/` · **URL base:** `https://cobros.com.co/bd_oro/` ·
  **BD:** `u668681301_oro`.
- **Credenciales:** `privado/oro.php` fuera de `public_html`; nunca en git ni en la app.
- La app envía `Authorization: Bearer TOKEN`; la identidad sale del token, **nunca** de un id enviado por la app.
- **Si falta un dato o endpoint:** no modifiques el backend a mano ni leas el esquema. Escribe el pedido (pantalla,
  datos que entran y salen, filtros, reglas) y llama al subagente **`backend-builder`**: hace BD + PHP, prueba,
  genera **un paquete** en `entregas/` y devuelve el contrato. Junta varios pedidos en un solo paquete.
  Nada se marca «instalado» sin que yo lo confirme.

## Comandos

```bash
flutter run -d chrome --dart-define=API_BASE_URL=https://cobros.com.co/bd_oro/
flutter analyze
flutter test
bash scripts/build_web.sh --dart-define=API_BASE_URL=https://cobros.com.co/bd_oro/   # web con Wasm
```

`API_BASE_URL` va por `--dart-define` (o `.env.json`, ignorado por git); nunca en el código. El catálogo se compila con
`bash scripts/build_catalogo.sh --dart-define=API_BASE_URL=...` (salida `build/catalogo`, `index.html` propio en `web_catalogo/`).

## Identidad visual

- Fuentes: Inter (cuerpo) + Plus Jakarta Sans (títulos), empaquetadas en `assets/fonts/`.
- Color de marca: dorado envejecido `#8A6A2F` (`AppColors.primary`; contraste ≈ 5:1 con texto blanco).
- Administración **oscura** (como «Cuentas Claras») con splash propio; catálogo **claro y elegante**. El starter solo
  trae tema claro: los tokens oscuros se agregan en el primer chat Flutter (ver `docs/ESTADO.md`).
- El resto del diseño sale de la base (`AppColors`, `AppTheme`, `DesignTokens`).
