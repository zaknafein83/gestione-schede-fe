import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../profile/data/avatar_providers.dart';
import '../models/auth_models.dart';
import 'auth_api.dart';
import 'auth_storage.dart';

/// Stato globale dell'utente autenticato:
///   - AsyncData(UserDto)  -> loggato
///   - AsyncData(null)     -> non loggato
///   - AsyncLoading()      -> sto facendo bootstrap / login
///   - AsyncError          -> errore di rete o credenziali
///
/// `build()` viene eseguito al primo `watch` e fa il bootstrap:
/// se in storage c'e' un access token, tenta `GET /me`; se il backend risponde
/// 401 prova un refresh trasparente.
class AuthController extends AsyncNotifier<UserDto?> {

  AuthApi      get _api     => ref.read(authApiProvider);
  AuthStorage  get _storage => ref.read(authStorageProvider);

  @override
  Future<UserDto?> build() async {
    final access = await _storage.loadAccess();
    if (access == null) return null;

    try {
      return await _api.me(access);
    } on ApiError catch (e) {
      if (e.status != 401) rethrow;
      return _tryRefresh();
    }
  }

  Future<UserDto?> _tryRefresh() async {
    final refresh = await _storage.loadRefresh();
    if (refresh == null) {
      await _storage.clear();
      return null;
    }
    try {
      final res = await _api.refresh(refresh);
      await _storage.saveTokens(access: res.accessToken, refresh: res.refreshToken);
      return res.user;
    } catch (_) {
      await _storage.clear();
      return null;
    }
  }

  /// Login: salva i token e popola lo stato con l'utente.
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final res = await _api.login(LoginRequest(email: email, password: password));
      await _storage.saveTokens(access: res.accessToken, refresh: res.refreshToken);
      return res.user;
    });
  }

  /// Aggiorna parzialmente il profilo (displayName/bio). Aggiorna lo state.
  Future<void> updateMe({String? displayName, String? bio}) async {
    final access = await _requireAccess();
    final updated = await _api.updateMe(
      access,
      UpdateMeRequest(displayName: displayName, bio: bio),
    );
    state = AsyncData(updated);
  }

  /// Cambia la password e poi pulisce lo stato locale: lato server tutti i
  /// refresh sono stati revocati, l'access attuale scadra' a breve.
  Future<void> changePassword(String currentPwd, String newPwd) async {
    final access = await _requireAccess();
    await _api.changePassword(
      access,
      ChangePasswordRequest(currentPassword: currentPwd, newPassword: newPwd),
    );
    await _storage.clear();
    state = const AsyncData(null);
  }

  /// Carica un nuovo avatar e aggiorna lo state + invalida la cache globale.
  Future<void> uploadAvatar(Uint8List bytes, String filename, String contentType) async {
    final access = await _requireAccess();
    final updated = await _api.uploadAvatar(
      access,
      bytes: bytes,
      filename: filename,
      contentType: contentType,
    );
    state = AsyncData(updated);
    ref.read(avatarVersionProvider.notifier).bump();
  }

  /// Rimuove l'avatar dell'utente.
  Future<void> deleteAvatar() async {
    final access = await _requireAccess();
    await _api.deleteAvatar(access);
    ref.read(avatarVersionProvider.notifier).bump();
  }

  /// GDPR: scarica un dump JSON completo dei dati personali (art. 15 + 20).
  /// Ritorna la mappa cosi' com'è dal backend; il caller la serializza/scarica.
  Future<Map<String, dynamic>> exportMyData() async {
    final access = await _requireAccess();
    return _api.exportMyData(access);
  }

  Future<String> _requireAccess() async {
    final access = await _storage.loadAccess();
    if (access == null) {
      throw StateError('Utente non autenticato');
    }
    return access;
  }

  /// Logout: revoca lato server, pulisce storage, azzera stato.
  /// Idempotente.
  Future<void> logout() async {
    final refresh = await _storage.loadRefresh();
    if (refresh != null) {
      try { await _api.logout(refresh); } catch (_) { /* best-effort */ }
    }
    await _storage.clear();
    state = const AsyncData(null);
  }

  /// Hard delete account + cascade lato server. Dopo successo: pulisce
  /// storage locale e azzera lo stato (utente sloggato).
  Future<void> deleteAccount(String password) async {
    final access = await _requireAccess();
    await _api.deleteAccount(access, password);
    // Tutto è già cancellato lato server; ripuliamo lo storage locale e
    // resettiamo lo stato. Niente logout API: l'utente è già sparito.
    await _storage.clear();
    state = const AsyncData(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserDto?>(AuthController.new);
