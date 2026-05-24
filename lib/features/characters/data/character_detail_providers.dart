import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_storage.dart';
import '../models/character_models.dart';
import 'characters_api.dart';

/// Fetch del dettaglio di una scheda. Riferito per id; si invalida con
/// `ref.invalidate(characterDetailProvider(id))` dopo PATCH/portrait/ecc.
final characterDetailProvider =
    FutureProvider.family<CharacterDto, String>((ref, id) async {
  final storage = ref.read(authStorageProvider);
  final api     = ref.read(charactersApiProvider);
  final access  = await storage.loadAccess();
  if (access == null) {
    throw StateError('Utente non autenticato');
  }
  return api.get(access, id);
});
