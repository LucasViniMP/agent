import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Paleta Principal ─────────────────────────────────────────────
  // Inspirada em restaurantes sofisticados: carvão, cobre, creme, vinho
  static const Color charcoal    = Color(0xFF101417); // fundo escuro principal
  static const Color charcoal2   = Color(0xFF182226); // superficie secundaria
  static const Color charcoal3   = Color(0xFF314852); // bordas / divisores
  static const Color copper      = Color(0xFF2DD4BF); // acento primario
  static const Color copperLight = Color(0xFF8CECCF); // acento claro
  static const Color cream       = Color(0xFFF8FAFC); // texto principal
  static const Color creamDark   = Color(0xFFE2E8F0); // superficie clara secundaria
  static const Color wine        = Color(0xFFE11D48); // erro / destaque critico
  static const Color sage        = Color(0xFF22C55E); // sucesso
  static const Color amber       = Color(0xFFFACC15); // atencao
  static const Color textLight   = Color(0xFFD7DEE5); // texto secundario
  static const Color textMuted   = Color(0xFF8BA3AD); // texto desabilitado

  // ── Status Colors ─────────────────────────────────────────────────
  static const Color pending   = amber;
  static const Color preparing = Color(0xFF38BDF8);
  static const Color ready     = sage;
  static const Color delivered = textMuted;
  static const Color canceled  = wine;

  // ── Theme principal (escuro, sofisticado) ─────────────────────────
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: copper,
        onPrimary: charcoal,
        secondary: copperLight,
        onSecondary: charcoal,
        surface: charcoal2,
        onSurface: cream,
        error: wine,
        onError: cream,
        outline: charcoal3,
      ),
      scaffoldBackgroundColor: charcoal,
      textTheme: GoogleFonts.cormorantGaramondTextTheme().copyWith(
        displayLarge: GoogleFonts.cormorantGaramond(
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
          color: cream,
        ),
        titleLarge: GoogleFonts.cormorantGaramond(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: cream,
          fontSize: 22,
        ),
        titleMedium: GoogleFonts.cormorantGaramond(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: cream,
          fontSize: 18,
        ),
        bodyLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          color: cream,
          fontSize: 14,
        ),
        bodyMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          color: textLight,
          fontSize: 13,
        ),
        labelSmall: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
          color: textMuted,
          fontSize: 9,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: charcoal2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: charcoal3, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: charcoal3, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: copper, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          fontSize: 10,
          color: textMuted,
        ),
        hintStyle: GoogleFonts.inter(
          color: charcoal3,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: copper,
          foregroundColor: charcoal,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            fontSize: 11,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: charcoal2,
        foregroundColor: cream,
        elevation: 0,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          letterSpacing: 0.5,
          color: cream,
        ),
      ),
      dividerColor: charcoal3,
      cardColor: charcoal2,
    );
  }

  // ── Sombra cobre suave ─────────────────────────────────────────────
  static List<BoxShadow> copperGlow = const [
    BoxShadow(
      color: Color(0x332DD4BF),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> subtleShadow = const [
    BoxShadow(
      color: Color(0x40000000),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  static List<BoxShadow> cardShadow = const [
    BoxShadow(
      color: Color(0x60000000),
      offset: Offset(0, 4),
      blurRadius: 20,
    ),
  ];

  // ── Bordas ────────────────────────────────────────────────────────
  static Border border({Color color = charcoal3, double width = 1.5}) =>
      Border.all(color: color, width: width);

  static Border borderBottom({Color color = charcoal3, double width = 1.5}) =>
      Border(bottom: BorderSide(color: color, width: width));

  static Border borderTop({Color color = charcoal3, double width = 1.5}) =>
      Border(top: BorderSide(color: color, width: width));

  // ── Decoração para cards ──────────────────────────────────────────
  static BoxDecoration cardDecoration({
    Color? bg,
    bool hasBorder = true,
    bool hasShadow = false,
    double radius = 8,
  }) =>
      BoxDecoration(
        color: bg ?? charcoal2,
        borderRadius: BorderRadius.circular(radius),
        border: hasBorder ? border() : null,
        boxShadow: hasShadow ? cardShadow : null,
      );

  // ── Status ────────────────────────────────────────────────────────
  static Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':   return pending;
      case 'PREPARING': return preparing;
      case 'READY':     return ready;
      case 'DELIVERED': return delivered;
      case 'CANCELED':  return canceled;
      default:          return textMuted;
    }
  }

  static String statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':   return 'PENDENTE';
      case 'PREPARING': return 'PREPARANDO';
      case 'READY':     return 'PRONTO';
      case 'DELIVERED': return 'ENTREGUE';
      case 'CANCELED':  return 'CANCELADO';
      default:          return status;
    }
  }

  // ── Gradiente de fundo decorativo ────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [charcoal, Color(0xFF102A2D), charcoal2],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient copperGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [copper, copperLight],
  );
}
