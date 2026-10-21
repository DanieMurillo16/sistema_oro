import 'package:flutter/material.dart';

/// Medidas de la app: espaciados, radios, alturas, anchos y puntos de quiebre.
/// Las vistas usan estos valores en vez de números sueltos. Los colores van en
/// `AppColors` y los estilos de texto en `AppTextTheme`.
abstract final class DesignTokens {
  // Espaciado
  static const double spaceXxs = 2;
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const EdgeInsets pagePadding = EdgeInsets.all(spaceLg);

  /// Margen de página según el ancho: 16 en teléfono (más sitio para el
  /// contenido) y 24 desde tablet.
  static EdgeInsets pagePaddingFor(double width) =>
      width < compactLayoutWidth ? const EdgeInsets.all(spaceMd) : pagePadding;

  // Radios de borde
  static const double radiusSm = 8;
  static const double radiusMd = 12; // campos y botones
  static const double radiusLg = 20; // tarjetas y diálogos
  static const double radiusPill = 999;

  /// Esquinas de las fotos del catálogo: casi rectas, como en la marca.
  static const double catalogPhotoRadius = 6;

  // Alturas y tamaños de controles
  static const double buttonHeight = 52;
  static const double dialogButtonHeight = 44;
  static const double controlMinHeight = 48;
  static const double actionSize = 40;
  static const double actionIconSize = 20;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 28;
  static const double avatarSize = 44;
  static const double progressSize = 20;
  static const double placeholderIconSize = 56;
  static const double logoSize = 72;
  static const double thumbSize = 56; // foto de prenda en listas
  static const double miniThumbSize = 48; // mini foto dentro de una ficha
  static const double galleryThumbSize = 88; // fotos del detalle de una prenda
  static const double summaryThumbSize =
      72; // foto en la tarjeta resumen del pedido
  static const double heroThumbSize = 96; // foto de prenda en un detalle
  static const double brandMarkSize = 104; // icono de marca del splash
  static const double pageDotSize = 8;
  static const double pageDotActiveWidth = 24;
  static const double splashTextMaxWidth = 280;
  static const double receiptLoaderHeight = 160;
  static const double receiptMaxHeight = 480;
  static const double stackedTitleWidth = 240;
  static const double galleryMaxHeightFactor = 0.45;
  static const double chipTouchHeight = 44;
  static const double listDialogHeight = 320;
  static const double headerMarkSize = 36; // marca en la cabecera del catálogo
  static const double catalogHeaderWideHeight = 76; // cabecera fija en ancho
  static const double catalogHeaderNarrowHeight = 134; // y en teléfono
  // Cuánto crece el alto por cada punto de escala de texto (lo único que crece
  // es el texto: el logo y los chips casi no).
  static const double catalogHeaderWideGrowth = 30;
  static const double catalogHeaderNarrowGrowth = 45;
  static const double catalogHeaderSideReserve = 240; // marca y chat, en ancho
  static const double brandLogoPreviewSize =
      140; // vista previa del logo en Ajustes
  static const double catalogSortWidth = 240;
  static const double quantityWidth = 36;
  static const double quantityButton = 36; // − y + de la cantidad
  static const double catalogBannerTextWidth = 520;
  static const double catalogThreeColumnsWidth = 700;
  static const double catalogFourColumnsWidth = 1000;

  // Anchos máximos y mínimos
  static const double dialogMaxWidth = 520;
  static const double dialogMaxHeight = 720;
  static const double contentMaxWidth = 1200;
  static const double catalogMaxWidth =
      1320; // el catálogo público aprovecha más ancho
  static const double loginMaxWidth = 420;
  static const double toastMaxWidth = 460;
  static const double menuMaxHeight = 260;
  static const double emptyActionMaxWidth = 280;
  static const double navigationRailWidth = 240;
  static const double formPairMinWidth = 280; // pareja de campos M
  static const double formShortPairMinWidth = 240; // pareja de campos XS/S
  static const double kpiMinWidth = 320;
  static const double kpiSlideWidth = 260;

  // Puntos de quiebre (ver ~/.claude/flutter-base/responsive.md)
  static const double compactLayoutWidth = 600; // < 600: teléfono
  static const double wideLayoutWidth = 900; // >= 900: menú lateral y tablas
  static const double expandedLayoutWidth = 1100; // >= 1100: 3 columnas

  // Espacio libre al final de una lista para que el botón flotante no tape el
  // último ítem.
  static const double listBottomSpace = 100;

  // Duraciones de animación
  static const Duration animationFast = Duration(milliseconds: 180);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationNumber = Duration(milliseconds: 500);

  // Curva por defecto de todas las animaciones (entrada suave, sin rebote).
  static const Curve curve = Curves.easeOutCubic;
}
