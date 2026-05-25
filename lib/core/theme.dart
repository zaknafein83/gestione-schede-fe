import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Seed color del tema. DeepPurple resta la nostra "anima viola".
const Color _seed = Colors.deepPurple;

/// Accento oro usato come [ColorScheme.tertiary] e per dettagli decorativi
/// (bordi card, evidenziazioni, glow). Coerente con la landing fantasy.
const Color _gold      = Color(0xFFD4AF37);
const Color _goldSoft  = Color(0xFFE6C56C);

/// Tonalità scure per il dark theme — più "atmosferiche" del dark Material
/// di default, in linea con la palette della landing.
const Color _darkInk     = Color(0xFF0F0A1C); // sfondo principale
const Color _darkSurface = Color(0xFF1A1330); // surface (card, dialog)
const Color _darkAppBar  = Color(0xFF1E1240); // app bar leggermente più viola

/// Font display fantasy. Esportato come costante così la landing e altre
/// schermate possono usarlo direttamente quando serve (es. CustomPaint).
const String kFontDisplay = 'Cinzel';

// ===========================================================================
//                              Builders
// ===========================================================================

ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: _seed,
    tertiary:  _gold,
    onTertiary: Colors.black,
  );
  return _baseTheme(scheme: scheme, isDark: false);
}

ThemeData buildDarkTheme() {
  // Dark "fantasy": colorScheme custom che parte da deepPurple ma usa i
  // nostri ink/surface scuri al posto del dark di default (troppo neutro).
  final base = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
    tertiary:  _goldSoft,
    onTertiary: Colors.black,
  );
  final scheme = base.copyWith(
    surface:                _darkSurface,
    surfaceContainerLowest: _darkInk,
    surfaceContainerLow:    _darkInk,
    surfaceContainer:       _darkSurface,
    surfaceContainerHigh:   const Color(0xFF22183D),
    surfaceContainerHighest:const Color(0xFF2A1E48),
    outlineVariant:         _goldSoft.withValues(alpha: 0.20),
  );
  return _baseTheme(scheme: scheme, isDark: true);
}

// ===========================================================================
//               Tema base condiviso (typography + componenti)
// ===========================================================================

