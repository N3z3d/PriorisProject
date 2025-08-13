import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

class AppTheme {
  // ==================== COULEURS PREMIUM SOPHISTIQUÉES ====================
  static const Color primaryColor = Color(0xFF6B73FF); // Bleu professionnel moderne
  static const Color primaryVariant = Color(0xFF5A63E8); // Bleu professionnel foncé
  static const Color secondaryColor = Color(0xFF64748B); // Gris bleu sophistiqué
  static const Color secondaryVariant = Color(0xFF475569); // Gris bleu foncé
  static const Color accentColor = Color(0xFF8B5CF6); // Violet élégant
  static const Color accentSecondary = Color(0xFF10B981); // Vert succès raffiné
  
  // ==================== COULEURS SYSTÈME PREMIUM ====================
  static const Color successColor = Color(0xFF10B981); // Vert succès professionnel
  static const Color warningColor = Color(0xFFF59E0B); // Orange avertissement raffiné
  static const Color errorColor = Color(0xFFEF4444); // Rouge erreur moderne
  static const Color infoColor = Color(0xFF3B82F6); // Bleu information élégant
  
  // ==================== PALETTE DE GRIS MODERNE ====================
  static const Color grey50 = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);
  
  /// Couleur globale utilisée pour les dividers (alias de grey300)
  static const Color dividerColor = Color(0xFFCBD5E1);
  
  // ==================== COULEURS SURFACES PREMIUM ====================
  static const Color surfaceColor = Color(0xFFFEFEFE);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color glassmorphismBackground = Color(0x20FFFFFF);
  
  // ==================== COULEURS TEXTE OPTIMISÉES ====================
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // ==================== PROFESSIONAL SURFACE COLORS (GRADIENT-FREE) ====================
  // Professional solid color alternatives to replace gradients
  static const Color professionalSurfaceColor = Color(0xFFFAFAFA); // Clean surface
  static const Color professionalCardColor = Color(0xFFFFFFFF); // Pure white cards
  static const Color professionalGlassBackground = Color(0x15FFFFFF); // Glass effect replacement

  // ==================== SHADOWS PREMIUM ====================
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];
  
  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x15000000),
      blurRadius: 25,
      offset: Offset(0, 10),
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Color(0x20000000),
      blurRadius: 10,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  // ==================== THÈME PRINCIPAL PREMIUM ====================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        surface: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      
      // ==================== TYPOGRAPHIE MODERNE ====================
      textTheme: GoogleFonts.interTextTheme(
        _buildTextTheme(textPrimary),
      ),
      
      // ==================== APP BAR PREMIUM ====================
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        // Removed flexibleSpace from theme - apply in AppBar widget instead
        // For gradient, use in pages: AppBar(flexibleSpace: Container(decoration: BoxDecoration(gradient: ...)))
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
        actionsIconTheme: const IconThemeData(color: textPrimary),
      ),
      
      // ==================== CARTES PREMIUM ====================
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusTokens.modal),
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // ==================== BOUTONS PREMIUM ====================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: textOnPrimary,
          disabledBackgroundColor: grey200,
          disabledForegroundColor: textTertiary,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusTokens.modal,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.2);
            }
            return null;
          }),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusTokens.card,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusTokens.button,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // ==================== CHAMPS DE SAISIE ====================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadiusTokens.card,
          borderSide: const BorderSide(color: grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadiusTokens.card,
          borderSide: const BorderSide(color: grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadiusTokens.card,
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadiusTokens.card,
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadiusTokens.card,
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(color: textTertiary),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      
      // ==================== CHIPS ====================
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF3F4F6),
        selectedColor: primaryColor.withValues(alpha: 0.1),
        disabledColor: const Color(0xFFF9FAFB),
        labelStyle: const TextStyle(color: textPrimary),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusTokens.radiusXl,
        ),
        side: const BorderSide(color: grey300),
      ),
      
      // ==================== NAVIGATION BAR ====================
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // ==================== FLOATING ACTION BUTTON ====================
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      
      // ==================== DIVIDERS ====================
      dividerTheme: const DividerThemeData(
        color: grey300,
        thickness: 1,
        space: 1,
      ),
      
      // ==================== DIALOGS ====================
      dialogTheme: DialogThemeData(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
      ),
      
      // ==================== SNACKBAR ====================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusTokens.card,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
    );
  }

  // Removed darkTheme getter

  static TextTheme _buildTextTheme(Color textColor) {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
    );
  }

  // ==================== ANIMATIONS ====================
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  
  // ==================== ESPACEMENTS ====================
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // ==================== RAYONS DE BORDURE ====================
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;

  // ==================== BREAKPOINTS RESPONSIVE ====================
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double smallMobileBreakpoint = 320;
  static const double mediumMobileBreakpoint = 480;

  /// Vérifie si l'écran est très petit (mobile compact)
  static bool isSmallMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= smallMobileBreakpoint;
  }

  /// Vérifie si l'écran est mobile standard
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= mobileBreakpoint;
  }

  /// Vérifie si l'écran est tablette
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width > mobileBreakpoint && 
           MediaQuery.of(context).size.width <= tabletBreakpoint;
  }

  /// Vérifie si l'écran est desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width > tabletBreakpoint;
  }

  /// Retourne le padding adaptatif selon la taille d'écran
  static EdgeInsets getAdaptivePadding(BuildContext context) {
    if (isSmallMobile(context)) {
      return const EdgeInsets.all(8);
    } else if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// Retourne la taille de police adaptative
  static double getAdaptiveFontSize(BuildContext context, {double baseSize = 16}) {
    if (isSmallMobile(context)) {
      return baseSize * 0.8;
    } else if (isMobile(context)) {
      return baseSize;
    } else if (isTablet(context)) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.2;
    }
  }
} 
