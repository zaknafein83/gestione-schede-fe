import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../auth/data/auth_storage.dart';
import 'characters_api.dart';

/// Cache-buster per i ritratti delle schede, indicizzato per characterId.
/// `bump(id)` invalida il `characterPortraitBytesProvider(id)`.
class CharacterPortraitVersions extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => const {};

  void bump(String id) {
    state = {...state, id: (state[id] ?? 0) + 1};
  }
}

final characterPortraitVersionsProvider =
    NotifierProvider<CharacterPortraitVersions, Map<String, int>>(
        CharacterPortraitVersions.new);

/// Bytes del ritratto della scheda. Null se la scheda non ha un ritratto
/// (server risponde 404 → mappato a null).
final characterPortraitBytesProvider =
    FutureProvider.family<Uint8List?, String>((ref, id) async {
  // Dipendenza esplicita: cambia → rerun
  ref.watch(characterPortraitVersionsProvider.select((m) => m[id] ?? 0));

  final access = await ref.read(authStorageProvider).loadAccess();
  if (access == null) return null;
  try {
    return await ref.read(charactersApiProvider).downloadPortrait(access, id);
  } on ApiError catch (e) {
    if (e.status == 404) return null;
    rethrow;
  }
});
