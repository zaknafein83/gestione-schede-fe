import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../auth/data/auth_api.dart';
import '../../auth/data/auth_storage.dart';

/// Notifier che funge da cache-buster globale per l'avatar.
/// In Riverpod 3.x `StateProvider` e' stato rimosso: si usa un `Notifier`.
class AvatarVersionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// Incrementa il contatore: `avatarBytesProvider` si invalidera'
  /// e i widget rifaranno il fetch.
  void bump() => state = state + 1;
}

final avatarVersionProvider =
    NotifierProvider<AvatarVersionNotifier, int>(AvatarVersionNotifier.new);

/// Bytes dell'avatar dell'utente loggato. Si invalida quando cambia
/// `avatarVersionProvider`. Ritorna null se non c'e' avatar (404).
final avatarBytesProvider = FutureProvider<Uint8List?>((ref) async {
  ref.watch(avatarVersionProvider);   // dipendenza: cambia → rerun

  final access = await ref.read(authStorageProvider).loadAccess();
  if (access == null) return null;
  try {
    return await ref.read(authApiProvider).downloadAvatar(access);
  } on ApiError catch (e) {
    if (e.status == 404) return null;
    rethrow;
  }
});
