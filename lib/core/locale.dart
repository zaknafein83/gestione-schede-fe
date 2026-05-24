import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Locale dell'app: null = segui la lingua di sistema, altrimenti override.
/// Le lingue supportate sono `it` e `en`.
class LocaleNotifier extends AsyncNotifier<Locale?> {
  final _storage = const FlutterSecureStorage();
  static const _key = 'ui.locale';

  @override
  Future<Locale?> build() async {
    final raw = await _storage.read(key: _key);
    return _parse(raw);
  }

  Future<void> setLocale(Locale? locale) async {
    state = AsyncData(locale);
    if (locale == null) {
      await _storage.delete(key: _key);
    } else {
      await _storage.write(key: _key, value: locale.languageCode);
    }
  }

  static Locale? _parse(String? code) {
    if (code == 'it') return const Locale('it');
    if (code == 'en') return const Locale('en');
    return null;
  }
}

final localeProvider =
    AsyncNotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);
