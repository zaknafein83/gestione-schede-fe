import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper su [FlutterSecureStorage] per conservare access + refresh token.
/// Su Flutter Web usa l'IndexedDB cifrata via Web Crypto (default del plugin).
class AuthStorage {
  AuthStorage(this._storage);

  static const _kAccess  = 'auth.access_token';
  static const _kRefresh = 'auth.refresh_token';

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: _kAccess,  value: access);
    await _storage.write(key: _kRefresh, value: refresh);
  }

  Future<String?> loadAccess()  => _storage.read(key: _kAccess);
  Future<String?> loadRefresh() => _storage.read(key: _kRefresh);

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}

final authStorageProvider = Provider<AuthStorage>((ref) {
  return AuthStorage(const FlutterSecureStorage());
});
