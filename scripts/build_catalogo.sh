#!/usr/bin/env bash
# Compila el catálogo público (lib/main_catalogo.dart) en build/catalogo.
#
# Uso:
#   bash scripts/build_catalogo.sh --dart-define=API_BASE_URL=...
#   CATALOGO_BASE_HREF=/ bash scripts/build_catalogo.sh ...   (si va en la raíz)
#
# Reutiliza build_web.sh (Wasm, Brotli, verificaciones) y solo cambia lo propio
# del catálogo: la entrada, la carpeta de salida y el index.html, que trae la
# vista previa de WhatsApp (web_catalogo/index.html). La administración sigue
# saliendo de scripts/build_web.sh con el index.html de web/.
set -euo pipefail
cd "$(dirname "$0")/.."

base_href=${CATALOGO_BASE_HREF:-/}   # el catálogo vive en la raíz de oro.murillocode.com
# oro.murillocode.com recomprime los .br (Brotli doble): se sube plano (BROTLI=0).
BROTLI=${BROTLI:-0} bash scripts/build_web.sh -t lib/main_catalogo.dart --base-href "$base_href" \
  --output build/catalogo "$@"

# Flutter solo sustituye $FLUTTER_BASE_HREF en el index.html; se hace aquí.
sed "s#\$FLUTTER_BASE_HREF#$base_href#" web_catalogo/index.html > build/catalogo/index.html
if grep -q 'FLUTTER_BASE_HREF' build/catalogo/index.html; then
  echo "Error: quedó \$FLUTTER_BASE_HREF sin sustituir en build/catalogo/index.html." >&2
  exit 1
fi
if grep -q 'TU-DOMINIO' build/catalogo/index.html; then
  echo "Aviso: build/catalogo/index.html aún tiene TU-DOMINIO (vista previa de WhatsApp). Pon el dominio real en web_catalogo/index.html antes de subir."
fi
# Manifiesto propio del catálogo (nombre comercial y colores de la marca).
cp web_catalogo/manifest.json build/catalogo/manifest.json

# Imagen de la vista previa de WhatsApp (og:image).
if [ -f web_catalogo/og-catalogo.jpg ]; then
  cp web_catalogo/og-catalogo.jpg build/catalogo/og-catalogo.jpg
else
  echo "Aviso: falta web_catalogo/og-catalogo.jpg (1200x630); WhatsApp no mostrará imagen en la vista previa."
fi
echo "Catálogo listo en build/catalogo: sube su CONTENIDO completo."