ThemeData _baseTheme({required ColorScheme scheme, required bool isDark}) {
  // TextTheme custom: Cinzel SOLO per i titoli, font di sistema per il body.
  // Questo è il pattern standard per i giochi fantasy (Skyrim, BG3, ecc.):
  // display per titoli, sans-serif per testo a runtime / paragrafi.
  final base    = isDark ? Typography.whiteCupertino : Typography.blackCupertino;
  final onSurf  = scheme.onSurface;
  final onSurfDim = scheme.onSurface.withValues(alpha: 0.80);

  TextStyle display(double size, {FontWeight weight = FontWeight.w700, double spacing = 1.2}) =>
      TextStyle(
        fontFamily:    kFontDisplay,
        fontSize:      size,
        fontWeight:    weight,
        letterSpacing: spacing,
        color:         onSurf,
        height:        1.15,
      );

  final textTheme = base.copyWith(
    // Display: usati raramente, ma se usati siano monumentali
    displayLarge:   display(56, weight: FontWeight.w800),
    displayMedium:  display(45, weight: FontWeight.w800),
    displaySmall:   display(36, weight: FontWeight.w700),
    // Headline: usati per titoli pagina, dialog title, ecc.
    headlineLarge:  display(32, weight: FontWeight.w700),
    headlineMedium: display(28, weight: FontWeight.w700),
    headlineSmall:  display(24, weight: FontWeight.w700, spacing: 1.0),
    // Title: AppBar usa titleLarge di default; carta-/section-headers usano gli altri
    titleLarge:     display(20, weight: FontWeight.w700, spacing: 0.8),
    titleMedium:    display(16, weight: FontWeight.w700, spacing: 0.6),
    titleSmall:     display(14, weight: FontWeight.w700, spacing: 0.5),
    // Body resta sui font di sistema (default) — Cinzel su paragrafi è illeggibile.
    bodyLarge:  base.bodyLarge?.copyWith(color: onSurf),
    bodyMedium: base.bodyMedium?.copyWith(color: onSurf),
    bodySmall:  base.bodySmall?.copyWith(color: onSurfDim),
    // Label dei bottoni: Cinzel piccolo con letterSpacing.
    labelLarge: TextStyle(
      fontFamily:    kFontDisplay,
      fontSize:      14,
      fontWeight:    FontWeight.w700,
      letterSpacing: 1.2,
      color:         onSurf,
    ),
    labelMedium: TextStyle(
      fontFamily:    kFontDisplay,
      fontSize:      12,
      fontWeight:    FontWeight.w600,
      letterSpacing: 1.0,
      color:         onSurfDim,
    ),
    labelSmall: TextStyle(
      fontFamily:    kFontDisplay,
      fontSize:      11,
      fontWeight:    FontWeight.w600,
      letterSpacing: 0.8,
      color:         onSurfDim,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme:  scheme,
    textTheme:    textTheme,
    scaffoldBackgroundColor: isDark ? _darkInk : null,

    // ---------------- AppBar ----------------
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? _darkAppBar : scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation:       0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily:    kFontDisplay,
        fontSize:      20,
        fontWeight:    FontWeight.w700,
        letterSpacing: 1.5,
        color:         scheme.onSurface,
      ),
      // Sottile bordo dorato a piè dell'AppBar — segna stilisticamente la
      // separazione dal contenuto senza ricorrere a ombra.
      shape: Border(
        bottom: BorderSide(
          color: _gold.withValues(alpha: isDark ? 0.32 : 0.20),
          width: 1,
        ),
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
    ),

    // ---------------- TabBar ----------------
    tabBarTheme: TabBarThemeData(
      labelStyle: TextStyle(
        fontFamily:    kFontDisplay,
        fontSize:      13,
        fontWeight:    FontWeight.w700,
        letterSpacing: 1.0,
        color:         scheme.primary,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily:    kFontDisplay,
        fontSize:      13,
        fontWeight:    FontWeight.w500,
        letterSpacing: 1.0,
        color:         scheme.onSurfaceVariant,
      ),
      indicatorColor: _gold,
      dividerColor:   _gold.withValues(alpha: 0.15),
    ),

    // ---------------- Bottoni: label in Cinzel ----------------
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily:    kFontDisplay,
          fontSize:      14,
          fontWeight:    FontWeight.w700,
          letterSpacing: 1.0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily:    kFontDisplay,
          fontSize:      14,
          fontWeight:    FontWeight.w600,
          letterSpacing: 1.0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily:    kFontDisplay,
          fontSize:      13,
          fontWeight:    FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    ),

    // ---------------- Card ----------------
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: _gold.withValues(alpha: isDark ? 0.22 : 0.18),
          width: 1,
        ),
      ),
      color: scheme.surface,
    ),

    // ---------------- Dialog ----------------
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _gold.withValues(alpha: isDark ? 0.30 : 0.18),
          width: 1,
        ),
      ),
      titleTextStyle: TextStyle(
        fontFamily:    kFontDisplay,
        fontSize:      20,
        fontWeight:    FontWeight.w700,
        letterSpacing: 1.0,
        color:         scheme.onSurface,
      ),
      contentTextStyle: TextStyle(
        fontSize: 14,
        height:   1.5,
        color:    scheme.onSurface.withValues(alpha: 0.9),
      ),
    ),

    // ---------------- Input field ----------------
    // Body/form: niente Cinzel (leggibilità). Solo label e helper
    // restano sui font di sistema; helper può avere un leggero touch fantasy
    // ma lo lasciamo neutro per non rovinare l'editor.
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
    ),

    // ---------------- Chip / Snackbar piccoli touches ----------------
    chipTheme: ChipThemeData(
      labelStyle: const TextStyle(
        fontFamily:    kFontDisplay,
        fontSize:      12,
        fontWeight:    FontWeight.w600,
        letterSpacing: 0.5,
      ),
      side: BorderSide(color: _gold.withValues(alpha: 0.25)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? _darkSurface : null,
      contentTextStyle: TextStyle(color: scheme.onSurface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: _gold.withValues(alpha: 0.25)),
      ),
    ),
  );
}

// ===========================================================================
//                              ThemeMode notifier
// ===========================================================================

const _storageKey = 'ui.theme_mode';

/// Notifier che espone la preferenza di tema (light/dark/system) e la
/// persiste in flutter_secure_storage. Bootstrap async: parte da
/// `ThemeMode.system` e aggiorna quando lo storage viene letto.
class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  final _storage = const FlutterSecureStorage();

  @override
  Future<ThemeMode> build() async {
    final raw = await _storage.read(key: _storageKey);
    return _parse(raw);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = AsyncData(mode);
    await _storage.write(key: _storageKey, value: _serialize(mode));
  }

  static ThemeMode _parse(String? v) {
    return switch (v) {
      'light'  => ThemeMode.light,
      'dark'   => ThemeMode.dark,
      _        => ThemeMode.system,
    };
  }

  static String _serialize(ThemeMode m) {
    return switch (m) {
      ThemeMode.light  => 'light',
      ThemeMode.dark   => 'dark',
      ThemeMode.system => 'system',
    };
  }
}

final themeModeProvider =
    AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
