import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Seed color condiviso per light e dark.
const Color _seed = Colors.deepPurple;

ThemeData buildLightTheme() => ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _seed),
      useMaterial3: true,
    );

ThemeData buildDarkTheme() => ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );

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
