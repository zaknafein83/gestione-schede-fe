import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_storage.dart';
import '../models/layout_models.dart';
import 'character_layout_api.dart';

/// Fetch del layout di una scheda. Si invalida con
/// `ref.invalidate(characterLayoutProvider(id))` dopo PUT/DELETE.
final characterLayoutProvider =
    FutureProvider.family<CharacterLayout, String>((ref, id) async {
  final storage = ref.read(authStorageProvider);
  final api     = ref.read(characterLayoutApiProvider);
  final access  = await storage.loadAccess();
  if (access == null) {
    throw StateError('Utente non autenticato');
  }
  return api.get(access, id);
});
