import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_error.dart';
import '../../auth/data/auth_storage.dart';
import 'character_detail_providers.dart';
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

/// Bytes del ritratto della scheda. Null se la scheda non ha un ritratto.
///
/// Skippa la GET se il detail della scheda ha già `portraitFileId == null`:
/// evita un 404 cosmetico nel Network panel del browser per schede senza
/// ritratto. Se il detail non è ancora caricato (loading/error) prova
/// comunque la fetch, e mappa il 404 server a null.
final characterPortraitBytesProvider =
    FutureProvider.family<Uint8List?, String>((ref, id) async {
  // Dipendenza esplicita: cambia → rerun
  ref.watch(characterPortraitVersionsProvider.select((m) => m[id] ?? 0));

  // Short-circuit se sappiamo già che la scheda non ha portrait.
  final detail = ref.watch(characterDetailProvider(id)).asData?.value;
  if (detail != null && detail.portraitFileId == null) return null;

  final access = await ref.read(authStorageProvider).loadAccess();
  if (access == null) return null;
  try {
    return await ref.read(charactersApiProvider).downloadPortrait(access, id);
  } on ApiError catch (e) {
    if (e.status == 404) return null;
    rethrow;
  }
});
