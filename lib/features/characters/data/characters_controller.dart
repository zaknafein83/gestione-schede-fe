import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_storage.dart';
import '../../share/logic/foundry_mapper.dart';
import '../../share/logic/pdf_builder.dart';
import '../models/character_models.dart';
import 'characters_api.dart';

/// Stato della lista schede dell'utente loggato.
///   - AsyncData(List)  -> caricate
///   - AsyncLoading()   -> primo fetch o refresh
///   - AsyncError       -> errore di rete
class CharactersListController extends AsyncNotifier<List<CharacterSummary>> {

  CharactersApi  get _api     => ref.read(charactersApiProvider);
  AuthStorage    get _storage => ref.read(authStorageProvider);

  @override
  Future<List<CharacterSummary>> build() async {
    return _fetch();
  }

  Future<List<CharacterSummary>> _fetch() async {
    final access = await _storage.loadAccess();
    if (access == null) return const [];
    return _api.list(access);
  }

  /// Ricarica la lista dal backend.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Crea una scheda vuota e ricarica la lista. Ritorna l'id della nuova scheda.
  Future<String> createEmpty() async {
    final access = await _requireAccess();
    final created = await _api.create(access, const {});
    await refresh();
    return created.id;
  }

  /// Duplica la scheda con id dato e ricarica la lista. Ritorna l'id della copia.
  Future<String> duplicate(String id) async {
    final access = await _requireAccess();
    final copy = await _api.duplicate(access, id);
    await refresh();
    return copy.id;
  }

  /// Elimina una scheda e ricarica la lista.
  Future<void> deleteOne(String id) async {
    final access = await _requireAccess();
    await _api.delete(access, id);
    await refresh();
  }

  /// Rinomina una scheda (PATCH con solo `name`) e ricarica la lista.
  /// Una stringa vuota viene trimmata e finisce su null lato backend
  /// (scheda senza nome).
  Future<void> rename(String id, String newName) async {
    final access = await _requireAccess();
    await _api.patch(access, id, {'name': newName});
    await refresh();
  }

  /// Restituisce il JSON formattato (indent 2) della scheda con id dato.
  /// I campi server-managed (id, ownerId, timestamps, portraitFileId) sono
  /// rimossi: il file rappresenta solo i dati editabili.
  Future<String> exportToJson(String id) async {
    final access = await _requireAccess();
    final c = await _api.get(access, id);
    final clean = _sanitizeForExport(c.raw);
    return const JsonEncoder.withIndent('  ').convert(clean);
  }

  /// Crea una nuova scheda con i dati del JSON in input. Pulisce i campi
  /// server-managed prima del POST. Ritorna l'id della scheda creata.
  Future<String> importFromJson(Map<String, dynamic> payload) async {
    final access  = await _requireAccess();
    final cleaned = _sanitizeForExport(payload);
    final created = await _api.create(access, cleaned);
    await refresh();
    return created.id;
  }

  /// Esporta come PDF "scheda di gioco" (vedi pdf_builder.dart).
  /// Le label del PDF sono localizzate nella lingua corrente passata in [l10n].
  Future<Uint8List> exportToPdf(String id, AppL10n l10n) async {
    final access = await _requireAccess();
    final c = await _api.get(access, id);
    return buildCharacterPdf(c.raw, l10n);
  }

  /// Esporta come JSON FoundryVTT dnd5e (best-effort: vedi foundry_mapper.dart).
  Future<String> exportToFoundry(String id) async {
    final access = await _requireAccess();
    final c = await _api.get(access, id);
    final foundryJson = toFoundry(c.raw);
    return const JsonEncoder.withIndent('  ').convert(foundryJson);
  }

  /// Importa una scheda da JSON Foundry dnd5e (best-effort).
  Future<String> importFromFoundry(Map<String, dynamic> foundryJson) async {
    final access  = await _requireAccess();
    final ours    = fromFoundry(foundryJson);
    final created = await _api.create(access, ours);
    await refresh();
    return created.id;
  }

  Map<String, dynamic> _sanitizeForExport(Map<String, dynamic> input) {
    final out = Map<String, dynamic>.from(input);
    out.remove('id');
    out.remove('ownerId');
    out.remove('portraitFileId');
    out.remove('createdAt');
    out.remove('updatedAt');
    return out;
  }

  Future<String> _requireAccess() async {
    final access = await _storage.loadAccess();
    if (access == null) {
      throw StateError('Utente non autenticato');
    }
    return access;
  }
}

final charactersListProvider =
    AsyncNotifierProvider<CharactersListController, List<CharacterSummary>>(
        CharactersListController.new);
