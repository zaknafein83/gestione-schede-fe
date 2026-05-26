import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_storage.dart';
import '../models/character_models.dart';
import 'characters_api.dart';

/// Fetch del dettaglio di una scheda. `autoDispose` cosi' quando esci dalla
/// screen che lo osserva il provider viene distrutto e al prossimo accesso
/// (es. passando dall'editor classico al layout custom) si fa un fetch fresh.
/// Evita drift fra le viste senza dover invalidare manualmente.
final characterDetailProvider =
    FutureProvider.autoDispose.family<CharacterDto, String>((ref, id) async {
  final storage = ref.read(authStorageProvider);
  final api     = ref.read(charactersApiProvider);
  final access  = await storage.loadAccess();
  if (access == null) {
    throw StateError('Utente non autenticato');
  }
  return api.get(access, id);
});
